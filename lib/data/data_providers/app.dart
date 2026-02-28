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
      home: const AppView(),
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
