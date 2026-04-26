import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEpisodeScreen extends StatefulWidget {
  final String dramaId;
  final String dramaTitle;
  final Map<String, dynamic>? episode; // Өңдеу үшін

  const AddEpisodeScreen({
    super.key,
    required this.dramaId,
    required this.dramaTitle,
    this.episode,
  });

  @override
  State<AddEpisodeScreen> createState() => _AddEpisodeScreenState();
}

class _AddEpisodeScreenState extends State<AddEpisodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  final _episodeNumberController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _durationController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.episode != null) {
      _loadEpisodeData();
    }
  }

  void _loadEpisodeData() {
    _episodeNumberController.text = widget.episode!['episode_number']?.toString() ?? '';
    _titleController.text = widget.episode!['title'] ?? '';
    _descriptionController.text = widget.episode!['description'] ?? '';
    _videoUrlController.text = widget.episode!['video_url'] ?? '';
    _durationController.text = widget.episode!['duration']?.toString() ?? '';
    _thumbnailUrlController.text = widget.episode!['thumbnail_url'] ?? '';
  }

  @override
  void dispose() {
    _episodeNumberController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _durationController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveEpisode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final episodeData = {
        'drama_id': widget.dramaId,
        'episode_number': int.parse(_episodeNumberController.text),
        'title': _titleController.text.trim().isEmpty 
            ? null 
            : _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        'video_url': _videoUrlController.text.trim(),
        'duration': _durationController.text.isEmpty 
            ? null 
            : int.parse(_durationController.text),
        'thumbnail_url': _thumbnailUrlController.text.trim().isEmpty 
            ? null 
            : _thumbnailUrlController.text.trim(),
      };

      if (widget.episode == null) {
        // Жаңа эпизод қосу
        await _supabase.from('episodes').insert(episodeData);
      } else {
        // Өңдеу
        await _supabase
            .from('episodes')
            .update(episodeData)
            .eq('id', widget.episode!['id']);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.episode == null 
                ? 'Эпизод сәтті қосылды!' 
                : 'Эпизод сәтті өңделді!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Қате: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text(widget.episode == null ? 'Эпизод қосу' : 'Эпизодты өңдеу'),
            Text(
              widget.dramaTitle,
              style: const TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Эпизод нөмірі
            TextFormField(
              controller: _episodeNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Эпизод нөмірі *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Нөмірді енгізіңіз';
                }
                final number = int.tryParse(value);
                if (number == null || number < 1) {
                  return 'Дұрыс нөмір енгізіңіз';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Атауы
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Атауы (міндетті емес)',
                hintText: 'Бөлім 1: Кездесу',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),

            // Сипаттама
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Сипаттама (міндетті емес)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Видео URL
            TextFormField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'Видео сілтемесі *',
                hintText: 'https://youtube.com/watch?v=...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.video_library),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Видео сілтемесін енгізіңіз';
                }
                if (!value.startsWith('http')) {
                  return 'Дұрыс URL енгізіңіз';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Ұзақтығы (минуттар)
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ұзақтығы (минут)',
                hintText: '60',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
            ),
            const SizedBox(height: 16),

            // Thumbnail URL
            TextFormField(
              controller: _thumbnailUrlController,
              decoration: const InputDecoration(
                labelText: 'Thumbnail сілтемесі (міндетті емес)',
                hintText: 'https://example.com/thumb.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
            ),
            const SizedBox(height: 24),

            // Сақтау батырмасы
            ElevatedButton(
              onPressed: _isLoading ? null : _saveEpisode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.episode == null ? 'Қосу' : 'Сақтау',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}