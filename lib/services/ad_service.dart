import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/auth_provider.dart';
import 'dart:async';
import 'dart:math';

import '../screens/ads/video_ad_screen.dart';

class AdService {
  static DateTime? _lastAdShownTime;
  static const Duration _minIntervalBetweenAds = Duration(minutes: 5);
  static int _actionCounter = 0;
  static const int _actionsBetweenAds =
      20; // Show ad every 20 significant actions

  // Initialize checks
  static void init() {
    // Reset counters on init if needed
    _actionCounter = 0;
  }

  // Check and show ad on startup
  static void checkAndShowStartupAd(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isPremium) return;

    // Small delay to ensure context is valid and UI is built
    Future.delayed(const Duration(seconds: 5), () {
      if (context.mounted) {
        _showAd(context);
      }
    });
  }

  // Check based on actions (e.g. swipes)
  static void incrementActionAndCheck(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isPremium) return;

    _actionCounter++;
    if (_actionCounter >= _actionsBetweenAds) {
      if (_canShowAd()) {
        _showAd(context);
        _actionCounter = 0;
      }
    }
  }

  // Check based on time or manual trigger
  static void checkPeriodic(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isPremium) return;

    if (_canShowAd()) {
      _showAd(context);
    }
  }

  static bool _canShowAd() {
    if (_lastAdShownTime == null) return true;
    final difference = DateTime.now().difference(_lastAdShownTime!);
    return difference >= _minIntervalBetweenAds;
  }

  static void _showAd(BuildContext context) {
    _lastAdShownTime = DateTime.now();

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const VideoAdScreen(),
      ),
    );
  }
}
