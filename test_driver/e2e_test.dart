import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Stock App', () {
    final searchButtonFinder = find.byValueKey('searchButton');
    final searchBarDriver = find.byValueKey('searchBar');

    FlutterDriver? driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver!.close();
      }
    });
    test('can search for stock and get value', () async {
      await driver!.tap(searchBarDriver);
      await driver!.enterText("AMZN");
      await driver!.tap(searchButtonFinder);
      final amznText = find.byValueKey("AMZN");
      expect(await driver!.getText(amznText), "AMZN");
    });

    Future<bool> isPresent(SerializableFinder finder, FlutterDriver driver,
        {Duration timeout = const Duration(seconds: 1)}) async {
      try {
        await driver.waitFor(finder, timeout: timeout);
        return true;
      } catch (e) {
        return false;
      }
    }

    test('invalid stock returns nothing', () async {
      await driver!.tap(searchBarDriver);
      await driver!.enterText("859");
      await driver!.tap(searchButtonFinder);
      final amznText = find.byValueKey("859");

      final exists = await isPresent(amznText, driver!);
      expect(exists, false);
    });
  });
}
