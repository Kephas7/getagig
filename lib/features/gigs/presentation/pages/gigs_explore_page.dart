import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:getagig/core/controllers/shake_refresh_controller.dart';
import 'package:getagig/features/applications/presentation/pages/my_applications_page.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/presentation/view_model/gigs_feed_viewmodel.dart';
import 'package:getagig/features/gigs/presentation/pages/gig_details_page.dart';

class GigsExplorePage extends ConsumerStatefulWidget {
  const GigsExplorePage({super.key});

  @override
  ConsumerState<GigsExplorePage> createState() => _GigsExplorePageState();
}

class _GigsExplorePageState extends ConsumerState<GigsExplorePage> {
  late final ShakeRefreshController _shakeRefreshController;
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
  void initState() {
    super.initState();
    _shakeRefreshController = ShakeRefreshController(
      onShake: _refreshFromShake,
    );
    _shakeRefreshController.start();
  }

  @override
  void dispose() {
    _shakeRefreshController.dispose();
    super.dispose();
  }

  Future<void> _refreshGigsFeed() async {
    await ref.read(gigsFeedProvider.notifier).refresh();
  }

  Future<void> _refreshFromShake() async {
    await _refreshGigsFeed();

    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Page refreshed')));
  }

  @override
  Widget build(BuildContext context) {
    final gigsAsyncValue = ref.watch(gigsFeedProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Find Gigs',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 28,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.assignment_outlined, color: colorScheme.onSurface),
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
                      color: AppShellStyles.mutedSurface(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search gigs by title...",
                        hintStyle: TextStyle(
                          color: AppShellStyles.mutedText(context),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppShellStyles.mutedText(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
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
                    selectedColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    backgroundColor: AppShellStyles.mutedSurface(context),
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
                  color: colorScheme.secondary,
                  onRefresh: _refreshGigsFeed,
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
                            color: AppShellStyles.mutedSurface(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${filteredGigs.length} Gigs Found',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppShellStyles.cardSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppShellStyles.border(context)),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.onSurface,
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
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppShellStyles.mutedText(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    gig.location,
                    style: TextStyle(color: AppShellStyles.mutedText(context)),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppShellStyles.mutedText(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    gig.deadline?.toLocal().toString().split(' ')[0] ??
                        'No deadline',
                    style: TextStyle(color: AppShellStyles.mutedText(context)),
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
                  color: AppShellStyles.mutedSurface(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  gig.eventType,
                  style: TextStyle(
                    color: AppShellStyles.mutedText(context),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppShellStyles.mutedText(context).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No gigs found",
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.66),
              fontSize: 18,
            ),
          ),
          if (onClearFilters != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onClearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }
}
