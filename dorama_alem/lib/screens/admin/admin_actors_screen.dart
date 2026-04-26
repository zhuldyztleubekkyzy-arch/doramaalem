import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../editor/add_actor_screen.dart';
import '../viewer/actor_detail_screen.dart';

class AdminActorsScreen extends StatefulWidget {
  const AdminActorsScreen({super.key});

  @override
  State<AdminActorsScreen> createState() => _AdminActorsScreenState();
}

class _AdminActorsScreenState extends State<AdminActorsScreen> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _actors = [];
  List<Map<String, dynamic>> _filteredActors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadActors() async {
    try {
      final response = await _supabase
          .from('actors')
          .select()
          .order('name', ascending: true);

      setState(() {
        _actors = List<Map<String, dynamic>>.from(response);
        _filteredActors = _actors;
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

  void _filterActors(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredActors = _actors;
      } else {
        _filteredActors = _actors.where((actor) {
          final name = actor['name']?.toString().toLowerCase() ?? '';
          final country = actor['country']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || country.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _deleteActor(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Актерді жою'),
        content: const Text('Бұл актерді жойғыңыз келе ме? Барлық дорамалардан да алынады.'),
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
        await _supabase.from('actors').delete().eq('id', id);
        _loadActors();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Актер жойылды'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Актерлерді басқару'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActors,
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
                hintText: 'Актер іздеу...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterActors('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterActors,
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Барлығы', _actors.length),
                _buildStatItem('Көрсетілген', _filteredActors.length),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredActors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 80, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Актерлер жоқ'
                                  : 'Іздеу нәтижесі жоқ',
                              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadActors,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredActors.length,
                          itemBuilder: (context, index) {
                            final actor = _filteredActors[index];
                            return _buildActorCard(actor);
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
            MaterialPageRoute(builder: (context) => const AddActorScreen()),
          );
          if (result == true) {
            _loadActors();
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Актер қосу'),
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

  Widget _buildActorCard(Map<String, dynamic> actor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActorDetailScreen(actor: actor),
            ),
          );
        },
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: actor['photo_url'] != null
                ? NetworkImage(actor['photo_url'])
                : null,
            child: actor['photo_url'] == null
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          title: Text(
            actor['name'] ?? 'Аты жоқ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (actor['country'] != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(actor['country']),
                  ],
                ),
              if (actor['birth_date'] != null)
                Row(
                  children: [
                    const Icon(Icons.cake, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(actor['birth_date']),
                  ],
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddActorScreen(actor: actor),
                    ),
                  );
                  if (result == true) {
                    _loadActors();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteActor(actor['id']),
              ),
            ],
          ),
        ),
      ),
    );
  }
}