import 'package:go_nomads_app/features/membership/domain/entities/membership_level.dart';
import 'package:go_nomads_app/features/membership/domain/entities/user_membership.dart';

class AppleIapMembershipProduct {
  final String productId;
  final MembershipLevel level;
  final BillingCycle billingCycle;

  const AppleIapMembershipProduct({
    required this.productId,
    required this.level,
    required this.billingCycle,
  });
}

class AppleIapProductCatalog {
  static const List<AppleIapMembershipProduct> membershipProducts = [
    AppleIapMembershipProduct(
      productId: 'com.gonomads.membership.basic.monthly',
      level: MembershipLevel.basic,
      billingCycle: BillingCycle.monthly,
    ),
    AppleIapMembershipProduct(
      productId: 'com.gonomads.membership.basic.yearly',
      level: MembershipLevel.basic,
      billingCycle: BillingCycle.yearly,
    ),
    AppleIapMembershipProduct(
      productId: 'com.gonomads.membership.pro.monthly',
      level: MembershipLevel.pro,
      billingCycle: BillingCycle.monthly,
    ),
    AppleIapMembershipProduct(
      productId: 'com.gonomads.membership.pro.yearly',
      level: MembershipLevel.pro,
      billingCycle: BillingCycle.yearly,
    ),
    AppleIapMembershipProduct(
      productId: 'com.gonomads.membership.premium.monthly',
      level: MembershipLevel.premium,
      billingCycle: BillingCycle.monthly,
    ),
    AppleIapMembershipProduct(
      productId: 'com.gonomads.membership.premium.yearly',
      level: MembershipLevel.premium,
      billingCycle: BillingCycle.yearly,
    ),
  ];

  static Set<String> get productIds => membershipProducts.map((item) => item.productId).toSet();

  static AppleIapMembershipProduct? forPlan(
    MembershipLevel level,
    BillingCycle billingCycle,
  ) {
    for (final item in membershipProducts) {
      if (item.level == level && item.billingCycle == billingCycle) {
        return item;
      }
    }
    return null;
  }

  static AppleIapMembershipProduct? fromProductId(String productId) {
    for (final item in membershipProducts) {
      if (item.productId == productId) {
        return item;
      }
    }
    return null;
  }
}