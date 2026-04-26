import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

class AddDramaScreen extends StatefulWidget {
  final Map<String, dynamic>? drama; // Өңдеу үшін

  const AddDramaScreen({super.key, this.drama});

  @override
  State<AddDramaScreen> createState() => _AddDramaScreenState();
}

class _AddDramaScreenState extends State<AddDramaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  final _authService = AuthService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _ratingController = TextEditingController();

  String _selectedGenre = 'Махаббат';
  String _selectedCountry = 'Оңтүстік Корея';
  bool _isLoading = false;

  final List<String> _genres = [
    'Махаббат',
    'Комедия',
    'Драма',
    'Фантастикалық',
    'Экшен',
    'Трагедия',
    'Тарихи',
    'Мистикалық',
  ];

  final List<String> _countries = [
    'Оңтүстік Корея',
    'Қытай',
    'Жапония',
    'Тайланд',
    'Тайвань',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.drama != null) {
      _loadDramaData();
    }
  }

  void _loadDramaData() {
    _titleController.text = widget.drama!['title'] ?? '';
    _descriptionController.text = widget.drama!['description'] ?? '';
    _yearController.text = widget.drama!['year']?.toString() ?? '';
    _posterUrlController.text = widget.drama!['poster_url'] ?? '';
    _ratingController.text = widget.drama!['rating']?.toString() ?? '';
    _selectedGenre = widget.drama!['genre'] ?? 'Махаббат';
    _selectedCountry = widget.drama!['country'] ?? 'Оңтүстік Корея';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _posterUrlController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _saveDrama() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userData = await _authService.getUserData();
      if (userData == null) {
        throw Exception('Пайдаланушы деректері табылмады');
      }

      final dramaData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'genre': _selectedGenre,
        'year': int.parse(_yearController.text),
        'country': _selectedCountry,
        'poster_url': _posterUrlController.text.trim().isEmpty 
            ? null 
            : _posterUrlController.text.trim(),
        'rating': _ratingController.text.isEmpty 
            ? 0 
            : double.parse(_ratingController.text),
      };

      if (widget.drama == null) {
        dramaData['created_by'] = userData['id'];
        await _supabase.from('dramas').insert(dramaData);
      } else {
        await _supabase
            .from('dramas')
            .update(dramaData)
            .eq('id', widget.drama!['id']);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.drama == null 
                ? 'Дорама сәтті қосылды!' 
                : 'Дорама сәтті өңделді!'),
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
        title: Text(widget.drama == null ? 'Дорама қосу' : 'Дораманы өңдеу'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Атауы
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Атауы *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Атауын енгізіңіз';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Сипаттама
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Сипаттама *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Сипаттаманы енгізіңіз';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Жанр
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              decoration: const InputDecoration(
                labelText: 'Жанры *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _genres.map((genre) {
                return DropdownMenuItem(
                  value: genre,
                  child: Text(genre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedGenre = value!);
              },
            ),
            const SizedBox(height: 16),

            // Жыл және ел
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Жылы *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Жылын енгізіңіз';
                      }
                      final year = int.tryParse(value);
                      if (year == null || year < 1900 || year > 2100) {
                        return 'Дұрыс жыл енгізіңіз';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    decoration: const InputDecoration(
                      labelText: 'Елі *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: _countries.map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCountry = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Постер URL
            TextFormField(
              controller: _posterUrlController,
              decoration: const InputDecoration(
                labelText: 'Постер сілтемесі',
                hintText: 'https://example.com/poster.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
            ),
            const SizedBox(height: 16),

            // Рейтинг
            TextFormField(
              controller: _ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Рейтинг (0-10)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.star),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final rating = double.tryParse(value);
                  if (rating == null || rating < 0 || rating > 10) {
                    return '0-10 арасында болуы керек';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Сақтау батырмасы
            ElevatedButton(
              onPressed: _isLoading ? null : _saveDrama,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.drama == null ? 'Қосу' : 'Сақтау',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}