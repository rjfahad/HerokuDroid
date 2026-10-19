import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herokudroid/data/services/app_lock_service.dart';
import 'package:herokudroid/data/services/secure_storage_service.dart';
import 'package:herokudroid/presentation/providers/app_lock_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLockService service;
  late AppLockProvider provider;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    service = AppLockService(storage: SecureStorageService());
    provider = AppLockProvider(service: service);
  });

  test('starts unlocked and ready when the lock is disabled', () async {
    await provider.init();

    expect(provider.isReady, isTrue);
    expect(provider.isLocked, isFalse);
  });

  test('locks on init when the lock is enabled', () async {
    await service.setPassword('abcd');
    await service.setLockEnabled(true);

    await provider.init();

    expect(provider.isLocked, isTrue);
  });

  test('enableLock rejects passwords under the minimum length', () async {
    final ok = await provider.enableLock('12');

    expect(ok, isFalse);
    expect(provider.lockEnabled, isFalse);
    expect(provider.error, isNotNull);
  });

  test('enable, lock, then unlock with the password', () async {
    expect(await provider.enableLock('abcd'), isTrue);
    expect(provider.lockEnabled, isTrue);
    expect(provider.isLocked, isFalse);

    provider.lock();
    expect(provider.isLocked, isTrue);

    expect(await provider.unlockWithPassword('wrong'), isFalse);
    expect(provider.isLocked, isTrue);
    expect(provider.error, isNotNull);

    expect(await provider.unlockWithPassword('abcd'), isTrue);
    expect(provider.isLocked, isFalse);
  });

  test('disableLock clears the password and unlocks', () async {
    await provider.enableLock('abcd');
    provider.lock();

    await provider.disableLock();

    expect(provider.lockEnabled, isFalse);
    expect(provider.isLocked, isFalse);
    expect(await service.hasPassword(), isFalse);
  });

  test('lock is a no-op when the feature is disabled', () async {
    await provider.init();

    provider.lock();

    expect(provider.isLocked, isFalse);
  });

  test('biometrics cannot be enabled when unavailable', () async {
    await provider.enableLock('abcd');

    await provider.setBiometricsEnabled(true);

    expect(provider.biometricsAvailable, isFalse);
    expect(provider.biometricsEnabled, isFalse);
  });
}
