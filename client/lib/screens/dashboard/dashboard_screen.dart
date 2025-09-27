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

class DummyDocument {
  final String name;
  final String type; // 'pitchdeck', 'processed', etc.
  final String content; // For demo, stores text content or summary

  DummyDocument({
    required this.name,
    required this.type,
    required this.content,
  });
}

class DummyReevaluation {
  final int id;
  final int startupId;
  final String reason;
  final DateTime requestedAt;
  final List<DummyDocument> documents;
  final List<String> conversationTranscripts;

  DummyReevaluation({
    required this.id,
    required this.startupId,
    required this.reason,
    required this.requestedAt,
    required this.documents,
    required this.conversationTranscripts,
  });
}

// ======================= DASHBOARD ===========================

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Future<List<Startup>> futureStartups;

  final List<DummyReevaluation> reevaluations = [
    DummyReevaluation(
      id: 1,
      startupId: 1,
      reason: 'Request to update the AI model details.',
      requestedAt: DateTime.now().subtract(const Duration(days: 1)),
      documents: [
        DummyDocument(
          name: "Pitchdeck.pdf",
          type: "pitchdeck",
          content: "Slide 1: Introduction...\nSlide 2: Tech Stack...",
        ),
        DummyDocument(
          name: "Processed Document",
          type: "processed",
          content:
              "SUMMARY: Leveraging neural networks for real-time decision-making. Updated modeling, reduced latency, improved outcomes.",
        ),
      ],
      conversationTranscripts: [
        "User: Please update the risk section.",
        "Reviewer: Risks now cover data privacy.",
      ],
    ),
    // Add more DummyReevaluation entries if needed
  ];

  @override
  void initState() {
    super.initState();
    futureStartups = fetchStartups();
  }

  Future<List<Startup>> fetchStartups() async {
    // 🔑 Replace with your actual backend endpoint
    const String apiUrl = "https://evalora-service-158695644143.asia-south1.run.app/startups";

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
          IconButton(
            icon: const Icon(Icons.track_changes),
            tooltip: 'Track Re-evaluations',
            onPressed: () async {
              final startups = await futureStartups; // fetch from future
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReevaluationListScreen(
                    reevaluations: reevaluations,
                    startups: startups,
                  ),
                ),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final user = ref.watch(authProvider).currentUser;
              if (user == null) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                tooltip: 'Account',
                onSelected: (value) async {
                  if (value == 'profile') {
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
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  } else if (value == 'logout') {
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
        final subs =
            (s.subCategories[cat] ?? s.subCategories[key] ?? []) as List;
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
                                  idea.subCategories[categoryKey.capitalize()]
                                          ?.join(', ') ??
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
                                  maxLines: 3,
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

// Extensions:

extension StringCap on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}

// Reevaluation List Screen

class ReevaluationListScreen extends StatelessWidget {
  final List<DummyReevaluation> reevaluations;
  final List<Startup> startups;

  const ReevaluationListScreen({
    super.key,
    required this.reevaluations,
    required this.startups,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Re-evaluation Requests'),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        itemCount: reevaluations.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, idx) {
          final r = reevaluations[idx];
          final s = startups.firstWhere((st) => st.id == r.startupId,
              orElse: () => Startup(
                    id: '0',
                    name: 'Unknown',
                    description: '',
                    categories: [],
                    subCategories: {},
                    founder: '',
                    founderId: '',
                    score: 0.0,
                    currentStatus: '',
                    approved: false,
                    docsList: {},
                  ));

          return ListTile(
            leading: const Icon(Icons.refresh, color: Colors.indigo),
            title: Text(s.name),
            subtitle:
                Text('Reason: ${r.reason}\nDate: ${r.requestedAt.toLocal()}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReevaluationDetailScreen(reevaluation: r),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Reevaluation Detail Screen

class ReevaluationDetailScreen extends StatelessWidget {
  final DummyReevaluation reevaluation;

  const ReevaluationDetailScreen({super.key, required this.reevaluation});

  @override
  Widget build(BuildContext context) {
    final processedDoc = reevaluation.documents.firstWhere(
      (d) => d.type == "processed",
      orElse: () => DummyDocument(
          name: "Processed Document",
          type: "processed",
          content: "No summary available."),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Re-evaluation Details'),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Reason: ${reevaluation.reason}",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Requested At: ${reevaluation.requestedAt.toLocal()}'),
          const SizedBox(height: 16),
          const Text('Uploaded Documents:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...reevaluation.documents
              .where((doc) => doc.type != "processed")
              .map((doc) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(doc.type == "pitchdeck"
                          ? Icons.picture_as_pdf
                          : Icons.description),
                      title: Text(doc.name),
                      subtitle: Text(doc.content.length > 40
                          ? doc.content.substring(0, 40) + '...'
                          : doc.content),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DocumentViewerScreen(document: doc),
                          ),
                        );
                      },
                    ),
                  )),
          const Divider(),
          const Text('Processed Document:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.summarize, color: Colors.indigo),
              title: const Text('View Summary'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ProcessedDocumentScreen(summary: processedDoc.content),
                  ),
                );
              },
              subtitle: Text(
                processedDoc.content.length > 48
                    ? processedDoc.content.substring(0, 48) + '...'
                    : processedDoc.content,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Conversation Transcripts:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...reevaluation.conversationTranscripts.map((txt) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(txt),
                ),
              )),
          if (reevaluation.conversationTranscripts.isEmpty)
            const Text('No transcripts available.',
                style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// Document Viewer Screen

class DocumentViewerScreen extends StatelessWidget {
  final DummyDocument document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.name),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SelectableText(
          document.content,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

// Processed Document Screen

class ProcessedDocumentScreen extends StatelessWidget {
  final String summary;

  const ProcessedDocumentScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Processed Document"),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SelectableText(
          summary,
          style: const TextStyle(fontSize: 16, height: 1.45),
        ),
      ),
    );
  }
}
