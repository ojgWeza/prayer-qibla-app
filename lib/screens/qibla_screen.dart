import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../l10n/app_strings.dart';
import '../services/location_service.dart';
import '../widgets/banner_ad_widget.dart';

class QiblaScreen extends StatelessWidget {
  final LocationState locationState;
  final double? qiblaBearing;
  final VoidCallback onRetryLocation;

  const QiblaScreen({
    super.key,
    required this.locationState,
    required this.qiblaBearing,
    required this.onRetryLocation,
  });

  @override
  Widget build(BuildContext context) {
    if (locationState == LocationState.denied ||
        locationState == LocationState.deniedForever ||
        locationState == LocationState.serviceDisabled) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48),
              const SizedBox(height: 16),
              Text(
                AppStrings.of(context, 'locationDenied'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetryLocation,
                child: Text(AppStrings.of(context, 'grantPermission')),
              ),
            ],
          ),
        ),
      );
    }

    if (qiblaBearing == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.connectionState == ConnectionState.active) {
                  return Center(
                    child: Text(AppStrings.of(context, 'compassUnavailable')),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              }
              final heading = snapshot.data!.heading;
              if (heading == null) {
                return Center(
                  child: Text(AppStrings.of(context, 'compassUnavailable')),
                );
              }
              final angle = ((qiblaBearing! - heading) * pi / 180) * -1;
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.of(context, 'qiblaTitle'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    Transform.rotate(
                      angle: angle,
                      child: Icon(
                        Icons.navigation,
                        size: 160,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('${qiblaBearing!.toStringAsFixed(0)}°'),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        AppStrings.of(context, 'qiblaHint'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SafeArea(top: false, child: BannerAdWidget()),
      ],
    );
  }
}
