import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herokudroid/data/services/app_lock_service.dart';
import 'package:herokudroid/data/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLockService service;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    service = AppLockService(storage: SecureStorageService());
  });

  group('AppLockService password', () {
    test('hasPassword is false before a password is set', () async {
      expect(await service.hasPassword(), isFalse);
    });

    test('verifies the correct password and rejects others', () async {
      await service.setPassword('correct horse');

      expect(await service.hasPassword(), isTrue);
      expect(await service.verifyPassword('correct horse'), isTrue);
      expect(await service.verifyPassword('wrong password'), isFalse);
    });

    test('uses a random salt so equal passwords hash differently', () async {
      await service.setPassword('same-password');
      final first = await service.verifyPassword('same-password');

      await service.setPassword('same-password');
      final second = await service.verifyPassword('same-password');

      expect(first, isTrue);
      expect(second, isTrue);
    });

    test('clearPassword removes the credential', () async {
      await service.setPassword('secret');
      await service.clearPassword();

      expect(await service.hasPassword(), isFalse);
      expect(await service.verifyPassword('secret'), isFalse);
    });
  });

  group('AppLockService settings', () {
    test('defaults to disabled', () async {
      expect(await service.isLockEnabled(), isFalse);
      expect(await service.isBiometricsEnabled(), isFalse);
    });

    test('persists lock and biometric toggles', () async {
      await service.setLockEnabled(true);
      await service.setBiometricsEnabled(true);

      expect(await service.isLockEnabled(), isTrue);
      expect(await service.isBiometricsEnabled(), isTrue);
    });
  });
}
