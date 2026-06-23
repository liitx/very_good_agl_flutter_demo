import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';

import 'export.dart';
import 'data/data_providers/mock_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use the fonts bundled in assets (fonts/google_fonts/) instead of fetching
  // from fonts.gstatic.com. The AGL device has no network, so fetching only
  // produced errors and fallback fonts; the bundled fonts render offline.
  GoogleFonts.config.allowRuntimeFetching = false;

  final container = ProviderContainer();

  if (useMockData) {
    // Offline demo mode: do not touch any AGL backend. Seed canned data so the
    // UI renders fully with zero external services. Reading the *ClientProviders
    // is deliberately skipped so no gRPC channels are ever opened.
    debugPrint(
        'MOCK_DATA enabled: seeding canned data, skipping backend connections.');
    seedMockData(container);
  } else {
    // Start asynchronously connecting to API provider backends
    container.read(storageClientProvider).connect();
    container.read(valClientProvider).connect();
    container.read(radioClientProvider).connect();
    container.read(mpdClientProvider).connect();
  }

  // Pass the container to ProviderScope and then run the app.
  runApp(
    ProviderScope(
      parent: container,
      child: DevicePreview(
        enabled: debugDisplay,
        tools: const [
          ...DevicePreview.defaultTools,
        ],
        builder: (context) => const App(),
      ),
    ),
  );
}
