import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

import '../../../core/theme/app_colors.dart';

class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  static const _ratesUrl =
      'https://api.frankfurter.dev/v1/latest?base=USD&symbols=IDR,EUR,JPY,GBP';
  static const _feedUrl = 'https://dailycoffeenews.com/feed/';

  static const _basePrices = <String, double>{'Arabica': 5.40, 'Robusta': 2.80};

  static const _currencies = <String, String>{
    'USD': 'USD',
    'IDR': 'IDR',
    'EUR': 'EUR',
    'JPY': 'JPY',
  };

  static final _events = [
    CoffeeEvent(
      title: 'Jakarta Coffee Week',
      location: 'JIExpo',
      utcDate: DateTime.utc(2026, 10, 24, 3),
    ),
    CoffeeEvent(
      title: 'Webinar Latte Art',
      location: 'Zoom',
      utcDate: DateTime.utc(2026, 11, 12, 12),
    ),
    CoffeeEvent(
      title: 'Brew Innovation Forum',
      location: 'Bandung',
      utcDate: DateTime.utc(2026, 12, 5, 2),
    ),
  ];

  static const _webFallbackRates = <String, double>{
    'USD': 1,
    'IDR': 16800,
    'EUR': 0.86,
    'JPY': 159,
  };

  static const _webFallbackArticles = <NewsPreview>[
    NewsPreview(
      title: 'Daily Coffee News',
      description:
          'Berita kopi terbaru tersedia saat akses RSS browser diizinkan.',
    ),
    NewsPreview(
      title: 'Jelajahi dunia kopi',
      description:
          'Buka aplikasi Android/iOS untuk memuat RSS Daily Coffee News secara langsung.',
    ),
  ];

  Map<String, double> _rates = _webFallbackRates;
  List<RssItem> _articles = [];
  List<NewsPreview> _fallbackArticles = [];
  String _selectedCurrency = 'IDR';
  int _selectedUtcOffset = 7;
  bool _isLoadingRates = true;
  bool _isLoadingNews = true;
  String? _ratesError;
  String? _newsError;

  @override
  void initState() {
    super.initState();
    _fetchRates();
    _fetchNews();
  }

  Future<void> _fetchRates() async {
    try {
      final response = await http.get(Uri.parse(_ratesUrl));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final body = response.body;
      final decoded = _decodeJsonObject(body);
      final rawRates = decoded['rates'];
      if (rawRates is! Map) {
        throw const FormatException('Format kurs tidak valid');
      }

      final rates = <String, double>{'USD': 1};
      for (final currency in _currencies.keys) {
        if (currency == 'USD') {
          continue;
        }
        final value = rawRates[currency];
        if (value is num) {
          rates[currency] = value.toDouble();
        }
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _rates = rates;
        _isLoadingRates = false;
        _ratesError = null;
      });
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingRates = false;
        _ratesError = kIsWeb
            ? null
            : 'Harga dan kurs tidak dapat dimuat: $error';
        if (kIsWeb) {
          _rates = _webFallbackRates;
        }
      });
    }
  }

  Future<void> _fetchNews() async {
    try {
      final response = await http.get(Uri.parse(_feedUrl));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final feed = RssFeed.parse(response.body);
      final articles = (feed.items ?? []).take(5).toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _articles = articles;
        _fallbackArticles = [];
        _isLoadingNews = false;
        _newsError = null;
      });
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingNews = false;
        _newsError = kIsWeb ? null : 'Berita tidak dapat dimuat: $error';
        if (kIsWeb) {
          _fallbackArticles = _webFallbackArticles;
        }
      });
    }
  }

  Map<String, dynamic> _decodeJsonObject(String source) {
    final value = const JsonDecoder().convert(source);
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw const FormatException('Respons kurs bukan object JSON');
  }

  double _priceFor(String product) {
    final basePrice = _basePrices[product] ?? 0;
    return basePrice * (_rates[_selectedCurrency] ?? 1);
  }

  String _formatPrice(double price) {
    return NumberFormat.currency(
      name: _selectedCurrency,
      decimalDigits: _selectedCurrency == 'IDR' ? 0 : 2,
    ).format(price);
  }

  DateTime _localEventDate(DateTime utcDate) {
    return utcDate.add(Duration(hours: _selectedUtcOffset));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryWhite,
      appBar: AppBar(
        title: const Text('Info Global'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_fetchRates(), _fetchNews()]);
        },
        color: AppColors.mediumCoffee,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildPriceCard(),
            const SizedBox(height: 28),
            _buildEventsSection(),
            const SizedBox(height: 28),
            _buildNewsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.darkCoffee,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkCoffee.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Harga Biji Global',
                  style: TextStyle(
                    color: AppColors.ivoryWhite,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedCurrency,
                dropdownColor: AppColors.darkCoffee,
                underline: const SizedBox.shrink(),
                iconEnabledColor: AppColors.ivoryWhite,
                style: const TextStyle(color: AppColors.ivoryWhite),
                items: _currencies.keys
                    .map(
                      (currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      ),
                    )
                    .toList(),
                onChanged: (currency) {
                  if (currency != null) {
                    setState(() => _selectedCurrency = currency);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_isLoadingRates)
            const Center(
              child: CircularProgressIndicator(color: AppColors.lightCream),
            )
          else if (_ratesError != null)
            Text(
              _ratesError!,
              style: const TextStyle(color: AppColors.lightCream),
            )
          else
            Row(
              children: [
                Expanded(child: _buildPriceTile('Arabica')),
                const SizedBox(width: 14),
                Expanded(child: _buildPriceTile('Robusta')),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPriceTile(String name) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mediumCoffee.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$name (kg)',
            style: const TextStyle(color: AppColors.ivoryWhite, fontSize: 16),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatPrice(_priceFor(name)),
              style: const TextStyle(
                color: AppColors.ivoryWhite,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name == 'Arabica' ? '▲ Base USD 5.40' : '▲ Base USD 2.80',
            style: const TextStyle(color: Colors.lightGreenAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Event & Webinar',
                style: TextStyle(
                  color: AppColors.darkCoffee,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DropdownButton<int>(
              value: _selectedUtcOffset,
              underline: const SizedBox.shrink(),
              style: const TextStyle(color: AppColors.darkCoffee),
              items: const [
                DropdownMenuItem(value: 7, child: Text('WIB')),
                DropdownMenuItem(value: 8, child: Text('WITA')),
                DropdownMenuItem(value: 9, child: Text('WIT')),
                DropdownMenuItem(value: 0, child: Text('UTC')),
              ],
              onChanged: (offset) {
                if (offset != null) {
                  setState(() => _selectedUtcOffset = offset);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final event in _events) ...[
          _buildEventTile(event),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildEventTile(CoffeeEvent event) {
    final localDate = _localEventDate(event.utcDate);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.mediumCoffee.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightCream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('MMM').format(localDate).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.darkCoffee,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${localDate.day}',
                    style: const TextStyle(
                      color: AppColors.darkCoffee,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.darkCoffee,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${DateFormat('dd MMM yyyy - HH:mm').format(localDate)} '
                    '· ${event.location}',
                    style: const TextStyle(color: AppColors.mediumCoffee),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Berita Terkini',
          style: TextStyle(
            color: AppColors.darkCoffee,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingNews)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.mediumCoffee),
            ),
          )
        else if (_newsError != null)
          _buildErrorMessage(_newsError!, _fetchNews)
        else if (_articles.isEmpty && _fallbackArticles.isEmpty)
          const Text(
            'Belum ada berita yang tersedia.',
            style: TextStyle(color: AppColors.mediumCoffee),
          )
        else if (_articles.isNotEmpty)
          for (final article in _articles) _buildNewsTile(article)
        else
          for (final article in _fallbackArticles)
            _buildFallbackNewsTile(article),
      ],
    );
  }

  Widget _buildNewsTile(RssItem article) {
    final title = article.title?.trim();
    final description = _cleanDescription(article.description);
    final date = article.pubDate == null
        ? 'Tanggal tidak tersedia'
        : DateFormat('dd MMM yyyy - HH:mm').format(article.pubDate!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.mediumCoffee,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.coffee,
            color: AppColors.lightCream,
            size: 34,
          ),
        ),
        title: Text(
          title == null || title.isEmpty ? 'Berita tanpa judul' : title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.darkCoffee,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(
            '$date\n${description.isEmpty ? 'Baca berita selengkapnya di Daily Coffee News.' : description}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.mediumCoffee),
          ),
        ),
        onTap: article.link == null
            ? null
            : () => _showArticleLink(article.link!),
      ),
    );
  }

  Widget _buildFallbackNewsTile(NewsPreview article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.mediumCoffee,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.coffee,
            color: AppColors.lightCream,
            size: 34,
          ),
        ),
        title: Text(
          article.title,
          style: const TextStyle(
            color: AppColors.darkCoffee,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(
            article.description,
            style: const TextStyle(color: AppColors.mediumCoffee),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message, VoidCallback retry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: const TextStyle(color: Colors.red)),
        TextButton(onPressed: retry, child: const Text('Coba lagi')),
      ],
    );
  }

  String _cleanDescription(String? description) {
    if (description == null) {
      return '';
    }
    return description
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _showArticleLink(String link) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buka Berita'),
        content: Text(link),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class CoffeeEvent {
  const CoffeeEvent({
    required this.title,
    required this.location,
    required this.utcDate,
  });

  final String title;
  final String location;
  final DateTime utcDate;
}

class NewsPreview {
  const NewsPreview({required this.title, required this.description});

  final String title;
  final String description;
}
