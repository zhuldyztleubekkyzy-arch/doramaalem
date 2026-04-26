import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import 'add_drama_screen.dart';
import 'add_actor_screen.dart';
import 'editor_drama_detail_screen.dart';
import '../viewer/actors_screen.dart';

class EditorHome extends StatefulWidget {
  final String userName;
  
  const EditorHome({super.key, required this.userName});

  @override
  State<EditorHome> createState() => _EditorHomeState();
}

class _EditorHomeState extends State<EditorHome> {
  final _authService = AuthService();
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _dramas = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDramas();
  }

  Future<void> _loadDramas() async {
    try {
      final response = await _supabase
          .from('dramas')
          .select()
          .order('created_at', ascending: false);
      
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
      appBar: AppBar(
        title: const Text('Dorama_Alem - Редактор'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
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
              backgroundColor: Colors.purple,
            )
          : _selectedIndex == 1
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddActorScreen()),
                    );
                    if (result == true) {
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Актер қосу'),
                  backgroundColor: Colors.blue,
                )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'Дорамалар',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Актерлер',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade800],
              ),
            ),
            accountName: Text(widget.userName),
            accountEmail: Text(_authService.currentUser?.email ?? ''),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.edit, size: 40, color: Colors.purple),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('Дорама қосу'),
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddDramaScreen()),
              );
              if (result == true) {
                _loadDramas();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Актер қосу'),
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddActorScreen()),
              );
              if (result == true) {
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Менің қосқандарым'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 0);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Барлық актерлер'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActorsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Баптаулар'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Шығу'),
            onTap: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildDramasList();
    } else if (_selectedIndex == 1) {
      return _buildActorsList();
    } else {
      return _buildProfile();
    }
  }

  Widget _buildDramasList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dramas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tv_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Әзірше дорамалар жоқ',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Дорама қосу
              },
              icon: const Icon(Icons.add),
              label: const Text('Бірінші дораманы қосу'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDramas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dramas.length,
        itemBuilder: (context, index) {
          final drama = _dramas[index];
          return _buildDramaCard(drama);
        },
      ),
    );
  }

  Widget _buildDramaCard(Map<String, dynamic> drama) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: drama['poster_url'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  drama['poster_url'],
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.tv),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                color: Colors.grey.shade300,
                child: const Icon(Icons.tv),
              ),
        title: Text(drama['title'] ?? 'Аты жоқ'),
        subtitle: Text('${drama['genre'] ?? ''} • ${drama['year'] ?? ''}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditorDramaDetailScreen(drama: drama),
            ),
          );
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

  Future<void> _deleteDrama(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Жою'),
        content: const Text('Бұл дораманы жойғыңыз келе ме?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Жоқ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Иә', style: TextStyle(color: Colors.red)),
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
            const SnackBar(content: Text('Дорама жойылды')),
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

  Widget _buildActorsList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 80, color: Colors.purple.shade300),
          const SizedBox(height: 16),
          const Text(
            'Актерлер басқармасы',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Актерлерді қосыңыз және өңдеңіз',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddActorScreen()),
                  );
                  if (result == true) {
                  }
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Актер қосу'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ActorsScreen()),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('Тізімді көру'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.purple,
              child: Icon(Icons.edit, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              widget.userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _authService.currentUser?.email ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: const Text('Редактор'),
              backgroundColor: Colors.blue.shade100,
              avatar: const Icon(Icons.edit, size: 18),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Редактор мүмкіндіктері:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionItem(
                      Icons.add_box,
                      'Дорама қосу',
                    ),
                    _buildPermissionItem(
                      Icons.edit,
                      'Дорама өңдеу',
                    ),
                    _buildPermissionItem(
                      Icons.person_add,
                      'Актер қосу',
                    ),
                    _buildPermissionItem(
                      Icons.delete,
                      'Өз қосқандарын жою',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await _authService.signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Шығу'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}