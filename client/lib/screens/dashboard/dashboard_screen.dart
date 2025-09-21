import 'dart:ui';
import '../upload/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/screens/session/session_list_screen.dart';
// Import your auth provider (adjust path accordingly)
import 'package:client/screens/auth/auth_provider.dart';
import '../auth/sign_in_screen.dart';

class DummyStartup {
  final int id;
  final String title;
  final String category;
  final bool approved;

  DummyStartup({
    required this.id,
    required this.title,
    required this.category,
    required this.approved,
  });
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final List<DummyStartup> startups = List.generate(
    10,
    (index) => DummyStartup(
      id: index,
      title: 'Idea #$index – Smart Widget',
      category: index % 2 == 0 ? 'technology' : 'industry',
      approved: index % 3 == 0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final totalIdeas = startups.length.toString();
    final approvedIdeas = startups.where((s) => s.approved).length.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        title: const Text('Evalora - Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SessionListScreen()),
              );
            },
            icon: const Icon(Icons.schedule),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UploadScreen()),
              );
            },
            icon: const Icon(Icons.upload),
          ),
          Consumer(
            builder: (context, ref, _) {
              final user = ref.watch(authProvider).currentUser;
              if (user == null) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                offset: const Offset(0, 48),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tooltip: 'Account',
                onSelected: (value) async {
                  if (value == 'profile') {
                    // Show profile dialog
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(user.displayName ?? 'No Name'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (user.photoURL != null)
                              CircleAvatar(
                                backgroundImage: NetworkImage(user.photoURL!),
                                radius: 40,
                              ),
                            const SizedBox(height: 12),
                            Text('Email: ${user.email ?? 'No Email'}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close')),
                        ],
                      ),
                    );
                  } else if (value == 'logout') {
                    // Call your logout method from authProvider
                    await ref.read(authProvider).signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                      (route) => false,
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child:
                            user.photoURL == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(user.displayName ?? ''),
                      subtitle: Text(user.email ?? ''),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child:
                          user.photoURL == null ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.displayName ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(36),
            padding: const EdgeInsets.all(40),
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.07),
                  blurRadius: 24,
                  spreadRadius: 8,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GlassInfoCard(
                      title: 'Total Ideas',
                      value: totalIdeas,
                      icon: Icons.lightbulb_outline,
                      color: Colors.indigo.shade400,
                    ),
                    GlassInfoCard(
                      title: 'Approved Ideas',
                      value: approvedIdeas,
                      icon: Icons.check_circle_outline,
                      color: Colors.green.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 34, horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GlassCategoryCard(
                        title: 'Technology',
                        icon: Icons.memory,
                        color: Colors.indigo.shade400,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => CategoryFilteredScreen(
                              category: 'technology',
                              startups: startups,
                            ),
                          ));
                        },
                      ),
                      const SizedBox(width: 40),
                      GlassCategoryCard(
                        title: 'Industry',
                        icon: Icons.factory,
                        color: Colors.teal.shade400,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => CategoryFilteredScreen(
                              category: 'industry',
                              startups: startups,
                            ),
                          ));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryFilteredScreen extends ConsumerStatefulWidget {
  final String category;
  final List<DummyStartup> startups;

  const CategoryFilteredScreen({
    super.key,
    required this.category,
    required this.startups,
  });

  @override
  ConsumerState<CategoryFilteredScreen> createState() => _CategoryFilteredScreenState();
}

class _CategoryFilteredScreenState extends ConsumerState<CategoryFilteredScreen> {
  String searchQuery = "";
  String? selectedSubCategory;

  // Subcategories per main category
  final Map<String, List<String>> subCategoriesMap = {
    "technology": ["AI", "Blockchain", "Cloud", "VR", "IoT"],
    "industry": ["Manufacturing", "Retail", "Healthcare", "Finance"],
  };

  @override
  Widget build(BuildContext context) {
    final String categoryKey = widget.category.toLowerCase();
    final List<String> subCategories = subCategoriesMap[categoryKey] ?? [];

    // Compose dropdown list with 'null' for 'All'
    final List<String?> dropdownItems = [null, ...subCategories];

    // Filtered list based on category, search query and subcategory
    var filteredList = widget.startups.where((idea) {
      final bool matchesCategory = idea.category.toLowerCase() == categoryKey;
      final bool matchesSearch = idea.title.toLowerCase().contains(searchQuery.toLowerCase());
      final bool matchesSubcategory = (selectedSubCategory == null ||
          selectedSubCategory!.isEmpty) ? true : idea.title.toLowerCase().contains(selectedSubCategory!.toLowerCase());
      return matchesCategory && matchesSearch && matchesSubcategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.capitalize()} Ideas'),
        backgroundColor: Colors.blueGrey.shade900
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (subCategories.isNotEmpty) const SizedBox(height: 12),

// Combined search bar and filter button
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search ideas...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final selected = await showModalBottomSheet<String?>(
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(18))),
                          builder: (context) {
                            final List<String?> subCatOptions = [null, ...subCategories];
                            return ListView(
                              shrinkWrap: true,
                              children: subCatOptions.map((subCat) {
                                return ListTile(
                                  title: Text(subCat ?? 'All Subcategories'),
                                  onTap: () => Navigator.pop(context, subCat),
                                  selected: selectedSubCategory == subCat,
                                );
                              }).toList(),
                            );
                          },
                        );
                        if (selected != null || selectedSubCategory != null) {
                          setState(() {
                            selectedSubCategory = selected;
                          });
                        }
                      },
                      icon: const Icon(Icons.filter_list),
                      label: Text(selectedSubCategory ?? 'All'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: filteredList.isEmpty
                  ? const Center(child: Text("No results found"))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 3 / 2),
                      itemCount: filteredList.length,
                      itemBuilder: (_, idx) {
                        var idea = filteredList[idx];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                        categoryKey == "technology" ? Icons.memory : Icons.factory,
                                        color: categoryKey == "technology" ? Colors.indigo : Colors.teal,
                                        size: 22),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        idea.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.category.capitalize(),
                                  style: TextStyle(
                                      color: categoryKey == "technology" ? Colors.indigo : Colors.teal,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Text(
                                  idea.approved ? "Approved" : "Pending",
                                  style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassInfoCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const GlassInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<GlassInfoCard> createState() => _GlassInfoCardState();
}

class _GlassInfoCardState extends State<GlassInfoCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      constraints: const BoxConstraints(minWidth: 220),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.37),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: widget.color.withOpacity(0.3),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(isHovered ? 0.3 : 0.15),
            blurRadius: isHovered ? 28 : 20,
            offset: Offset(0, isHovered ? 16 : 12),
          ),
        ],
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() {
          isHovered = true;
        }),
        onExit: (_) => setState(() {
          isHovered = false;
        }),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 40, color: widget.color),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: TextStyle(
                  color: Colors.blueGrey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.value,
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return card;
  }
}

class GlassCategoryCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const GlassCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<GlassCategoryCard> createState() => _GlassCategoryCardState();
}

class _GlassCategoryCardState extends State<GlassCategoryCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      constraints: const BoxConstraints(minWidth: 160),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: widget.color.withOpacity(0.26),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(isHovered ? 0.38 : 0.22),
            blurRadius: isHovered ? 28 : 14,
            offset: Offset(0, isHovered ? 16 : 10),
          ),
        ],
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() {
          isHovered = true;
        }),
        onExit: (_) => setState(() {
          isHovered = false;
        }),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 40, color: widget.color),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );

    return card;
  }
}

extension StringCap on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}
