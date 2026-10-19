import 'package:flutter_test/flutter_test.dart';
import 'package:herokudroid/data/models/app_update.dart';
import 'package:herokudroid/data/services/update_service.dart';
import 'package:herokudroid/presentation/providers/update_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeUpdateService extends UpdateService {
  _FakeUpdateService({this.result, this.error});

  final AppUpdate? result;
  final Object? error;

  @override
  Future<AppUpdate?> fetchLatest() async {
    if (error != null) throw error!;
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    PackageInfo.setMockInitialValues(
      appName: 'HerokuDroid',
      packageName: 'com.phoenixdev.herokudroid',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  UpdateProvider providerWith(UpdateService service) =>
      UpdateProvider(service: service, prefs: prefs);

  test('reads the installed version from package metadata', () async {
    final provider = providerWith(_FakeUpdateService());

    await provider.init();

    expect(provider.currentVersion, '1.0.0');
  });

  test('reports no update when the latest version matches', () async {
    final provider = providerWith(
      _FakeUpdateService(result: const AppUpdate(version: '1.0.0')),
    );

    expect(await provider.checkForUpdates(), isFalse);
    expect(provider.hasUpdate, isFalse);
  });

  test('reports an update when a newer version is published', () async {
    final provider = providerWith(
      _FakeUpdateService(
        result: const AppUpdate(
          version: '1.1.0',
          downloadUrl: 'https://example.com/app.apk',
        ),
      ),
    );

    expect(await provider.checkForUpdates(), isTrue);
    expect(provider.availableUpdate!.version, '1.1.0');
    expect(provider.shouldPrompt, isTrue);
  });

  test('dismissPrompt stops the launch prompt for that version', () async {
    final provider = providerWith(
      _FakeUpdateService(result: const AppUpdate(version: '1.1.0')),
    );
    await provider.checkForUpdates();

    await provider.dismissPrompt();

    expect(provider.shouldPrompt, isFalse);
  });

  test('silent failures do not surface an error', () async {
    final provider = providerWith(
      _FakeUpdateService(error: Exception('network')),
    );

    expect(await provider.checkForUpdates(silent: true), isFalse);
    expect(provider.error, isNull);
  });

  test('non-silent failures surface an error', () async {
    final provider = providerWith(
      _FakeUpdateService(error: Exception('network')),
    );

    expect(await provider.checkForUpdates(), isFalse);
    expect(provider.error, isNotNull);
  });
}
