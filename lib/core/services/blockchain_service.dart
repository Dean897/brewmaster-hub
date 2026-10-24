import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Block {
  Block({
    required this.index,
    required this.timestamp,
    required this.data,
    required this.previousHash,
    String? hash,
  }) : hash =
           hash ??
           _calculateBlockHash(
             index: index,
             timestamp: timestamp,
             data: data,
             previousHash: previousHash,
           );

  final int index;
  final DateTime timestamp;
  final String data;
  final String previousHash;
  final String hash;

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      index: json['index'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String).toUtc(),
      data: json['data'] as String,
      previousHash: json['previousHash'] as String,
      hash: json['hash'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'index': index,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'data': data,
    'previousHash': previousHash,
    'hash': hash,
  };

  String calculateHash() {
    return _calculateBlockHash(
      index: index,
      timestamp: timestamp,
      data: data,
      previousHash: previousHash,
    );
  }
}

String _calculateBlockHash({
  required int index,
  required DateTime timestamp,
  required String data,
  required String previousHash,
}) {
  final payload = jsonEncode({
    'index': index,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'data': data,
    'previousHash': previousHash,
  });
  return sha256.convert(utf8.encode(payload)).toString();
}

class Blockchain extends ChangeNotifier {
  Blockchain._() {
    _chain.add(_createGenesisBlock());
    _loadFuture = loadChainFromPrefs();
  }

  static final Blockchain instance = Blockchain._();
  static const _storageKey = 'blockchain_stamps';

  final List<Block> _chain = [];
  late final Future<void> _loadFuture;

  List<Block> get chain => List.unmodifiable(_chain);

  int get stampCount => _chain.length - 1;

  Block _createGenesisBlock() {
    return Block(
      index: 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      data: 'Genesis Block',
      previousHash: '0',
    );
  }

  Future<void> addBlock(String data) async {
    await _loadFuture;
    final normalizedData = data.trim();
    if (normalizedData.isEmpty) {
      throw ArgumentError.value(
        data,
        'data',
        'Data stempel tidak boleh kosong.',
      );
    }

    final previousBlock = _chain.last;
    _chain.add(
      Block(
        index: _chain.length,
        timestamp: DateTime.now().toUtc(),
        data: normalizedData,
        previousHash: previousBlock.hash,
      ),
    );
    notifyListeners();
    await saveChainToPrefs();
  }

  Future<void> saveChainToPrefs() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedChain = jsonEncode(
      _chain.map((block) => block.toJson()).toList(),
    );
    await preferences.setString(_storageKey, encodedChain);
  }

  Future<void> resetChain() async {
    await _loadFuture;
    _chain
      ..clear()
      ..add(_createGenesisBlock());
    await saveChainToPrefs();
    notifyListeners();
  }

  Future<void> loadChainFromPrefs() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedChain = preferences.getString(_storageKey);
    if (encodedChain == null || encodedChain.isEmpty) {
      return;
    }

    try {
      final decodedChain = jsonDecode(encodedChain);
      if (decodedChain is! List) {
        return;
      }

      final loadedChain = decodedChain
          .map((item) => Block.fromJson(item as Map<String, dynamic>))
          .toList();
      if (loadedChain.isEmpty ||
          loadedChain.first.index != 0 ||
          loadedChain.first.previousHash != '0') {
        return;
      }

      _chain
        ..clear()
        ..addAll(loadedChain);
      notifyListeners();
    } on FormatException catch (error) {
      debugPrint('Blockchain tidak dapat dimuat: $error');
    } on TypeError catch (error) {
      debugPrint('Format blockchain tidak valid: $error');
    }
  }

  bool isChainValid() {
    for (var index = 0; index < _chain.length; index++) {
      final currentBlock = _chain[index];
      if (currentBlock.hash != currentBlock.calculateHash()) {
        return false;
      }
      if (index == 0) {
        if (currentBlock.previousHash != '0') {
          return false;
        }
        continue;
      }
      if (currentBlock.previousHash != _chain[index - 1].hash) {
        return false;
      }
    }
    return true;
  }
}
