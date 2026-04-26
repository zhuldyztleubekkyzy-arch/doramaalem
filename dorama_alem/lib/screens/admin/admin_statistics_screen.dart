import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, int> _stats = {};
  List<Map<String, dynamic>> _topDramas = [];
  List<Map<String, dynamic>> _recentComments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
  try {
    final users = await _supabase.from('users').select('id');
    final dramas = await _supabase.from('dramas').select('id');
    final actors = await _supabase.from('actors').select('id');
    final episodes = await _supabase.from('episodes').select('id');
    final comments = await _supabase.from('comments').select('id');
    final favorites = await _supabase.from('favorites').select('id');

    final admins = await _supabase.from('users').select('id').eq('role', 'admin');
    final editors = await _supabase.from('users').select('id').eq('role', 'editor');
    final viewers = await _supabase.from('users').select('id').eq('role', 'viewer');

    

    final topDramasResponse = await _supabase
        .from('dramas')
        .select()
        .order('rating', ascending: false)
        .limit(5);

    final commentsResponse = await _supabase
        .from('comments')
        .select('*, users(name), dramas(title)')
        .order('created_at', ascending: false)
        .limit(10);
        
    setState(() {
      _stats = {
        'users': users.length,
        'dramas': dramas.length,
        'actors': actors.length,
        'episodes': episodes.length,
        'comments': comments.length,
        'favorites': favorites.length,
        'admins': admins.length,
        'editors': editors.length,
        'viewers': viewers.length,
      };
      _topDramas = List<Map<String, dynamic>>.from(topDramasResponse);
      _recentComments = List<Map<String, dynamic>>.from(commentsResponse);
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
      appBar: AppBar(
        title: const Text('Статистика'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadStatistics();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Жалпы статистика
                  const Text(
                    'Жалпы көрсеткіштер',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard('Пайдаланушылар', _stats['users'] ?? 0, Icons.people, Colors.blue),
                      _buildStatCard('Дорамалар', _stats['dramas'] ?? 0, Icons.tv, Colors.purple),
                      _buildStatCard('Актерлер', _stats['actors'] ?? 0, Icons.star, Colors.orange),
                      _buildStatCard('Эпизодтар', _stats['episodes'] ?? 0, Icons.video_library, Colors.green),
                      _buildStatCard('Пікірлер', _stats['comments'] ?? 0, Icons.comment, Colors.pink),
                      _buildStatCard('Таңдаулы', _stats['favorites'] ?? 0, Icons.favorite, Colors.red),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Рөлдер бойынша
                  const Text(
                    'Рөлдер бойынша',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Админдер', _stats['admins'] ?? 0, Icons.admin_panel_settings, Colors.red),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Редакторлар', _stats['editors'] ?? 0, Icons.edit, Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Қарап шығушылар', _stats['viewers'] ?? 0, Icons.visibility, Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Топ дорамалар
                  const Text(
                    'Топ 5 дорамалар',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  ..._topDramas.map((drama) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Text(
                          drama['rating']?.toString() ?? '0',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(drama['title'] ?? ''),
                      subtitle: Text('${drama['genre']} • ${drama['year']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            drama['rating']?.toString() ?? '0',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 32),

                  // Соңғы пікірлер
                  const Text(
                    'Соңғы пікірлер',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  ..._recentComments.map((comment) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          comment['users']['name'][0].toUpperCase(),
                        ),
                      ),
                      title: Text(comment['dramas']['title'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment['content'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment['users']['name'] ?? 'Белгісіз',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: comment['rating'] != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(comment['rating'].toString()),
                              ],
                            )
                          : null,
                    ),
                  )),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}