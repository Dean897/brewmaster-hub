import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';

class AiChatTab extends StatefulWidget {
  const AiChatTab({super.key});

  @override
  State<AiChatTab> createState() => _AiChatTabState();
}

class _AiChatTabState extends State<AiChatTab> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  static const _historyKey = 'ai_chat_history';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_historyKey);
    if (encoded == null || !mounted) {
      return;
    }
    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      return;
    }
    setState(() {
      _messages
        ..clear()
        ..addAll(
          decoded.whereType<Map>().map(
            (item) => Map<String, String>.from(item),
          ),
        );
    });
  }

  Future<void> _saveHistory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_historyKey, jsonEncode(_messages));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    final message = text.trim();
    if (message.isEmpty || _isLoading) {
      return;
    }

    _messageController.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': message});
      _isLoading = true;
    });
    await _saveHistory();
    _scrollToBottom();

    try {
      final model = GenerativeModel(
        model: 'gemini-3.8-flash',
        apiKey: ApiConstants.geminiApiKey,
      );
      final response = await model.generateContent([Content.text(message)]);
      final responseText = response.text?.trim();

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add({
          'role': 'model',
          'text': responseText == null || responseText.isEmpty
              ? 'Maaf, saya tidak menerima respons dari AI.'
              : responseText,
        });
      });
      await _saveHistory();
      _scrollToBottom();
    } catch (error, stackTrace) {
      debugPrint('Gemini request failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add({
          'role': 'model',
          'text': 'Maaf, Asisten AI sedang istirahat. Coba lagi nanti!',
        });
      });
      await _saveHistory();
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Tanyakan apa saja tentang kopi kepada asisten AI.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mediumCoffee),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser
                                ? AppColors.darkCoffee
                                : AppColors.lightCream,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: TextStyle(
                              color: isUser
                                  ? AppColors.ivoryWhite
                                  : AppColors.darkCoffee,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(
                color: AppColors.mediumCoffee,
                backgroundColor: AppColors.lightCream,
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: AppColors.ivoryWhite,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _QuickPrompt(
                        label: 'Resep Es Kopi Susu',
                        onPressed: () => _sendMessage('Resep Es Kopi Susu'),
                      ),
                      _QuickPrompt(
                        label: 'Cara Cold Brew',
                        onPressed: () => _sendMessage('Cara Cold Brew'),
                      ),
                      _QuickPrompt(
                        label: 'Kopi Asam Lambung',
                        onPressed: () => _sendMessage('Kopi Asam Lambung'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan...',
                          filled: true,
                          fillColor: AppColors.lightCream,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isLoading
                          ? null
                          : () => _sendMessage(_messageController.text),
                      icon: const Icon(Icons.send),
                      color: AppColors.darkCoffee,
                      tooltip: 'Kirim',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPrompt extends StatelessWidget {
  const _QuickPrompt({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onPressed,
        backgroundColor: AppColors.lightCream,
        labelStyle: const TextStyle(color: AppColors.darkCoffee),
      ),
    );
  }
}
