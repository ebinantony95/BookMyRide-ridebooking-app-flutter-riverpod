import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:make_my_ride/core/theme/app_colors.dart';
import 'package:make_my_ride/features/pending_rides/presentation/providers/pending_ride_provider.dart';
import 'package:make_my_ride/features/maps/presentation/view /widgets/book_your_ride_button.dart';
import 'package:make_my_ride/features/maps/presentation/view /widgets/ride_summary_widget.dart';
import 'package:make_my_ride/features/polylines_routes/presentation/providers/polyline_route_providers.dart';
import 'package:make_my_ride/shared/models/location_model.dart';
import '../../providers/map_providers.dart';

class SearchBottomSheet extends ConsumerWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(String) onSearchChanged;
  final VoidCallback onCloseSearch;
  final MapController mapController;

  const SearchBottomSheet({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.onCloseSearch,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapViewModelProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: isSearching
          ? 0
          : (state.isSummaryMode
              ? MediaQuery.of(context).size.height - 400
              : MediaQuery.of(context).size.height - 250),
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding:
            EdgeInsets.only(top: isSearching ? 60 : 20, left: 24, right: 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: isSearching
              ? BorderRadius.zero
              : const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: theme.brightness == Brightness.dark ? 26 : 20,
              offset: const Offset(0, -6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isSummaryMode)
              Expanded(
                child: const RideSummaryWidget(),
              )
            else ...[
              if (!isSearching)
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Where to?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

              /// Search Input Row
              Row(
                children: [
                  if (isSearching)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: onCloseSearch,
                      ),
                    ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        onChanged: onSearchChanged,
                        decoration: InputDecoration(
                          hintText: "Search destination...",
                          hintStyle: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    searchController.clear();
                                    onSearchChanged("");
                                    ref
                                        .read(mapViewModelProvider.notifier)
                                        .clearSelection();
                                    ref
                                        .read(
                                          polylineRouteViewModelProvider
                                              .notifier,
                                        )
                                        .clearPreviewRoute();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Results or Quick Actions
              Expanded(
                child: isSearching
                    ? _buildSearchResults(state, ref)
                    : Column(
                        children: [
                          BookYourRideButton(),
                          const SizedBox(height: 20), // SizedBox below the row
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // book my ride button

// search results or error widgets.
  Widget _buildSearchResults(dynamic state, WidgetRef ref) {
    if (searchController.text.isEmpty) {
      return const SizedBox();
    }
    if (state.searchResults.isEmpty) {
      return Center(
        child: Text(
          "No results found",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: state.searchResults.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final place = state.searchResults[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(Icons.place, color: AppColors.textSecondary),
          title: Text(place.name,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          onTap: () {
            if (ref.read(hasBlockingRideProvider)) {
              ref.read(mapViewModelProvider.notifier).setSummaryMode(true);
              onCloseSearch();
              return;
            }

            ref.read(mapViewModelProvider.notifier).selectPlace(place);
            final pickup = ref.read(mapViewModelProvider).currentLocation;

            if (pickup != null) {
              ref
                  .read(polylineRouteViewModelProvider.notifier)
                  .fetchPreviewRoute(
                    pickup: LocationPoint(
                      latitude: pickup.latitude,
                      longitude: pickup.longitude,
                    ),
                    drop: LocationPoint(
                      latitude: place.lat,
                      longitude: place.lon,
                      name: place.name,
                    ),
                  );
            }

            mapController.move(
              LatLng(place.lat, place.lon),
              15, // Keep standard zoom
            );

            searchController.text = place.name;
            onCloseSearch(); // Elongated view pops back down inherently
          },
        );
      },
    );
  }
}
