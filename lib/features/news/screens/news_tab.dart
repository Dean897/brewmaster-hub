import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/coffee_app_bar.dart';
import '../../../core/widgets/page_scrubber.dart';

class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  static const _ratesUrl =
      'https://api.frankfurter.dev/v1/latest?base=USD&symbols=IDR,EUR,JPY,AUD,GBP';
  static const _feedUrl = 'https://dailycoffeenews.com/feed/';

  static const _basePrices = <String, double>{'Arabica': 5.40, 'Robusta': 2.80};
  static const _currencyPairs = <(String, String)>[
    ('USD', 'IDR'),
    ('EUR', 'JPY'),
    ('AUD', 'GBP'),
  ];
  static const _timeZones = <({String label, int offset})>[
    (label: 'WIB', offset: 7),
    (label: 'WITA', offset: 8),
    (label: 'WIT', offset: 9),
    (label: 'UTC', offset: 0),
  ];

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
    'AUD': 1.53,
    'GBP': 0.79,
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
  final _marketPageController = PageController();
  final _eventsPageController = PageController(viewportFraction: 0.88);
  final Map<String, int> _eventTimeZoneOffsets = {};
  int _marketPage = 0;
  int _eventsPage = 0;
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

  @override
  void dispose() {
    _marketPageController.dispose();
    _eventsPageController.dispose();
    super.dispose();
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
      for (final currency in {'IDR', 'EUR', 'JPY', 'AUD', 'GBP'}) {
        final value = rawRates[currency];
        if (value is! num) {
          throw FormatException('Kurs $currency tidak tersedia');
        }
        rates[currency] = value.toDouble();
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

  double _priceFor(String product, String currency) {
    final basePrice = _basePrices[product] ?? 0;
    final rate = _rates[currency];
    if (rate == null) {
      throw StateError('Kurs $currency tidak tersedia.');
    }
    return basePrice * rate;
  }

  String _formatPrice(double price, String currency) {
    return NumberFormat.currency(
      name: currency,
      decimalDigits: currency == 'IDR' || currency == 'JPY' ? 0 : 2,
    ).format(price);
  }

  int _timeZoneOffset(CoffeeEvent event) {
    return _eventTimeZoneOffsets[event.title] ?? 7;
  }

  String _timeZoneLabel(int offset) {
    return _timeZones.firstWhere((zone) => zone.offset == offset).label;
  }

  DateTime _localEventDate(CoffeeEvent event) {
    return event.utcDate.add(Duration(hours: _timeZoneOffset(event)));
  }

  Future<void> _selectEventTimeZone(CoffeeEvent event) async {
    final selectedOffset = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.ivoryWhite,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pilih zona waktu',
                  style: TextStyle(
                    color: AppColors.darkCoffee,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            for (final zone in _timeZones)
              ListTile(
                title: Text(zone.label),
                subtitle: Text(
                  'UTC${zone.offset == 0
                      ? ''
                      : zone.offset > 0
                      ? '+'
                      : ''}${zone.offset}',
                ),
                trailing: _timeZoneOffset(event) == zone.offset
                    ? const Icon(Icons.check, color: AppColors.mediumCoffee)
                    : null,
                onTap: () => Navigator.of(context).pop(zone.offset),
              ),
          ],
        ),
      ),
    );

    if (selectedOffset != null && mounted) {
      setState(() {
        _eventTimeZoneOffsets[event.title] = selectedOffset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryWhite,
      appBar: coffeeAppBar(title: 'The Daily Brew'),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_fetchRates(), _fetchNews()]);
        },
        color: AppColors.mediumCoffee,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          children: [
            _buildMarketSection(),
            const SizedBox(height: 30),
            _buildEventsSection(),
            const SizedBox(height: 30),
            _buildNewsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.darkCoffee,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.mediumCoffee.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(
          title: 'Market Pulse',
          subtitle: 'Harga acuan biji kopi per kilogram',
        ),
        _buildPriceCard(),
        const SizedBox(height: 14),
        PageScrubber(
          count: _currencyPairs.length,
          currentPage: _marketPage,
          color: AppColors.darkCoffee,
          inactiveColor: AppColors.mediumCoffee,
          onPageSelected: (index) {
            _marketPageController.jumpToPage(index);
          },
        ),
      ],
    );
  }

  Widget _buildPriceCard() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _marketPageController,
        itemCount: _currencyPairs.length,
        onPageChanged: (index) => setState(() => _marketPage = index),
        itemBuilder: (context, index) {
          final pair = _currencyPairs[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            decoration: BoxDecoration(
              color: AppColors.darkCoffee,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkCoffee.withValues(alpha: 0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: _isLoadingRates
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.lightCream,
                    ),
                  )
                : _ratesError != null
                ? Center(
                    child: Text(
                      _ratesError!,
                      style: const TextStyle(color: AppColors.lightCream),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.show_chart_rounded,
                            color: AppColors.lightCream,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${pair.$1}  →  ${pair.$2}',
                            style: const TextStyle(
                              color: AppColors.lightCream,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${index + 1} / ${_currencyPairs.length}',
                            style: TextStyle(
                              color: AppColors.ivoryWhite.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        height: 1,
                        color: AppColors.ivoryWhite.withValues(alpha: 0.18),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPriceRow('Arabica', pair.$1, pair.$2),
                            _buildPriceRow('Robusta', pair.$1, pair.$2),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPriceRow(
    String product,
    String firstCurrency,
    String secondCurrency,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            product,
            style: const TextStyle(
              color: AppColors.ivoryWhite,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _formatPrice(
                      _priceFor(product, firstCurrency),
                      firstCurrency,
                    ),
                    style: const TextStyle(
                      color: AppColors.ivoryWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.lightCream.withValues(alpha: 0.8),
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _formatPrice(
                      _priceFor(product, secondCurrency),
                      secondCurrency,
                    ),
                    style: const TextStyle(
                      color: AppColors.lightCream,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(
          title: 'Upcoming Events',
          subtitle: 'Pilih zona waktu langsung dari kartu acara',
        ),
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _eventsPageController,
            itemCount: _events.length,
            onPageChanged: (index) => setState(() => _eventsPage = index),
            itemBuilder: (context, index) => _buildEventTile(_events[index]),
          ),
        ),
        const SizedBox(height: 8),
        PageScrubber(
          count: _events.length,
          currentPage: _eventsPage,
          color: AppColors.darkCoffee,
          inactiveColor: AppColors.mediumCoffee,
          onPageSelected: (index) {
            _eventsPageController.jumpToPage(index);
          },
        ),
      ],
    );
  }

  Widget _buildEventTile(CoffeeEvent event) {
    final localDate = _localEventDate(event);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      elevation: 2,
      color: AppColors.ivoryWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.mediumCoffee.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.lightCream,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(localDate).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.darkCoffee,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${localDate.day}',
                        style: const TextStyle(
                          color: AppColors.darkCoffee,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.darkCoffee,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.location,
                        style: const TextStyle(
                          color: AppColors.mediumCoffee,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            ActionChip(
              avatar: const Icon(
                Icons.schedule_rounded,
                size: 17,
                color: AppColors.darkCoffee,
              ),
              label: Text(
                '${DateFormat('dd MMM yyyy · HH:mm').format(localDate)} '
                '${_timeZoneLabel(_timeZoneOffset(event))}',
              ),
              labelStyle: const TextStyle(
                color: AppColors.darkCoffee,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              backgroundColor: AppColors.lightCream,
              side: BorderSide.none,
              onPressed: () => _selectEventTimeZone(event),
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
        _buildSectionHeading(
          title: 'Latest News',
          subtitle: 'Cerita dan kabar terbaru dari dunia kopi',
        ),
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
    final source = article.source?.value?.trim();
    final thumbnailUrl = _thumbnailUrl(article);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: article.link == null ? null : () => _openArticle(article.link!),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 170,
              child: _buildNewsImage(thumbnailUrl),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 14, 17, 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.newspaper_rounded,
                        size: 15,
                        color: AppColors.mediumCoffee,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          source == null || source.isEmpty
                              ? 'Daily Coffee News'
                              : source,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.mediumCoffee,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (article.pubDate != null)
                        Text(
                          DateFormat('dd MMM yyyy').format(article.pubDate!),
                          style: TextStyle(
                            color: AppColors.mediumCoffee.withValues(
                              alpha: 0.8,
                            ),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    title == null || title.isEmpty
                        ? 'Berita tanpa judul'
                        : title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.darkCoffee,
                      fontSize: 17,
                      height: 1.3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.mediumCoffee,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsImage(String? imageUrl) {
    if (imageUrl == null) {
      return _newsImagePlaceholder();
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _newsImagePlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return _newsImagePlaceholder();
      },
    );
  }

  Widget _newsImagePlaceholder() {
    return ColoredBox(
      color: AppColors.lightCream,
      child: Center(
        child: Icon(
          Icons.coffee_rounded,
          size: 52,
          color: AppColors.mediumCoffee.withValues(alpha: 0.75),
        ),
      ),
    );
  }

  String? _thumbnailUrl(RssItem article) {
    final thumbnails = article.media?.thumbnails;
    if (thumbnails != null && thumbnails.isNotEmpty) {
      final url = thumbnails.first.url;
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }

    final mediaContents = article.media?.contents;
    if (mediaContents != null) {
      for (final content in mediaContents) {
        if (content.url != null && content.type?.startsWith('image/') == true) {
          return content.url;
        }
      }
    }

    final enclosure = article.enclosure;
    final enclosureUrl = enclosure?.url;
    final enclosureType = enclosure?.type;
    if (enclosureUrl != null &&
        (enclosureType == null || enclosureType.startsWith('image/'))) {
      return enclosureUrl;
    }

    final html = article.description ?? article.content?.value;
    if (html != null) {
      final match = RegExp(
        r'''<img[^>]+src=["']([^"']+)["']''',
        caseSensitive: false,
      ).firstMatch(html);
      return match?.group(1);
    }
    return null;
  }

  Future<void> _openArticle(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      _showOpenArticleError('Tautan berita tidak valid.');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _showOpenArticleError('Tautan berita tidak dapat dibuka.');
      }
    } on Exception {
      if (mounted) {
        _showOpenArticleError('Tautan berita tidak dapat dibuka.');
      }
    }
  }

  void _showOpenArticleError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
