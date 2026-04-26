import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _supabase = Supabase.instance.client;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  final String _apiKey = 'AIzaSyB6qrJwl0QJogLvv43FGVDrLV4-JAA_orE';

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: 'Сәлеметсіз бе! 👋\n\nМен сіздің дорама бойынша DoramaAI көмекшіңізбін. Мен сізге:\n\n• Дорама ұсына аламын\n• Актерлер туралы айта аламын\n• Жанр бойынша іздеуге көмектесе аламын\n• Дорама туралы сұрақтарға жауап бере аламын\n\nҚандай дорама іздеп жүрсіз?',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final dramasContext = await _getDramasContext();
      final aiResponse = await _getAIResponse(text, dramasContext);

      setState(() {
        _messages.add(ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Кешіріңіз, қате орын алды. Қайталап көріңіз.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<String> _getDramasContext() async {
    try {
      final response = await _supabase
          .from('dramas')
          .select('title, genre, year, country, rating, description')
          .limit(50);

      final dramas = List<Map<String, dynamic>>.from(response);
      
      if (dramas.isEmpty) {
        return 'Қазіргі уақытта дорамалар қолжетімді емес.';
      }

      String context = 'Қолжетімді дорамалар:\n\n';
      for (var drama in dramas) {
        context += '• ${drama['title']} (${drama['year']}) - ${drama['genre']}, ${drama['country']}, рейтинг: ${drama['rating']}\n';
      }

      return context;
    } catch (e) {
      return 'Дорамалар туралы ақпарат алу мүмкін болмады.';
    }
  }

  Future<String> _getAIResponse(String userMessage, String context) async {
    if (_apiKey == 'API_KEY') {
      return '⚠️ Қате: Google AI Studio API кілті орнатылмаған.\n\nКілтті ai_chat_screen.dart файлында _apiKey айнымалысына қосыңыз.\n\nКілт алу үшін: https://aistudio.google.com/app/apikey';
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
    );

    final systemPrompt = '''
Сіз дорама бойынша AI көмекшісіз. Қазақ тілінде жауап беріңіз.

Сіздің міндетіңіз:
1. Пайдаланушыға дорама ұсыну
2. Дорамалар мен актерлер туралы сұрақтарға жауап беру
3. Жанр, жыл бойынша іздеуге көмектесу

Қолжетімді дорамалар:
$context

ЕРЕЖЕЛЕР:
- ТЕК қазақ тілінде жауап беріңіз
- ТЕК дорамалар туралы сөйлесіңіз
- Қысқа және нақты жауап (4-5 абзац)
- Егер сұрақ дорамаларға қатысты емес болса: "Кешіріңіз, мен тек дорамалар туралы сөйлесе аламын"

Пайдаланушы сұрағы: $userMessage
''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': systemPrompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.9,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          final aiText = data['candidates'][0]['content']['parts'][0]['text'];
          return aiText;
        } else {
          return 'DoramaAI жауап қайтара алмады. Қайталап көріңіз.';
        }
      } else {
        String errorMessage = 'Қате: ${response.statusCode}\n\n';
        
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            errorMessage += 'Хабар: ${errorData['error']['message']}\n';
            if (errorData['error']['status'] != null) {
              errorMessage += 'Статус: ${errorData['error']['status']}\n';
            }
          }
        } catch (e) {
          errorMessage += 'Response: ${response.body}';
        }
        
        return errorMessage;
      }
    } catch (e) {
      return 'Байланыс қатесі: $e\n\nИнтернет байланысын тексеріңіз.';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy),
            SizedBox(width: 8),
            Text('DoramaAI көмекші боты'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
            tooltip: 'Чатты тазалау',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessage(message);
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(
                    'DoramaAI ойланып жатыр...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Хабар жазыңыз...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.purple : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}