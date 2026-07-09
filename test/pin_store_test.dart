import 'package:eazywallet/core/errors/wallet_exception.dart';
import 'package:eazywallet/features/transactions/application/pin_store.dart';
import 'package:eazywallet/features/transactions/domain/wallet_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'pin_store_test.mocks.dart';

@GenerateNiceMocks([MockSpec<WalletRepository>()])
void main() {
  late PinStore store;
  late MockWalletRepository mockRepository;

  setUp(() {
    mockRepository = MockWalletRepository();
    when(mockRepository.isPinLocked).thenReturn(false);
    store = PinStore(mockRepository);
  });

  group('PIN Verification & Wrong Attempt Logic Tests', () {
    test('Successful verification clears the PIN and returns true', () async {
      store.setPin('1234');
      when(mockRepository.verifyTransactionPin('1234'))
          .thenAnswer((_) async => true);

      final result = await store.verify();

      expect(result, isTrue);
      expect(store.isVerifying.value, isFalse);
      expect(store.pin.value, '');
      expect(store.errorMessage.value, isNull);
    });

    test(
      'Wrong PIN attempt handles standard WalletException without locking',
      () async {
        store.setPin('1111');
        const wrongPinMessage = 'Incorrect PIN. 2 attempts remaining.';

        when(mockRepository.verifyTransactionPin('1111')).thenThrow(
          WalletException(WalletErrorType.invalidPin, wrongPinMessage),
        );

        final result = await store.verify();

        expect(result, isFalse);
        expect(store.isVerifying.value, isFalse);
        expect(store.pin.value, '');
        expect(store.errorMessage.value, wrongPinMessage);
        expect(store.isLocked.value, isFalse);
      },
    );

    test(
      'Wrong PIN attempt that exceeds limits changes store state to locked',
      () async {
        store.setPin('9999');
        const lockedMessage =
            'Too many incorrect attempts. Your PIN has been locked.';

        when(mockRepository.verifyTransactionPin('9999')).thenThrow(
          WalletException(WalletErrorType.pinLocked, lockedMessage),
        );

        final result = await store.verify();

        expect(result, isFalse);
        expect(store.isVerifying.value, isFalse);
        expect(store.pin.value, '');
        expect(store.errorMessage.value, lockedMessage);
        expect(store.isLocked.value, isTrue);
      },
    );
  });
}