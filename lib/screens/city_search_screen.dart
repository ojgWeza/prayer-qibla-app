import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/geocoding_service.dart';

/// Sentinel result meaning "go back to GPS-based location" instead of a
/// picked city. Kept as a dedicated type so callers don't need a nullable
/// CitySearchResult with ambiguous meaning.
class UseGpsLocation {
  const UseGpsLocation();
}

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final _geocoding = GeocodingService();
  final _controller = TextEditingController();
  Timer? _debounce;

  List<CitySearchResult> _results = [];
  bool _loading = false;
  bool _errored = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _runSearch(value));
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _loading = false;
        _errored = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _errored = false;
    });
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final results = await _geocoding.search(query, language: lang);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errored = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.of(context, 'chooseCityTitle'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: AppStrings.of(context, 'searchCityHint'),
                prefixIcon: const Icon(Icons.search_rounded),
                border: const OutlineInputBorder(),
              ),
              onChanged: _onChanged,
              onSubmitted: _runSearch,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppStrings.of(context, 'manualLocationNote'),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.my_location_rounded),
            title: Text(AppStrings.of(context, 'useCurrentLocation')),
            onTap: () => Navigator.of(context).pop(const UseGpsLocation()),
          ),
          const Divider(height: 1),
          Expanded(child: _buildResults(context)),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(AppStrings.of(context, 'searching')),
          ],
        ),
      );
    }
    if (_errored) {
      return Center(child: Text(AppStrings.of(context, 'searchError')));
    }
    if (_controller.text.trim().length >= 2 && _results.isEmpty) {
      return Center(child: Text(AppStrings.of(context, 'noResults')));
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return ListTile(
          leading: const Icon(Icons.place_rounded),
          title: Text(result.displayName),
          onTap: () => Navigator.of(context).pop(result),
        );
      },
    );
  }
}
