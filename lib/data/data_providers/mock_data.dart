import 'package:flutter_ics_homescreen/export.dart';
import 'package:protos/val_api.dart';

/// Seeds the providers with canned vehicle + audio values so the homescreen
/// renders a complete demo with NO AGL backend services running.
///
/// Enabled by `--dart-define=MOCK_DATA=true` (see [useMockData]). Values are
/// pushed through the SAME `handleSignalUpdate` path that live KUKSA.val data
/// uses, so what you see in mock mode is exactly what a real databroker would
/// produce. This adds no fake rendering path and cannot drift from real data.
void seedMockData(ProviderContainer container) {
  final vehicle = container.read(vehicleProvider.notifier);
  final audio = container.read(audioStateProvider.notifier);

  // Builders mirror the Datapoint cascade style used in ValClient.
  DataEntry f(String path, double v) =>
      DataEntry()..path = path..value = (Datapoint()..float = v);
  DataEntry u(String path, int v) =>
      DataEntry()..path = path..value = (Datapoint()..uint32 = v);
  DataEntry i(String path, int v) =>
      DataEntry()..path = path..value = (Datapoint()..int32 = v);
  DataEntry b(String path, bool v) =>
      DataEntry()..path = path..value = (Datapoint()..bool_12 = v);

  // Dashboard + HVAC (types match VehicleNotifier.handleSignalUpdate).
  for (final e in <DataEntry>[
    f(VSSPath.vehicleSpeed, 64.0),
    u(VSSPath.vehicleEngineSpeed, 2200),
    f(VSSPath.vehicleInsideTemperature, 21.5),
    f(VSSPath.vehicleOutsideTemperature, 18.0),
    u(VSSPath.vehicleRange, 420),
    u(VSSPath.vehicleFuelLevel, 65),
    u(VSSPath.vehicleFrontLeftTire, 32),
    u(VSSPath.vehicleFrontRightTire, 32),
    u(VSSPath.vehicleRearLeftTire, 31),
    u(VSSPath.vehicleRearRightTire, 31),
    b(VSSPath.vehicleIsAirConditioningActive, true),
    b(VSSPath.vehicleIsFrontDefrosterActive, false),
    b(VSSPath.vehicleIsRearDefrosterActive, false),
    b(VSSPath.vehicleIsRecirculationActive, true),
    u(VSSPath.vehicleFanSpeed, 66),
    i(VSSPath.vehicleDriverTemperature, 21),
    i(VSSPath.vehiclePassengerTemperature, 22),
  ]) {
    vehicle.handleSignalUpdate(e);
  }

  // Audio (types match AudioNotifier.handleSignalUpdate).
  for (final e in <DataEntry>[
    u(VSSPath.vehicleMediaVolume, 30),
    i(VSSPath.vehicleMediaBalance, 0),
    i(VSSPath.vehicleMediaFade, 0),
    i(VSSPath.vehicleMediaBass, 0),
    i(VSSPath.vehicleMediaTreble, 0),
  ]) {
    audio.handleSignalUpdate(e);
  }
}
