import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageDramaActorsScreen extends StatefulWidget {
  final String dramaId;
  final String dramaTitle;

  const ManageDramaActorsScreen({
    super.key,
    required this.dramaId,
    required this.dramaTitle,
  });

  @override
  State<ManageDramaActorsScreen> createState() => _ManageDramaActorsScreenState();
}

class _ManageDramaActorsScreenState extends State<ManageDramaActorsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _allActors = [];
  List<Map<String, dynamic>> _selectedActors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Барлық актерлерді жүктеу
      final actorsResponse = await _supabase
          .from('actors')
          .select()
          .order('name', ascending: true);

      // Дораманың актерлерін жүктеу
      final dramaActorsResponse = await _supabase
          .from('drama_actors')
          .select('*, actors(*)')
          .eq('drama_id', widget.dramaId);

      setState(() {
        _allActors = List<Map<String, dynamic>>.from(actorsResponse);
        _selectedActors = List<Map<String, dynamic>>.from(dramaActorsResponse);
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

  bool _isActorSelected(String actorId) {
    return _selectedActors.any((item) => item['actor_id'] == actorId);
  }

  Future<void> _addActor(String actorId) async {
    // Рөл атын сұрау
    final roleController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Рөл атын енгізіңіз'),
        content: TextField(
          controller: roleController,
          decoration: const InputDecoration(
            hintText: 'Мысалы: Басты рөл, Қосымша рөл',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Болдырмау'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Қосу'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _supabase.from('drama_actors').insert({
          'drama_id': widget.dramaId,
          'actor_id': actorId,
          'role_name': roleController.text.trim().isEmpty 
              ? null 
              : roleController.text.trim(),
        });

        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Актер қосылды'),
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

  Future<void> _removeActor(String actorId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Актерді жою'),
        content: const Text('Бұл актерді дорамадан жойғыңыз келе ме?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Жоқ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Иә'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase
            .from('drama_actors')
            .delete()
            .eq('drama_id', widget.dramaId)
            .eq('actor_id', actorId);

        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Актер жойылды')),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Актерлерді басқару'),
            Text(
              widget.dramaTitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Таңдалған актерлер
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Таңдалған актерлер (${_selectedActors.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _selectedActors.isEmpty
                          ? const Text(
                              'Әзірше актерлер қосылмаған',
                              style: TextStyle(color: Colors.grey),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedActors.map((item) {
                                final actor = item['actors'];
                                return Chip(
                                  avatar: CircleAvatar(
                                    backgroundImage: actor['photo_url'] != null
                                        ? NetworkImage(actor['photo_url'])
                                        : null,
                                    child: actor['photo_url'] == null
                                        ? const Icon(Icons.person, size: 20)
                                        : null,
                                  ),
                                  label: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(actor['name'] ?? ''),
                                      if (item['role_name'] != null)
                                        Text(
                                          item['role_name'],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 20),
                                  onDeleted: () => _removeActor(actor['id']),
                                  backgroundColor: Colors.blue.shade100,
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.list),
                      const SizedBox(width: 8),
                      const Text(
                        'Барлық актерлер',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _allActors.isEmpty
                      ? const Center(
                          child: Text('Актерлер табылмады'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _allActors.length,
                          itemBuilder: (context, index) {
                            final actor = _allActors[index];
                            final isSelected = _isActorSelected(actor['id']);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: actor['photo_url'] != null
                                      ? NetworkImage(actor['photo_url'])
                                      : null,
                                  child: actor['photo_url'] == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(actor['name'] ?? ''),
                                subtitle: actor['country'] != null
                                    ? Text(actor['country'])
                                    : null,
                                trailing: isSelected
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                        onPressed: () => _removeActor(actor['id']),
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _addActor(actor['id']),
                                      ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}