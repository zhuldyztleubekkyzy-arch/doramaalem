import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'drama_detail_screen.dart';

class ActorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> actor;

  const ActorDetailScreen({super.key, required this.actor});

  @override
  State<ActorDetailScreen> createState() => _ActorDetailScreenState();
}

class _ActorDetailScreenState extends State<ActorDetailScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _dramas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDramas();
  }

  Future<void> _loadDramas() async {
    try {
      final response = await _supabase
          .from('drama_actors')
          .select('*, dramas(*)')
          .eq('actor_id', widget.actor['id']);

      setState(() {
        _dramas = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.actor['name'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.actor['photo_url'] != null
                      ? Image.network(
                          widget.actor['photo_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.person, size: 100, color: Colors.white),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.person, size: 100, color: Colors.white),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Жалпы ақпарат
                  if (widget.actor['country'] != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          widget.actor['country'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (widget.actor['birth_date'] != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.cake, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          widget.actor['birth_date'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Биография
                  if (widget.actor['bio'] != null) ...[
                    const Text(
                      'Биография:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.actor['bio'],
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Дорамалар
                  const Text(
                    'Дорамалар:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _dramas.isEmpty
                          ? const Text('Әзірше дорамалар жоқ')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _dramas.length,
                              itemBuilder: (context, index) {
                                final drama = _dramas[index]['dramas'];
                                final role = _dramas[index]['role_name'];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: drama['poster_url'] != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              drama['poster_url'],
                                              width: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Container(
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.tv),
                                          ),
                                    title: Text(drama['title'] ?? ''),
                                    subtitle: role != null ? Text('Рөлі: $role') : null,
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DramaDetailScreen(drama: drama),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}