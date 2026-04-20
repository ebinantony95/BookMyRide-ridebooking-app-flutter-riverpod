import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:go_router/go_router.dart';
import 'package:make_my_ride/core/router/app_routes.dart';
import 'package:make_my_ride/core/theme/theme.dart';
import 'package:make_my_ride/features/auth/presentation/providers/auth_provider.dart';
import 'package:make_my_ride/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:make_my_ride/features/pending_rides/presentation/providers/pending_ride_provider.dart';
import 'package:make_my_ride/features/polylines_routes/presentation/providers/polyline_route_providers.dart';
import 'package:make_my_ride/features/ride/presentation/providers/user_id_provider.dart';
import 'package:make_my_ride/shared/models/location_model.dart';

import '../providers/map_providers.dart';
import 'widgets/search_bottom_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController controller = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final MapController mapController = MapController();
  Timer? _debounce;
  bool _isSearching = false;
  bool _isMapReady = false;
  String? _lastRouteSignature;
  List<LocationPoint>? _pendingFitPoints;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          _isSearching = true;
        });
      }
    });

    Future.microtask(() {
      ref.read(mapViewModelProvider.notifier).loadLocation();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    _searchFocusNode.dispose();
    mapController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.isNotEmpty) {
        ref.read(mapViewModelProvider.notifier).search(query);
      }
      setState(() {});
    });
    setState(() {}); // to show the clear button interactively
  }

  void _closeSearch() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = false;
    });
  }

  String? _routeSignature(List<LocationPoint> points) {
    if (points.length < 2) {
      return null;
    }

    final first = points.first;
    final last = points.last;
    return '${points.length}:${first.latitude}:${first.longitude}:${last.latitude}:${last.longitude}';
  }

  void _handleMapReady() {
    if (_isMapReady || !mounted) {
      return;
    }

    _isMapReady = true;

    final pendingPoints = _pendingFitPoints;
    _pendingFitPoints = null;
    if (pendingPoints != null) {
      _fitPolyline(pendingPoints);
      return;
    }

    final route = ref.read(polylineRouteViewModelProvider).route;
    if (route != null) {
      _fitPolyline(route.points);
    }
  }

  void _fitPolyline(List<LocationPoint> points) {
    if (points.length < 2 || !mounted) {
      return;
    }

    if (!_isMapReady) {
      _pendingFitPoints = List<LocationPoint>.from(points);
      return;
    }

    final coordinates = points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: coordinates,
          padding: const EdgeInsets.fromLTRB(48, 88, 48, 280),
          maxZoom: 15.5,
        ),
      );
    });
  }

  String _themeModeLabel(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final activeRide = ref.watch(activeRideProvider).valueOrNull;
    final polylineRouteState = ref.watch(polylineRouteViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(polylineRouteViewModelProvider, (previous, next) {
      if (!next.hasRoute) {
        _lastRouteSignature = null;
        return;
      }

      final route = next.route;
      if (route == null) {
        return;
      }

      final signature = _routeSignature(route.points);
      if (signature == null || signature == _lastRouteSignature) {
        return;
      }

      _lastRouteSignature = signature;
      _fitPolyline(route.points);
    });

    if (state.currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final current = state.currentLocation!;
    final routePoints = polylineRouteState.route?.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(growable: false) ??
        const <LatLng>[];
    final destinationPoint = activeRide != null
        ? LatLng(activeRide.dropLat, activeRide.dropLng)
        : state.selectedPlace != null
            ? LatLng(state.selectedPlace!.lat, state.selectedPlace!.lon)
            : null;
    final pickupPoint = activeRide != null
        ? LatLng(activeRide.pickupLat, activeRide.pickupLng)
        : null;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildAppDrawer(context, authState),
      body: Stack(
        children: [
          /// 1. Background Map
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(current.latitude, current.longitude),
              initialZoom: 15,
              onMapReady: _handleMapReady,
              onTap: (_, __) {
                if (_isSearching) {
                  _closeSearch();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.make_my_ride',
              ),
              if (routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5,
                      color: AppColors.primary,
                      borderStrokeWidth: 2,
                      borderColor: colorScheme.surface.withValues(alpha: 0.88),
                    ),
                  ],
                ),
              CurrentLocationLayer(
                alignPositionOnUpdate: AlignOnUpdate.never,
                alignDirectionOnUpdate: AlignOnUpdate.never,
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    color: AppColors.primary,
                    child:
                        Icon(Icons.navigation, color: Colors.white, size: 16),
                  ),
                  markerSize: Size(36, 36),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              MarkerLayer(
                markers: [
                  if (pickupPoint != null)
                    Marker(
                      point: pickupPoint,
                      child: Icon(
                        Icons.radio_button_checked,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  if (destinationPoint != null)
                    Marker(
                      point: destinationPoint,
                      child: Icon(
                        Icons.location_pin,
                        color: AppColors.textPrimary,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          /// 2. Floating Action Buttons (Hidden when searching)
          if (!_isSearching) ...[
            Positioned(
              top: 60,
              left: 16,
              child: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: _buildFloatingIcon(Icons.person_outline),
              ),
            ),
            Positioned(
              top: 60,
              right: 16,
              child: _buildFloatingIcon(Icons.notifications_none),
            ),
            Positioned(
              bottom: 270,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  mapController.move(
                    LatLng(current.latitude, current.longitude),
                    15,
                  );
                },
                child: _buildFloatingIcon(Icons.my_location,
                    iconColor: AppColors.primary),
              ),
            ),
          ],

          /// 3. Animated Bottom "Where to?" Card -> Full Screen Search
          SearchBottomSheet(
            isSearching: _isSearching,
            searchController: controller,
            searchFocusNode: _searchFocusNode,
            onSearchChanged: _onSearchChanged,
            onCloseSearch: _closeSearch,
            mapController: mapController,
          ),
        ],
      ),
    );
  }

  Drawer _buildAppDrawer(BuildContext context, AuthState authState) {
    final user = authState.user;
    final userName = user?.name?.trim();
    final title =
        userName != null && userName.isNotEmpty ? userName : 'My Account';
    final subtitle = user?.phoneNumber ?? 'Signed-in user';
    final themeMode = ref.watch(appThemeModeProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Drawer actions stay here so account navigation is easy to follow.
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Ride History'),
              subtitle: const Text('View all rides for this account'),
              onTap: () {
                final userId = ref.read(userIdProvider);
                Navigator.of(context).pop();
                context.push('${AppRoutes.rideHistory}/$userId');
              },
            ),
            ListTile(
              leading: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.dark_mode_rounded
                    : themeMode == ThemeMode.light
                        ? Icons.light_mode_rounded
                        : Icons.brightness_auto_rounded,
              ),
              title: const Text('Appearance'),
              subtitle: Text(_themeModeLabel(themeMode)),
              trailing: PopupMenuButton<ThemeMode>(
                initialValue: themeMode,
                onSelected: (mode) {
                  ref.read(appThemeModeProvider.notifier).setThemeMode(mode);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: ThemeMode.system,
                    child: Text('System'),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Sign Out'),
              subtitle: const Text('Exit this account'),
              onTap: () async {
                Navigator.of(context).pop();
                await ref.read(authViewModelProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(
    IconData icon, {
    Color? iconColor,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor ?? AppColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }
}
