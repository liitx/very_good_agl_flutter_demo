import '../../export.dart';

final homeScreenProvider = Provider((ref) {
  final Map<String, String> envVars = Platform.environment;
  final ciFlagStr = envVars['HOMESCREEN_DEMO_CI'];
  final bool ciFlag = ciFlagStr != null && ciFlagStr != "0";
  return ciFlag ? const HomeScreenCI() : const HomeScreen();
});

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      showPerformanceOverlay: debugShowPerformanceOverlay,
      theme: theme,
      // Scale the whole UI uniformly to whatever window/display it runs on.
      builder: (context, child) => DesignScaler(child: child!),
      home: const AppView(),
    );
  }
}

/// Locks the UI to its authored design size and scales it uniformly to the
/// actual window/display with [BoxFit.contain], letterboxing in black. This
/// makes every screen render at a stable logical size, so layouts cannot throw
/// RenderFlex overflow regardless of the real window or panel resolution, and
/// the app fills the screen 1:1 when run fullscreen.
///
/// Design size defaults to the homescreen's authored 1080x1920 (portrait IVI).
/// Override for landscape/other panels with `ICS_DESIGN_SIZE=WxH`, e.g.
///   ICS_DESIGN_SIZE=1920x1080 ./scripts/run.sh
class DesignScaler extends StatelessWidget {
  const DesignScaler({super.key, required this.child});
  final Widget child;

  static final Size designSize = _resolveDesignSize();

  static Size _resolveDesignSize() {
    final env = Platform.environment['ICS_DESIGN_SIZE'];
    if (env != null) {
      final m = RegExp(r'^(\d+)x(\d+)$').firstMatch(env.trim());
      if (m != null) {
        return Size(
            double.parse(m.group(1)!), double.parse(m.group(2)!));
      }
    }
    return const Size(1080, 1920);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: designSize.width,
            height: designSize.height,
            // Report the design size to descendants so MediaQuery-based layout
            // (e.g. size.height * 0.82) is consistent at any scale.
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(size: designSize),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class AppView extends ConsumerWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(homeScreenProvider);
  }
}
