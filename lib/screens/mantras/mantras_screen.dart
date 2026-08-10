import 'package:flutter/material.dart';

import '../../models/mantra_model.dart';
import '../../services/mantra_service.dart';
import 'widgets/mantra_list_tile.dart';

class MantrasScreen extends StatefulWidget {
  const MantrasScreen({super.key});

  @override
  State<MantrasScreen> createState() => _MantrasScreenState();
}

class _MantrasScreenState extends State<MantrasScreen>
    with SingleTickerProviderStateMixin {
  final MantraService _mantraService = MantraService();
  late TabController _tabController;

  List<Mantra> _mantras = [];
  Map<String, bool> _recitedToday = {};
  int _todayCount = 0;
  bool _loading = true;
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadMantras();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      _selectedCategory =
          _tabController.index == 0 ? "Mantra" : "Pooja";
    });
  }

  Future<void> _loadMantras() async {
    final mantras = await _mantraService.getMantras();

    final recitedMap = <String, bool>{};
    for (final mantra in mantras) {
      recitedMap[mantra.id] = await _mantraService.hasRecitedToday(mantra.id);
    }

    final todayCount = await _mantraService.getTodayRecitationCount();

    if (!mounted) return;
    setState(() {
      _mantras = mantras;
      _recitedToday = recitedMap;
      _todayCount = todayCount;
      _loading = false;
    });
  }

  Future<void> _markAsRecited(String mantraId) async {
    await _mantraService.markAsRecited(mantraId);

    final todayCount = await _mantraService.getTodayRecitationCount();

    if (!mounted) return;
    setState(() {
      _recitedToday[mantraId] = true;
      _todayCount = todayCount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mantra marked as recited ✨'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<Mantra> get _filteredMantras {
    if (_selectedCategory == "All") return _mantras;
    return _mantras
        .where((mantra) => mantra.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _filteredMantras;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F2),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMantras,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFFFDF8F2),
                elevation: 0,
                title: const Text(
                  'Divine Mantras',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1810),
                  ),
                ),
                centerTitle: true,
              ),
            ],
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Progress card
                Card(
                  color: const Color(0xFFFFF5E6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s Progress',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B6F47),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_todayCount/${_mantras.length} recited',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4A574),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Section header
                const Text(
                  'Mantras & Poojas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B6F47),
                  ),
                ),
                const SizedBox(height: 12),

                // Tabs
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.deepOrange,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.deepOrange,
                    tabs: const [
                      Tab(text: 'Mantras'),
                      Tab(text: 'Puja'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // List items
                ...filtered.map((mantra) {
                  final isRecited = _recitedToday[mantra.id] ?? false;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MantraListTile(
                      mantra: mantra,
                      isRecited: isRecited,
                      onAddTap: () => _markAsRecited(mantra.id),
                      onShareTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Shared ✨'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
