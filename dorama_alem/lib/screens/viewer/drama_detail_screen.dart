import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/auth_service.dart';
import 'video_player_screen.dart';

class DramaDetailScreen extends StatefulWidget {
  final Map<String, dynamic> drama;

  const DramaDetailScreen({super.key, required this.drama});

  @override
  State<DramaDetailScreen> createState() => _DramaDetailScreenState();
}

class _DramaDetailScreenState extends State<DramaDetailScreen> {
  final _supabase = Supabase.instance.client;
  final _authService = AuthService();
  List<Map<String, dynamic>> _episodes = [];
  List<Map<String, dynamic>> _actors = [];
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isFavorite = false;
  String? _favoriteId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    try {
      final userData = await _authService.getUserData();
      if (userData == null) return;

      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userData['id'])
          .eq('drama_id', widget.drama['id'])
          .maybeSingle();

      if (response != null) {
        setState(() {
          _isFavorite = true;
          _favoriteId = response['id'];
        });
      }
    } catch (e) {
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final userData = await _authService.getUserData();
      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Кіру қажет')),
        );
        return;
      }

      if (_isFavorite && _favoriteId != null) {
        await _supabase.from('favorites').delete().eq('id', _favoriteId!);
        setState(() {
          _isFavorite = false;
          _favoriteId = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Таңдаулыдан алынды')),
          );
        }
      } else {
        // Қосу
        final response = await _supabase.from('favorites').insert({
          'user_id': userData['id'],
          'drama_id': widget.drama['id'],
        }).select().single();
        
        setState(() {
          _isFavorite = true;
          _favoriteId = response['id'];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Таңдаулыға қосылды')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final episodesResponse = await _supabase
          .from('episodes')
          .select()
          .eq('drama_id', widget.drama['id'])
          .order('episode_number', ascending: true);

      final actorsResponse = await _supabase
          .from('drama_actors')
          .select('*, actors(*)')
          .eq('drama_id', widget.drama['id']);

      final commentsResponse = await _supabase
          .from('comments')
          .select('*, users(name)')
          .eq('drama_id', widget.drama['id'])
          .order('created_at', ascending: false)
          .limit(10);

      setState(() {
        _episodes = List<Map<String, dynamic>>.from(episodesResponse);
        _actors = List<Map<String, dynamic>>.from(actorsResponse);
        _comments = List<Map<String, dynamic>>.from(commentsResponse);
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
                widget.drama['title'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 10),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.drama['poster_url'] != null
                      ? Image.network(
                          widget.drama['poster_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.tv, size: 100, color: Colors.white),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.tv, size: 100, color: Colors.white),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                color: Colors.red,
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Share.share(
                    'Бұл дораманы қараңыз: ${widget.drama['title']}\n\n'
                    'Жанры: ${widget.drama['genre']}\n'
                    'Рейтинг: ${widget.drama['rating']}\n\n'
                    'Dorama_Alem қосымшасында қараңыз!',
                  );
                },
              ),
            ],
          ),

          // Негізгі контент
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(),

                      const Divider(height: 32),

                      _buildEpisodesSection(),

                      const Divider(height: 32),

                      _buildActorsSection(),

                      const Divider(height: 32),

                      _buildCommentsSection(),

                      const SizedBox(height: 100),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      widget.drama['rating']?.toString() ?? '0.0',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Chip(
                label: Text(widget.drama['year']?.toString() ?? ''),
                backgroundColor: Colors.purple.shade100,
              ),
              const SizedBox(width: 8),
              if (widget.drama['country'] != null)
                Chip(
                  label: Text(widget.drama['country']),
                  backgroundColor: Colors.blue.shade100,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Жанр
          if (widget.drama['genre'] != null) ...[
            const Text(
              'Жанры:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(widget.drama['genre']),
                  backgroundColor: Colors.purple.shade100,
                  avatar: const Icon(Icons.movie, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Сипаттама
          const Text(
            'Сипаттама:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.drama['description'] ?? 'Сипаттама жоқ',
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Эпизодтар',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_episodes.isNotEmpty)
                Text(
                  '${_episodes.length} бөлім',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _episodes.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Эпизодтар әзірше қосылмаған',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _episodes.length,
                itemBuilder: (context, index) {
                  final episode = _episodes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Text(
                          episode['episode_number']?.toString() ?? '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(episode['title'] ?? 'Бөлім ${episode['episode_number']}'),
                      subtitle: episode['duration'] != null
                          ? Text('${episode['duration']} минут')
                          : null,
                      trailing: const Icon(Icons.play_circle_fill, color: Colors.purple, size: 40),
                      onTap: () {
                        if (episode['video_url'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                videoUrl: episode['video_url'],
                                title: episode['title'] ?? 'Бөлім ${episode['episode_number']}',
                                dramaTitle: widget.drama['title'],
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Видео сілтемесі жоқ')),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildActorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Актерлер',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _actors.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Актерлер әзірше қосылмаған',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            : SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _actors.length,
                  itemBuilder: (context, index) {
                    final actor = _actors[index]['actors'];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: actor['photo_url'] != null
                                ? NetworkImage(actor['photo_url'])
                                : null,
                            child: actor['photo_url'] == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            actor['name'] ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Пікірлер',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _showAddCommentDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('Қосу'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _comments.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Пікірлер әзірше жоқ',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.purple.shade100,
                                child: Text(
                                  comment['users']['name'][0].toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment['users']['name'] ?? 'Пайдаланушы',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    if (comment['rating'] != null)
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 14, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            comment['rating'].toString(),
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(comment['content'] ?? ''),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  void _showAddCommentDialog() {
    final commentController = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Пікір қосу'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Пікіріңізді жазыңыз...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Рейтинг:'),
                  Row(
                    children: List.generate(10, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Болдырмау'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пікір жазыңыз')),
                  );
                  return;
                }

                try {
                  final userData = await _authService.getUserData();
                  if (userData == null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Кіру қажет')),
                    );
                    return;
                  }

                  await _supabase.from('comments').insert({
                    'drama_id': widget.drama['id'],
                    'user_id': userData['id'],
                    'content': commentController.text,
                    'rating': rating,
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пікір қосылды!')),
                  );
                  _loadData();
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Қате: $e')),
                  );
                }
              },
              child: const Text('Жіберу'),
            ),
          ],
        ),
      ),
    );
  }
}