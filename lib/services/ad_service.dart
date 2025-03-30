import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  static final AdService instance = AdService._internal();
  AdService._internal();

  void loadRewardedAd({
    required VoidCallback onAdLoaded,
    required VoidCallback onAdFailedToLoad,
  }) {
    RewardedAd.load(
      // adUnitId: 'ca-app-pub-3940256099942544/5224354917', // test ID
      adUnitId: 'ca-app-pub-3566864184779419~9372033494',
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          onAdLoaded();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isRewardedAdReady = false;
          onAdFailedToLoad();
        },
      ),
    );
  }

  void showRewardedAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    required VoidCallback onAdClosed,
  }) {
    if (_rewardedAd != null && _isRewardedAdReady) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdReady = false;
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdReady = false;
          onAdClosed();
        },
      );
      _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
    } else {
      onAdClosed();
    }
  }
}
