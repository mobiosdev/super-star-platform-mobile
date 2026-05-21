enum SubscriptionTier {
  silver,
  gold,
  platinum;

  String get label {
    switch (this) {
      case SubscriptionTier.silver:
        return 'Silver';
      case SubscriptionTier.gold:
        return 'Gold';
      case SubscriptionTier.platinum:
        return 'Platinum';
    }
  }

  int get level {
    switch (this) {
      case SubscriptionTier.silver:
        return 1;
      case SubscriptionTier.gold:
        return 2;
      case SubscriptionTier.platinum:
        return 3;
    }
  }
}
