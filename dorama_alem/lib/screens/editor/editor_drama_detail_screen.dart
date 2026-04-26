import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_episode_screen.dart';
import 'manage_drama_actors_screen.dart';

class EditorDramaDetailScreen extends StatefulWidget {
  final Map<String, dynamic> drama;

  const EditorDramaDetailScreen({super.key, required this.drama});

  @override
  State<EditorDramaDetailScreen> createState() => _EditorDramaDetailScreenState();
}

class _EditorDramaDetailScreenState extends State<EditorDramaDetailScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _episodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    try {
      final response = await _supabase
          .from('episodes')
          .select()
          .eq('drama_id', widget.drama['id'])
          .order('episode_number', ascending: true);

      setState(() {
        _episodes = List<Map<String, dynamic>>.from(response);
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

  Future<void> _deleteEpisode(String episodeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Эпизодты жою'),
        content: const Text('Бұл эпизодты жойғыңыз келе ме?'),
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
        await _supabase.from('episodes').delete().eq('id', episodeId);
        _loadEpisodes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Эпизод жойылды')),
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
        title: Text(widget.drama['title'] ?? ''),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Дорама ақпараты
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.drama['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.drama['genre']} • ${widget.drama['year']} • ${widget.drama['country']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Рейтинг: ${widget.drama['rating'] ?? '0.0'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Эпизодтар тізімі
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Эпизодтар (${_episodes.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManageDramaActorsScreen(
                                    dramaId: widget.drama['id'],
                                    dramaTitle: widget.drama['title'],
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.people),
                            label: const Text('Актерлер'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEpisodeScreen(
                                    dramaId: widget.drama['id'],
                                    dramaTitle: widget.drama['title'],
                                  ),
                                ),
                              );
                              if (result == true) {
                                _loadEpisodes();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Эпизод'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Эпизодтар
                Expanded(
                  child: _episodes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.video_library_outlined,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Әзірше эпизодтар жоқ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _episodes.length,
                          itemBuilder: (context, index) {
                            final episode = _episodes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    episode['episode_number']?.toString() ?? '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  episode['title'] ?? 'Бөлім ${episode['episode_number']}',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (episode['duration'] != null)
                                      Text('${episode['duration']} минут'),
                                    Text(
                                      episode['video_url'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
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
                                            builder: (context) => AddEpisodeScreen(
                                              dramaId: widget.drama['id'],
                                              dramaTitle: widget.drama['title'],
                                              episode: episode,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          _loadEpisodes();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteEpisode(episode['id']),
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
    );
  }
}