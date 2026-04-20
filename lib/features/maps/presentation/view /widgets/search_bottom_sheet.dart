import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
          color: Colors.white,
          borderRadius: isSearching
              ? BorderRadius.zero
              : const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
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
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Where to?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        onChanged: onSearchChanged,
                        decoration: InputDecoration(
                          hintText: "Search destination...",
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                          border: InputBorder.none,
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.grey),
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
      return const Center(
          child:
              Text("No results found", style: TextStyle(color: Colors.grey)));
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: state.searchResults.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: Colors.black12),
      itemBuilder: (context, index) {
        final place = state.searchResults[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const Icon(Icons.place, color: Colors.grey),
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
