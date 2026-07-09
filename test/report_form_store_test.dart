import 'package:eazywallet/features/transactions/application/report_form_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:eazywallet/features/transactions/domain/report_transaction_model.dart';
import 'package:eazywallet/features/transactions/domain/wallet_repo.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late ReportFormStore store;
  late MockWalletRepository mockRepository;
  const String testTransactionId = 'tx_12345';

  setUp(() {
    mockRepository = MockWalletRepository();
    store = ReportFormStore(mockRepository, testTransactionId);
  });

  group('Report Form Validation Tests', () {
    test('Initial state should be invalid and empty', () {
      expect(store.reason.value, isNull);
      expect(store.description.value, '');
      expect(store.isDescriptionValid.value, isFalse);
      expect(store.isValid.value, isFalse);
    });

    test('Description validation should enforce min and max bounds', () {
      // Below min bound (19 characters)
      store.setDescription('Too short text here');
      expect(store.isDescriptionValid.value, isFalse);

      // Exactly minimum bound (20 characters)
      store.setDescription('Valid description 20');
      expect(store.isDescriptionValid.value, isTrue);

      // Within normal bounds
      store.setDescription('This is a completely valid report reason statement.');
      expect(store.isDescriptionValid.value, isTrue);

      // Exceeding max bound (>250 characters)
      store.setDescription('a' * 251);
      expect(store.isDescriptionValid.value, isFalse);
    });

    test('Form should only be valid when BOTH reason and valid description exist', () {
      // Case 1: Valid description but no reason
      store.setDescription('Valid description text of twenty chars');
      expect(store.isDescriptionValid.value, isTrue);
      expect(store.isValid.value, isFalse);

      // Case 2: Reason selected but invalid description
      store.setReason(ReportReason.suspectedFraud);
      store.setDescription('Short');
      expect(store.isValid.value, isFalse);

      // Case 3: Both conditions satisfied
      store.setDescription('Valid description text of twenty chars');
      expect(store.isValid.value, isTrue);
    });
  });
}