import 'package:flutter_ics_homescreen/export.dart';

final hybridBackgroundProvider = Provider((ref) {
  return SvgPicture.asset('animations/hybrid_model/hybrid_bg.svg');
});

class HybridBackground extends ConsumerWidget {
  const HybridBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(hybridBackgroundProvider);
  }
}

final topArrowBlueProvider = Provider((ref) {
  return SvgPicture.asset('animations/hybrid_model/top_blue.svg');
});

final topArrowRedProvider = Provider((ref) {
  return Lottie.asset('animations/hybrid_model/top_arrow_red.json');
});

class TopArrow extends ConsumerWidget {
  const TopArrow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arrowState =
        ref.watch(hybridStateProvider.select((hybrid) => hybrid.topArrowState));
    Widget? widget;
    switch (arrowState) {
      case ArrowState.red:
        widget = ref.read(topArrowRedProvider);
        break;
      default:
        widget = ref.read(topArrowBlueProvider);
    }
    return Align(alignment: const Alignment(0, -0.75), child: widget);
  }
}

final leftArrowBlueProvider = Provider((ref) {
  return SvgPicture.asset('animations/hybrid_model/left_blue.svg');
});

final leftArrowRedProvider = Provider((ref) {
  return Lottie.asset('animations/hybrid_model/left_arrow_red.json');
});

class LeftArrow extends ConsumerWidget {
  const LeftArrow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arrowState = ref
        .watch(hybridStateProvider.select((hybrid) => hybrid.leftArrowState));
    Widget? widget;
    switch (arrowState) {
      case ArrowState.red:
        widget = ref.read(leftArrowRedProvider);
        break;
      default:
        widget = ref.read(leftArrowBlueProvider);
    }
    return Align(alignment: const Alignment(-0.7, 0.5), child: widget);
  }
}

final rightArrowBlueProvider = Provider((ref) {
  return SvgPicture.asset('animations/hybrid_model/right_blue.svg');
});

final rightArrowYellowProvider = Provider((ref) {
  return Lottie.asset('animations/hybrid_model/right_arrow_yellow.json');
});

final rightArrowGreenProvider = Provider((ref) {
  return Lottie.asset('animations/hybrid_model/right_arrow_green.json');
});

class RightArrow extends ConsumerWidget {
  const RightArrow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arrowState = ref
        .watch(hybridStateProvider.select((hybrid) => hybrid.rightArrowState));
    Widget? widget;
    switch (arrowState) {
      case ArrowState.yellow:
        widget = ref.read(rightArrowYellowProvider);
        break;
      case ArrowState.green:
        widget = ref.read(rightArrowGreenProvider);
        break;
      default:
        widget = ref.read(rightArrowBlueProvider);
    }
    return Align(alignment: const Alignment(0.70, 0.5), child: widget);
  }
}

final batteryWhiteProvider = Provider((ref) {
  return SvgPicture.asset('animations/hybrid_model/battery_white.svg');
});

final batteryRedProvider = Provider((ref) {
  return SvgPicture.asset('animations/hybrid_model/battery_red.svg');
});

final batteryGreenProvider = Provider((ref) {
  return SvgPicture.asset('animations/hybrid_model/battery_green.svg');
});

final batteryYellowProvider = Provider((ref) {
  return SvgPicture.asset('animations/hybrid_model/battery_yellow.svg');
});

final batteryOrangeProvider = Provider((ref) {
  return SvgPicture.asset('animations/hybrid_model/battery_orange.svg');
});

class BatteryHybrid extends ConsumerWidget {
  const BatteryHybrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryState =
        ref.watch(hybridStateProvider.select((hybrid) => hybrid.batteryState));
    Widget? widget;
    switch (batteryState) {
      case BatteryState.red:
        widget = ref.read(batteryRedProvider);
        break;
      case BatteryState.green:
        widget = ref.read(batteryGreenProvider);
        break;
      case BatteryState.yellow:
        widget = ref.read(batteryYellowProvider);
        break;
      case BatteryState.orange:
        widget = ref.read(batteryOrangeProvider);
        break;
      default:
        widget = ref.read(batteryWhiteProvider);
    }
    return Align(
      alignment: const Alignment(0, 0.8),
      child: widget,
    );
  }
}
