class DashboardMetrics {
  final int totalMembers;
  final int activeChits;
  final double monthlyCollection;
  final double pendingCollections;
  final int settledChits;
  final int defaulters;
  final int upcomingAuctions;

  const DashboardMetrics({
    required this.totalMembers,
    required this.activeChits,
    required this.monthlyCollection,
    required this.pendingCollections,
    required this.settledChits,
    required this.defaulters,
    required this.upcomingAuctions,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalMembers: (json['total_members'] as num?)?.toInt() ?? 0,
      activeChits: (json['active_chits'] as num?)?.toInt() ?? 0,
      monthlyCollection:
          (json['monthly_collection'] as num?)?.toDouble() ?? 0.0,
      pendingCollections:
          (json['pending_collections'] as num?)?.toDouble() ?? 0.0,
      settledChits: (json['settled_chits'] as num?)?.toInt() ?? 0,
      defaulters: (json['defaulters'] as num?)?.toInt() ?? 0,
      upcomingAuctions: (json['upcoming_auctions'] as num?)?.toInt() ?? 0,
    );
  }

  static const empty = DashboardMetrics(
    totalMembers: 0,
    activeChits: 0,
    monthlyCollection: 0,
    pendingCollections: 0,
    settledChits: 0,
    defaulters: 0,
    upcomingAuctions: 0,
  );
}
