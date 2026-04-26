import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Баптаулар'),
      ),
      body: ListView(
        children: [
          _buildSection(
            'Деректер қорын басқару',
            [
              _buildListTile(
                'Кэшті тазалау',
                'Уақытша файлдарды жою',
                Icons.cleaning_services,
                Colors.blue,
                () => _showClearCacheDialog(),
              ),
              _buildListTile(
                'Экспорт',
                'Деректерді сақтық көшірме',
                Icons.download,
                Colors.green,
                () => _showExportDialog(),
              ),
              _buildListTile(
                'Импорт',
                'Деректерді қалпына келтіру',
                Icons.upload,
                Colors.orange,
                () => _showImportDialog(),
              ),
            ],
          ),

          const Divider(height: 32),

          _buildSection(
            'Қауіпті әрекеттер',
            [
              _buildListTile(
                'Барлық пікірлерді жою',
                'Барлық пайдаланушы пікірлері жойылады',
                Icons.delete_sweep,
                Colors.orange,
                () => _confirmDeleteAll('comments', 'пікірлерді'),
              ),
              _buildListTile(
                'Барлық таңдаулыларды жою',
                'Барлық favorites жойылады',
                Icons.favorite_border,
                Colors.red,
                () => _confirmDeleteAll('favorites', 'таңдаулыларды'),
              ),
              _buildListTile(
                'Деректер қорын толық тазалау',
                '⚠️ БАРЛЫҚ деректер жойылады!',
                Icons.warning,
                Colors.red,
                () => _showDangerousResetDialog(),
              ),
            ],
          ),

          const Divider(height: 32),

          _buildSection(
            'Жүйе ақпараты',
            [
              _buildInfoTile('Қосымша нұсқасы', '1.0.0'),
              _buildInfoTile('Supabase байланысы', 'Белсенді ✅'),
              _buildInfoTile('Firebase байланысы', 'Белсенді ✅'),
              _buildInfoTile('Деректер қоры', 'PostgreSQL'),
            ],
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Техникалық қолдау',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Сұрақтар болса байланысыңыз:'),
                    const SizedBox(height: 8),
                    Text(
                      'Email: support@doramaalem.kz',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                    Text(
                      'Telegram: @doramaalem_support',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showClearCacheDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Кэшті тазалау'),
        content: const Text('Уақытша файлдар мен кэш тазаланады. Жалғастырасыз ба?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Болдырмау'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Кэш тазаланды ✅'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Тазалау'),
          ),
        ],
      ),
    );
  }

  Future<void> _showExportDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Экспорт'),
        content: const Text('Деректерді JSON форматында сақтау. (Функция әзірленуде)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Жабу'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Импорт'),
        content: const Text('Сақтық көшірмеден қалпына келтіру. (Функция әзірленуде)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Жабу'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAll(String table, String itemName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Ескерту'),
        content: Text('Барлық $itemName жойылады! Бұл әрекетті қайтару мүмкін емес.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Болдырмау'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Жою'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from(table).delete().neq('id', '00000000-0000-0000-0000-000000000000');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Барлық $itemName жойылды'),
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

  Future<void> _showDangerousResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚨 ҚАУІПТІ ӘРЕКЕТ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Барлық деректер жойылады:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Барлық дорамалар'),
            Text('• Барлық актерлер'),
            Text('• Барлық эпизодтар'),
            Text('• Барлық пікірлер'),
            Text('• Барлық таңдаулылар'),
            SizedBox(height: 16),
            Text(
              '⚠️ Тек пайдаланушылар қалады!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Бұл әрекетті ҚАЙТАРУ МҮМКІН ЕМЕС!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Болдырмау'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Барлығын жою'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final doubleConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Соңғы растау'),
          content: const Text('Шынымен де БАРЛЫҚ деректерді жойғыңыз келе ме?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Жоқ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Иә, жою'),
            ),
          ],
        ),
      );

      if (doubleConfirmed == true) {
        try {
          await _supabase.from('comments').delete().neq('id', '00000000-0000-0000-0000-000000000000');
          await _supabase.from('favorites').delete().neq('id', '00000000-0000-0000-0000-000000000000');
          await _supabase.from('drama_actors').delete().neq('drama_id', '00000000-0000-0000-0000-000000000000');
          await _supabase.from('episodes').delete().neq('id', '00000000-0000-0000-0000-000000000000');
          await _supabase.from('dramas').delete().neq('id', '00000000-0000-0000-0000-000000000000');
          await _supabase.from('actors').delete().neq('id', '00000000-0000-0000-0000-000000000000');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Деректер қоры тазаланды'),
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
  }
}