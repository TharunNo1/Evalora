import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../upload/upload_screen.dart';
import '../session/session_list_screen.dart';
import '../auth/auth_provider.dart';
import '../auth/sign_in_screen.dart';
import '../re_evaluation/re_evaluation_screen.dart';

// ======================= MODEL ===========================
class Startup {
  final String id;
  final String name;
  final String description;
  final List<String> categories;
  final Map<String, dynamic> subCategories;
  final String founder;
  final String founderId;
  final double score;
  final String currentStatus;
  final bool approved;
  final Map<String, dynamic> docsList;

  Startup({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
    required this.subCategories,
    required this.founder,
    required this.founderId,
    required this.score,
    required this.currentStatus,
    required this.approved,
    required this.docsList,
  });

  factory Startup.fromJson(Map<String, dynamic> json) {
    return Startup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      categories: List<String>.from(json['categories']),
      subCategories: Map<String, dynamic>.from(json['subCategories']),
      founder: json['founder'],
      founderId: json['founder_id'],
      score: (json['score'] as num).toDouble(),
      currentStatus: json['currentStatus'],
      approved: json['approved'],
      docsList: Map<String, dynamic>.from(json['docsList'] ?? {}),
    );
  }
}

// ======================= DASHBOARD ===========================
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Future<List<Startup>> futureStartups;

  @override
  void initState() {
    super.initState();
    futureStartups = fetchStartups();
  }

  Future<List<Startup>> fetchStartups() async {
    // 🔑 Replace with your actual backend endpoint
    const String apiUrl = "http://127.0.0.1:8000/startups";

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Startup.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load startups");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 12),
            const Text('Evalora - Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SessionListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadScreen()),
            ),
          ),
          Consumer(
            builder: (context, ref, _) {
              final user = ref.watch(authProvider).currentUser;
              if (user == null) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await ref.read(authProvider).signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
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
                        child: user.photoURL == null
                            ? const Icon(Icons.person)
                            : null,
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
                      child: user.photoURL == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(user.displayName ?? '',
                        style: const TextStyle(color: Colors.white)),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Startup>>(
        future: futureStartups,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No startups found"));
          }

          final startups = snapshot.data!;
          final totalIdeas = startups.length.toString();
          final approvedIdeas =
              startups.where((s) => s.approved).length.toString();
          print(
              'Fetched ${startups.length} startups, $approvedIdeas approved. list of startups: $startups');
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Image.asset('assets/investor.png',
                          width: 120, height: 120),
                      const SizedBox(height: 16),
                      const Text('Investor',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
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
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 32),
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
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CategoryFilteredScreen(
                                          category: 'Technology',
                                          startups: startups,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 40),
                                  GlassCategoryCard(
                                    title: 'Industry',
                                    icon: Icons.factory,
                                    color: Colors.teal.shade400,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CategoryFilteredScreen(
                                          category: 'Industry',
                                          startups: startups,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Image.asset('assets/founder.png',
                          width: 120, height: 120),
                      const SizedBox(height: 16),
                      const Text('Founder',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ReevaluationDialog.show(context),
        label: const Text('Request Re-evaluation'),
        icon: const Icon(Icons.refresh),
        backgroundColor: Colors.blueGrey.shade900,
      ),
    );
  }
}

// ======================= CATEGORY FILTER ===========================
class CategoryFilteredScreen extends ConsumerStatefulWidget {
  final String category;
  final List<Startup> startups;

  const CategoryFilteredScreen({
    super.key,
    required this.category,
    required this.startups,
  });

  @override
  ConsumerState<CategoryFilteredScreen> createState() =>
      _CategoryFilteredScreenState();


}

class _CategoryFilteredScreenState
    extends ConsumerState<CategoryFilteredScreen> {
  String searchQuery = "";
  String? selectedSubCategory;

  Map<String, List<String>> buildSubCategoriesMap(List<Startup> startups) {
  final Map<String, Set<String>> dynamicMap = {};
  for (final s in startups) {
    for (final cat in s.categories) {
      final key = cat.toLowerCase();
      final subs = (s.subCategories[cat] ??
                    s.subCategories[key] ??
                    []) as List;
      dynamicMap.putIfAbsent(key, () => <String>{});
      dynamicMap[key]!.addAll(subs.map((e) => e.toString()));
    }
  }
  return dynamicMap.map((k, v) => MapEntry(k, v.toList()..sort()));
}

  @override
  Widget build(BuildContext context) {
    final String categoryKey = widget.category.toLowerCase();
    final subCategoriesMap = buildSubCategoriesMap(widget.startups);
    final List<String> subCategories = subCategoriesMap[categoryKey] ?? [];

    String selectedCategory = categoryKey;
    String? selectedSub = selectedSubCategory;

    final filteredList = widget.startups.where((startup) {
      // ✅ Case-insensitive main category match
      if (!startup.categories.any((c) => c.toLowerCase() == selectedCategory)) {
        return false;
      }

      // ✅ Safely retrieve subcategories (Title or lower case key)
      final List subs = (startup.subCategories[widget.category] ??
          startup.subCategories[selectedCategory] ??
          []) as List;

      // ✅ Optional subcategory filter
      if (selectedSub != null &&
          selectedSub.isNotEmpty &&
          !subs.any(
              (s) => s.toString().toLowerCase() == selectedSub.toLowerCase())) {
        return false;
      }

      // ✅ Optional search filter
      if (searchQuery.isNotEmpty &&
          !(startup.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              startup.description
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))) {
        return false;
      }

      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
          title: Text('${widget.category.capitalize()} Ideas'),
          backgroundColor: Colors.blueGrey.shade900),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search and filter row
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
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
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
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(18))),
                          builder: (context) {
                            final List<String?> options = [
                              null,
                              ...subCategories
                            ];
                            return ListView(
                              shrinkWrap: true,
                              children: options.map((subCat) {
                                return ListTile(
                                  title: Text(subCat ?? 'All Subcategories'),
                                  onTap: () => Navigator.pop(context, subCat),
                                  selected: selectedSubCategory == subCat,
                                );
                              }).toList(),
                            );
                          },
                        );

                        setState(() {
                          selectedSubCategory = selected;
                        });
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 6 / 3,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (_, idx) {
                        var idea = filteredList[idx];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      categoryKey == "technology"
                                          ? Icons.memory
                                          : Icons.factory,
                                      color: categoryKey == "technology"
                                          ? Colors.indigo
                                          : Colors.teal,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        idea.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  idea.subCategories[categoryKey.capitalize()]?.join(', ') ??
                                      '',
                                  style: TextStyle(
                                    color: categoryKey == "technology"
                                        ? Colors.indigo
                                        : Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  idea.description,
                                  maxLines: 3, // limit to avoid overflow
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: idea.approved
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    idea.approved ? "Approved" : "Pending",
                                    style: TextStyle(
                                      color: idea.approved
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= SMALL UI HELPERS ===========================
class GlassInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const GlassInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  color: Colors.blueGrey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class GlassCategoryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.45),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: color.withOpacity(0.26)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.blueGrey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            )
          ],
        ),
      ),
    );
  }
}

extension StringCap on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}
