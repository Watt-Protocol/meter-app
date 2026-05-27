import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks bottom-tab transitions for directional slide animations.
class TabNavState {
  final int currentIndex;
  final int previousIndex;

  const TabNavState({
    this.currentIndex = 0,
    this.previousIndex = 0,
  });
}

class TabNavNotifier extends Notifier<TabNavState> {
  @override
  TabNavState build() => const TabNavState();

  void setIndices(int from, int to) {
    state = TabNavState(currentIndex: to, previousIndex: from);
  }

  void syncFromRoute(int index) {
    if (state.currentIndex == index) return;
    state = TabNavState(currentIndex: index, previousIndex: state.currentIndex);
  }
}

final tabNavigationProvider =
    NotifierProvider<TabNavNotifier, TabNavState>(TabNavNotifier.new);
