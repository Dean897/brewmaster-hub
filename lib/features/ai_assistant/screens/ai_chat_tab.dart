import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';

class _ChatSession {
  _ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  factory _ChatSession.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'];
    final messages = rawMessages is List
        ? rawMessages
              .whereType<Map>()
              .map((message) => Map<String, String>.from(message))
              .toList()
        : <Map<String, String>>[];

    return _ChatSession(
      id: json['id']?.toString() ?? DateTime.now().toIso8601String(),
      title: json['title']?.toString() ?? 'Percakapan baru',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      messages: messages,
    );
  }

  final String id;
  String title;
  final DateTime createdAt;
  final List<Map<String, String>> messages;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'messages': messages,
  };
}

class AiChatTab extends StatefulWidget {
  const AiChatTab({super.key});

  @override
  State<AiChatTab> createState() => _AiChatTabState();
}

class _AiChatTabState extends State<AiChatTab> {
  static const _historyKey = 'ai_chat_sessions';
  static const _legacyHistoryKey = 'ai_chat_history';

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatSession> _sessions = [];
  final List<Map<String, String>> _messages = [];

  bool _isLoading = false;
  bool _isHistoryLoading = true;
  String? _activeSessionId;

  _ChatSession? get _activeSession {
    final id = _activeSessionId;
    if (id == null) {
      return null;
    }
    for (final session in _sessions) {
      if (session.id == id) {
        return session;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_historyKey);
      final legacyEncoded = preferences.getString(_legacyHistoryKey);
      final loadedSessions = <_ChatSession>[];

      if (encoded != null) {
        final decoded = jsonDecode(encoded);
        if (decoded is List) {
          loadedSessions.addAll(
            decoded
                .whereType<Map>()
                .map(
                  (item) =>
                      _ChatSession.fromJson(Map<String, dynamic>.from(item)),
                )
                .where((session) => session.messages.isNotEmpty),
          );
        }
      } else if (legacyEncoded != null) {
        final decoded = jsonDecode(legacyEncoded);
        if (decoded is List) {
          final messages = decoded
              .whereType<Map>()
              .map((item) => Map<String, String>.from(item))
              .toList();
          if (messages.isNotEmpty) {
            loadedSessions.add(
              _ChatSession(
                id: DateTime.now().toIso8601String(),
                title: _titleFromMessages(messages),
                createdAt: DateTime.now(),
                messages: messages,
              ),
            );
            await preferences.remove(_legacyHistoryKey);
            await _saveSessions(loadedSessions, preferences: preferences);
          }
        }
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _sessions
          ..clear()
          ..addAll(loadedSessions);
        _isHistoryLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Gagal memuat history chat: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() => _isHistoryLoading = false);
      }
    }
  }

  Future<void> _saveSessions(
    List<_ChatSession> sessions, {
    SharedPreferences? preferences,
  }) async {
    final store = preferences ?? await SharedPreferences.getInstance();
    await store.setString(
      _historyKey,
      jsonEncode(sessions.map((session) => session.toJson()).toList()),
    );
  }

  String _titleFromMessages(List<Map<String, String>> messages) {
    final firstUserMessage = messages.cast<Map<String, String>?>().firstWhere(
      (message) => message?['role'] == 'user',
      orElse: () => null,
    );
    final text = firstUserMessage?['text']?.trim();
    if (text == null || text.isEmpty) {
      return 'Percakapan baru';
    }
    return text.length > 32 ? '${text.substring(0, 32)}...' : text;
  }

  Future<void> _saveActiveSession() async {
    if (_messages.isEmpty) {
      return;
    }
    final session = _activeSession;
    if (session == null) {
      return;
    }
    session.title = _titleFromMessages(_messages);
    session.messages
      ..clear()
      ..addAll(_messages);
    await _saveSessions(_sessions);
  }

  Future<void> _startNewChat() async {
    if (_isLoading) {
      return;
    }
    await _saveActiveSession();
    if (!mounted) {
      return;
    }
    setState(() {
      _activeSessionId = null;
      _messages.clear();
    });
    Navigator.of(context).pop();
  }

  Future<void> _openSession(_ChatSession session) async {
    if (_isLoading) {
      return;
    }
    await _saveActiveSession();
    if (!mounted) {
      return;
    }
    setState(() {
      _activeSessionId = session.id;
      _messages
        ..clear()
        ..addAll(session.messages);
    });
    Navigator.of(context).pop();
    _scrollToBottom();
  }

  Future<void> _deleteSession(_ChatSession session) async {
    _sessions.removeWhere((item) => item.id == session.id);
    if (_activeSessionId == session.id) {
      _activeSessionId = null;
      _messages.clear();
    }
    await _saveSessions(_sessions);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _sendMessage(String text) async {
    final message = text.trim();
    if (message.isEmpty || _isLoading) {
      return;
    }

    _messageController.clear();
    if (_activeSessionId == null) {
      final session = _ChatSession(
        id: DateTime.now().toIso8601String(),
        title: _titleFromMessages([
          {'role': 'user', 'text': message},
        ]),
        createdAt: DateTime.now(),
        messages: [],
      );
      _sessions.insert(0, session);
      _activeSessionId = session.id;
    }

    setState(() {
      _messages.add({'role': 'user', 'text': message});
      _isLoading = true;
    });
    await _saveActiveSession();
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
      await _saveActiveSession();
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
      await _saveActiveSession();
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    if (now.year == date.year &&
        now.month == date.month &&
        now.day == date.day) {
      return 'Hari ini';
    }
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildHistoryDrawer(),
      appBar: AppBar(
        title: const Text(
          'Asisten AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkCoffee,
        foregroundColor: AppColors.ivoryWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'History chat',
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _startNewChat,
            icon: const Icon(Icons.edit_square),
            tooltip: 'Chat baru',
          ),
        ],
      ),
      backgroundColor: AppColors.ivoryWhite,
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Tanyakan apa saja tentang kopi kepada asisten AI.\n\nChat baru akan tersimpan di history.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.mediumCoffee),
                      ),
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
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
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
    );
  }

  Widget _buildHistoryDrawer() {
    return Drawer(
      backgroundColor: AppColors.ivoryWhite,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
              color: AppColors.darkCoffee,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'History Chat',
                      style: TextStyle(
                        color: AppColors.ivoryWhite,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _startNewChat,
                    icon: const Icon(Icons.add, color: AppColors.ivoryWhite),
                    tooltip: 'Chat baru',
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.edit_square,
                color: AppColors.darkCoffee,
              ),
              title: const Text(
                'Chat baru',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: _startNewChat,
            ),
            const Divider(height: 1),
            Expanded(
              child: _isHistoryLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _sessions.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Belum ada history percakapan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.mediumCoffee),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        return ListTile(
                          selected: session.id == _activeSessionId,
                          selectedTileColor: AppColors.lightCream,
                          leading: const Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.mediumCoffee,
                          ),
                          title: Text(
                            session.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(_dateLabel(session.createdAt)),
                          trailing: IconButton(
                            onPressed: () => _deleteSession(session),
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Hapus chat',
                          ),
                          onTap: () => _openSession(session),
                        );
                      },
                    ),
            ),
          ],
        ),
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
