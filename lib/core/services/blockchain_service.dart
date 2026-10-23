import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

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
  }

  static final Blockchain instance = Blockchain._();

  final List<Block> _chain = [];

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

  void addBlock(String data) {
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
