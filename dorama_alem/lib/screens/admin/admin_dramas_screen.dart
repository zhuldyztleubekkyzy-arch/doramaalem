import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../editor/add_drama_screen.dart';
import '../editor/editor_drama_detail_screen.dart';

class AdminDramasScreen extends StatefulWidget {
  const AdminDramasScreen({super.key});

  @override
  State<AdminDramasScreen> createState() => _AdminDramasScreenState();
}

class _AdminDramasScreenState extends State<AdminDramasScreen> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _dramas = [];
  List<Map<String, dynamic>> _filteredDramas = [];
  bool _isLoading = true;
  String _selectedFilter = 'Барлығы';

  @override
  void initState() {
    super.initState();
    _loadDramas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDramas() async {
    try {
      final response = await _supabase
          .from('dramas')
          .select('*, users(name)')
          .order('created_at', ascending: false);

      setState(() {
        _dramas = List<Map<String, dynamic>>.from(response);
        _filteredDramas = _dramas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    }
  }

  void _filterDramas(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDramas = _dramas;
      } else {
        _filteredDramas = _dramas.where((drama) {
          final title = drama['title']?.toString().toLowerCase() ?? '';
          final genre = drama['genre']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return title.contains(searchLower) || genre.contains(searchLower);
        }).toList();
      }
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Барлығы') {
        _filteredDramas = _dramas;
      } else {
        _filteredDramas = _dramas.where((drama) {
          return drama['genre'] == filter;
        }).toList();
      }
    });
  }

  Future<void> _deleteDrama(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Дораманы жою'),
        content: const Text('Бұл дораманы толықтай жойғыңыз келе ме? Барлық эпизодтар, пікірлер де жойылады.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Болдырмау'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Жою'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('dramas').delete().eq('id', id);
        _loadDramas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Дорама жойылды'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Қате: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final genres = ['Барлығы', 'Romance', 'Comedy', 'Drama', 'Fantasy', 'Action', 'Thriller', 'Historical'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Дорамаларды басқару'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDramas,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Дорама іздеу...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterDramas('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterDramas,
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = genre == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (selected) => _applyFilter(genre),
                    selectedColor: Colors.red,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Барлығы', _dramas.length),
                _buildStatItem('Көрсетілген', _filteredDramas.length),
                _buildStatItem('Жанрлар', genres.length - 1),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDramas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.tv_off, size: 80, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Дорамалар жоқ'
                                  : 'Іздеу нәтижесі жоқ',
                              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDramas,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredDramas.length,
                          itemBuilder: (context, index) {
                            final drama = _filteredDramas[index];
                            return _buildDramaCard(drama);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDramaScreen()),
          );
          if (result == true) {
            _loadDramas();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Дорама қосу'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDramaCard(Map<String, dynamic> drama) {
    final creatorName = drama['users']?['name'] ?? 'Белгісіз';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditorDramaDetailScreen(drama: drama),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: drama['poster_url'] != null
                    ? Image.network(
                        drama['poster_url'],
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 120,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.tv, size: 40),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.tv, size: 40),
                      ),
              ),
              const SizedBox(width: 12),

              // Ақпарат
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drama['title'] ?? 'Аты жоқ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('${drama['genre'] ?? ''} • ${drama['year'] ?? ''}'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${drama['rating'] ?? '0.0'}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Қосқан: $creatorName',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Батырмалар
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddDramaScreen(drama: drama),
                        ),
                      );
                      if (result == true) {
                        _loadDramas();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteDrama(drama['id']),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}