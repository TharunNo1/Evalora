import 'dart:ui';
import '../upload/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/screens/session/session_list_screen.dart';
import 'package:client/screens/auth/auth_provider.dart';
import '../auth/sign_in_screen.dart';
import '../re_evaluation/re_evaluation_screen.dart';

// Dummy models for startups, reevaluations, and documents

class DummyStartup {
  final int id;
  final String title;
  final List<String> categories; // e.g. ['technology', 'industry']
  final Map<String, List<String>> subCategories;
  // key = category, value = list of subcategories for that category
  final bool approved;
  final String description;

  DummyStartup({
    required this.id,
    required this.title,
    required this.categories,
    required this.subCategories,
    required this.approved,
    required this.description,
  });
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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Example startups with categories and subcategories
  final List<DummyStartup> startups = [
    DummyStartup(
      id: 1,
      title: 'NeuroLink AI',
      categories: ['technology'],
      subCategories: {
        'technology': ['AI', 'Machine Learning'],
      },
      approved: true,
      description:
          'Developing next-gen neural network models for real-time decision making in healthcare and robotics.',
    ),
    DummyStartup(
      id: 2,
      title: 'EcoEnergy Solutions',
      categories: ['industry'],
      subCategories: {
        'industry': ['Manufacturing', 'Clean Energy'],
      },
      approved: false,
      description:
          'Building modular clean-energy units to reduce carbon footprint in large-scale manufacturing plants.',
    ),
    DummyStartup(
      id: 3,
      title: 'SmartHealth Tracker',
      categories: ['technology', 'industry'],
      subCategories: {
        'technology': ['IoT', 'Wearables'],
        'industry': ['Healthcare'],
      },
      approved: true,
      description:
          'Wearable IoT device that continuously monitors vital signs and provides AI-driven health insights.',
    ),
    DummyStartup(
      id: 4,
      title: 'AgriTech Innovations',
      categories: ['industry'],
      subCategories: {
        'industry': ['Retail', 'Agriculture'],
      },
      approved: false,
      description:
          'Digitizing farm-to-market supply chains with predictive analytics to cut food wastage.',
    ),
    DummyStartup(
      id: 5,
      title: 'FinMate App',
      categories: ['technology'],
      subCategories: {
        'technology': ['Blockchain', 'FinTech'],
      },
      approved: true,
      description:
          'A blockchain-powered personal finance app enabling secure peer-to-peer micro-investments.',
    ),
    DummyStartup(
      id: 6,
      title: 'CleanWater Tech',
      categories: ['industry'],
      subCategories: {
        'industry': ['Healthcare', 'Sustainability'],
      },
      approved: false,
      description:
          'Portable filtration units that deliver safe drinking water using solar-powered nano-filters.',
    ),
    DummyStartup(
      id: 7,
      title: 'EduLearn Platform',
      categories: ['technology'],
      subCategories: {
        'technology': ['VR/AR', 'EdTech'],
      },
      approved: true,
      description:
          'Immersive VR/AR classrooms bringing interactive STEM education to remote schools worldwide.',
    ),
    DummyStartup(
      id: 8,
      title: 'GreenLogistics',
      categories: ['industry'],
      subCategories: {
        'industry': ['Logistics', 'Sustainability'],
      },
      approved: false,
      description:
          'AI-optimized delivery routing platform to reduce fuel consumption and logistics costs.',
    ),
    DummyStartup(
      id: 9,
      title: 'AI-Powered Chatbot',
      categories: ['technology'],
      subCategories: {
        'technology': ['AI', 'Conversational'],
      },
      approved: true,
      description:
          'Conversational AI assistant that provides multilingual customer support across digital channels.',
    ),
    DummyStartup(
      id: 10,
      title: 'Renewable Materials Co.',
      categories: ['industry'],
      subCategories: {
        'industry': ['Manufacturing', 'Eco Materials'],
      },
      approved: false,
      description:
          'Creating biodegradable composite materials to replace single-use plastics in consumer goods.',
    ),
  ];

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
  Widget build(BuildContext context) {
    final totalIdeas = startups.length.toString();
    final approvedIdeas = startups.where((s) => s.approved).length.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32, // adjust as needed
            ),
            const SizedBox(width: 12),
            const Text('Evalora - Dashboard'),
          ],
        ),
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
          IconButton(
            icon: const Icon(Icons.track_changes),
            tooltip: 'Track Re-evaluations',
            onPressed: () {
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            child: const Text('Close'),
                          ),
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
                        backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                        child: user.photoURL == null ? const Icon(Icons.person) : null,
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
                      backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                      child: user.photoURL == null ? const Icon(Icons.person) : null,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Left side - Founder image
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Image.asset(
                  'assets/founder.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 16),
                Text('Founder', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Center content
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
                      const SizedBox(height: 60),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 32),
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
          ),
          // Right side - Investor image
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Image.asset(
                  'assets/investor.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 16),
                Text('Investor', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ReevaluationDialog.show(context),
        label: const Text('Request Re-evaluation'),
        icon: const Icon(Icons.refresh),
        backgroundColor: Colors.blueGrey.shade900, // Button background color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

  final Map<String, List<String>> subCategoriesMap = {
    "technology": ["AI", "Blockchain", "Cloud", "VR/AR", "IoT"],
    "industry": [
      "Manufacturing",
      "Retail",
      "Healthcare",
      "Finance",
      "Logistics"
    ]
  };

  @override
  Widget build(BuildContext context) {
    final String categoryKey = widget.category.toLowerCase();
    final List<String> subCategories = subCategoriesMap[categoryKey] ?? [];

    String selectedCategory = categoryKey;
    String? selectedSub = selectedSubCategory;

    final filteredList = widget.startups.where((startup) {
      if (!startup.categories.contains(selectedCategory)) return false;
      final subs = startup.subCategories[selectedCategory] ?? [];
      if (selectedSub == null || selectedSub.isEmpty) return true;
      return subs.contains(selectedSub);
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
                              borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
                          builder: (context) {
                            final List<String?> options = [null, ...subCategories];
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                        idea.title,
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
                                  idea.subCategories[categoryKey]?.join(', ') ?? '',
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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


// Extensions:

extension StringCap on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}

// Reevaluation List Screen

class ReevaluationListScreen extends StatelessWidget {
  final List<DummyReevaluation> reevaluations;
  final List<DummyStartup> startups;

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
          final s = startups.firstWhere(
              (st) => st.id == r.startupId,
              orElse: () => DummyStartup(
                    id: 0,
                    title: 'Unknown',
                    categories: [],
                    subCategories: {},
                    approved: false,
                    description: '',
                  ));
          return ListTile(
            leading: const Icon(Icons.refresh, color: Colors.indigo),
            title: Text(s.title),
            subtitle: Text('Reason: ${r.reason}\nDate: ${r.requestedAt.toLocal()}'),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Requested At: ${reevaluation.requestedAt.toLocal()}'),
          const SizedBox(height: 16),
          const Text('Uploaded Documents:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...reevaluation.documents
              .where((doc) => doc.type != "processed")
              .map((doc) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading:
                          Icon(doc.type == "pitchdeck" ? Icons.picture_as_pdf : Icons.description),
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
          const Text('Processed Document:', style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.summarize, color: Colors.indigo),
              title: const Text('View Summary'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProcessedDocumentScreen(summary: processedDoc.content),
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
          const Text('Conversation Transcripts:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...reevaluation.conversationTranscripts.map((txt) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(txt),
                ),
              )),
          if (reevaluation.conversationTranscripts.isEmpty)
            const Text('No transcripts available.', style: TextStyle(color: Colors.grey)),
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
