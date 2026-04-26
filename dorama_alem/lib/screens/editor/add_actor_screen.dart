import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddActorScreen extends StatefulWidget {
  final Map<String, dynamic>? actor; 

  const AddActorScreen({super.key, this.actor});

  @override
  State<AddActorScreen> createState() => _AddActorScreenState();
}

class _AddActorScreenState extends State<AddActorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.actor != null) {
      _loadActorData();
    }
  }

  void _loadActorData() {
    _nameController.text = widget.actor!['name'] ?? '';
    _bioController.text = widget.actor!['bio'] ?? '';
    _photoUrlController.text = widget.actor!['photo_url'] ?? '';
    _birthDateController.text = widget.actor!['birth_date'] ?? '';
    _countryController.text = widget.actor!['country'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _photoUrlController.dispose();
    _birthDateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  Future<void> _saveActor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final actorData = {
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim().isEmpty 
            ? null 
            : _bioController.text.trim(),
        'photo_url': _photoUrlController.text.trim().isEmpty 
            ? null 
            : _photoUrlController.text.trim(),
        'birth_date': _birthDateController.text.isEmpty 
            ? null 
            : _birthDateController.text,
        'country': _countryController.text.trim().isEmpty 
            ? null 
            : _countryController.text.trim(),
      };

      if (widget.actor == null) {
        await _supabase.from('actors').insert(actorData);
      } else {
        await _supabase
            .from('actors')
            .update(actorData)
            .eq('id', widget.actor!['id']);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.actor == null 
                ? 'Актер сәтті қосылды!' 
                : 'Актер сәтті өңделді!'),
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
        title: Text(widget.actor == null ? 'Актер қосу' : 'Актерді өңдеу'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Аты-жөні *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Аты-жөнін енгізіңіз';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Биография',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _photoUrlController,
              decoration: const InputDecoration(
                labelText: 'Фото сілтемесі',
                hintText: 'https://example.com/photo.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _birthDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Туған күні',
                hintText: 'YYYY-MM-DD',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.cake),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Елі',
                hintText: 'Оңтүстік Корея',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _saveActor,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.actor == null ? 'Қосу' : 'Сақтау',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}