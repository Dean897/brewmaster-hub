import 'package:brewmaster_hub/core/services/brew_points_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await BrewPointsService.instance.ensureLoaded();
  });

  test('Initial extra points should be 0', () {
    expect(BrewPointsService.instance.totalExtraPoints, 0);
    expect(BrewPointsService.instance.pourOverCount, 0);
  });

  test('addPourOverPoint adds 1 point and notifies listeners', () async {
    int notifiedValue = -1;
    BrewPointsService.instance.extraPointsNotifier.addListener(() {
      notifiedValue = BrewPointsService.instance.extraPointsNotifier.value;
    });

    await BrewPointsService.instance.addPourOverPoint();

    expect(BrewPointsService.instance.pourOverCount, 1);
    expect(BrewPointsService.instance.totalExtraPoints, 1);
    expect(notifiedValue, 1);

    // Add another pour over point
    await BrewPointsService.instance.addPourOverPoint();
    expect(BrewPointsService.instance.pourOverCount, 2);
    expect(BrewPointsService.instance.totalExtraPoints, 2);
    expect(notifiedValue, 2);
  });
}
