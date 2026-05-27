import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/user_profile.dart';
import 'total_rewards_card.dart';
import 'todays_usage_card.dart';

/// Swipeable summary cards — rewards always; usage only when meter is online.
class DashboardSummaryCarousel extends StatefulWidget {
  final UserProfile? profile;
  final TodayUsageStats? usage;
  final bool profileLoading;
  final bool usageLoading;
  final bool isMeterOnline;

  const DashboardSummaryCarousel({
    super.key,
    this.profile,
    this.usage,
    this.profileLoading = false,
    this.usageLoading = false,
    required this.isMeterOnline,
  });

  @override
  State<DashboardSummaryCarousel> createState() =>
      _DashboardSummaryCarouselState();
}

class _DashboardSummaryCarouselState extends State<DashboardSummaryCarousel> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _pageCount => widget.isMeterOnline ? 2 : 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 132,
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: AppDimensions.sm),
                child: TotalRewardsCard(
                  profile: widget.profile,
                  isLoading: widget.profileLoading,
                  compact: true,
                ),
              ),
              if (widget.isMeterOnline)
                Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.sm),
                  child: TodaysUsageCard(
                    stats: widget.usage,
                    isLoading: widget.usageLoading,
                    compact: true,
                  ),
                ),
            ],
          ),
        ),
        if (_pageCount > 1) ...[
          const SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pageCount, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? AppColors.gold : AppColors.divider,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
