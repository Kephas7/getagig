import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/presentation/view_model/gigs_feed_viewmodel.dart';
import 'package:getagig/features/gigs/presentation/pages/gig_details_page.dart';
import 'package:getagig/features/gigs/presentation/pages/my_applications_page.dart';

class GigsExplorePage extends ConsumerStatefulWidget {
  const GigsExplorePage({super.key});

  @override
  ConsumerState<GigsExplorePage> createState() => _GigsExplorePageState();
}

class _GigsExplorePageState extends ConsumerState<GigsExplorePage> {
  String _searchQuery = "";
  String _selectedFilter = "All";

  final List<String> _filters = [
    "All",
    "Wedding",
    "Club",
    "Private",
    "Corporate",
  ];

  @override
  Widget build(BuildContext context) {
    final gigsAsyncValue = ref.watch(gigsFeedProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Find Gigs',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 28,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_outlined, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyApplicationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Search gigs by title...",
                        hintStyle: TextStyle(color: Colors.black38),
                        prefixIcon: Icon(Icons.search, color: Colors.black54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: Colors.black87,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide.none,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Gig List
          Expanded(
            child: gigsAsyncValue.when(
              data: (gigs) {
                var filteredGigs = gigs.where((gig) {
                  final normalizedQuery = _searchQuery.trim().toLowerCase();
                  final searchable = [
                    gig.title,
                    gig.description,
                    gig.eventType,
                    gig.location,
                    gig.organizerName,
                    ...gig.genres,
                    ...gig.instruments,
                  ].join(' ').toLowerCase();

                  final matchesSearch =
                      normalizedQuery.isEmpty ||
                      searchable.contains(normalizedQuery);
                  final matchesFilter =
                      _selectedFilter == "All" ||
                      gig.eventType.toLowerCase().contains(
                        _selectedFilter.toLowerCase(),
                      );
                  return matchesSearch && matchesFilter;
                }).toList();

                final hasActiveFilters =
                    _searchQuery.trim().isNotEmpty || _selectedFilter != 'All';

                if (filteredGigs.isEmpty) {
                  return _EmptyState(
                    onClearFilters: hasActiveFilters
                        ? () {
                            setState(() {
                              _searchQuery = '';
                              _selectedFilter = 'All';
                            });
                          }
                        : null,
                  );
                }

                return RefreshIndicator(
                  color: Colors.black87,
                  onRefresh: () =>
                      ref.read(gigsFeedProvider.notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${filteredGigs.length} Gigs Found',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...filteredGigs.map((gig) => _GigCard(gig: gig)),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.black87),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _GigCard extends StatelessWidget {
  final GigEntity gig;
  const _GigCard({required this.gig});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GigDetailsPage(gig: gig)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      gig.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    "Rs. ${gig.payRate}",
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.black45,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    gig.location,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.black45,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    gig.deadline?.toLocal().toString().split(' ')[0] ??
                        'No deadline',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  gig.eventType,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onClearFilters;

  const _EmptyState({this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No gigs found",
            style: TextStyle(color: Colors.black38, fontSize: 18),
          ),
          if (onClearFilters != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onClearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }
}
