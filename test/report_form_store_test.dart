import 'package:eazywallet/core/errors/wallet_exception.dart';
import 'package:eazywallet/features/transactions/application/report_form_store.dart';
import 'package:eazywallet/features/transactions/domain/report_transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:eazywallet/features/transactions/domain/wallet_repo.dart';

import 'report_form_store_test.mocks.dart';

@GenerateNiceMocks([MockSpec<WalletRepository>()])
void main() {
  late ReportFormStore store;
  late MockWalletRepository mockRepository;
  const testTransactionId = 'tx_12345';
  const validDescription = 'Valid description text of twenty chars';

  setUp(() {
    mockRepository = MockWalletRepository();
    store = ReportFormStore(mockRepository, testTransactionId);
  });

  group('Report form validation', () {
    test('is invalid with no reason and no description', () {
      expect(store.isValid.value, isFalse);
    });

    test('description must meet min/max length bounds', () {
      store.setDescription('Too short text here'); // 19 chars
      expect(store.isDescriptionValid.value, isFalse);

      store.setDescription(validDescription); // 20+ chars
      expect(store.isDescriptionValid.value, isTrue);

      store.setDescription('a' * 251); // over max
      expect(store.isDescriptionValid.value, isFalse);
    });

    test(
      'form is valid only when reason AND valid description are both set',
      () {
        store.setDescription(validDescription);
        expect(store.isValid.value, isFalse); // no reason yet

        store.setReason(ReportReason.suspectedFraud);
        store.setDescription('Short');
        expect(
          store.isValid.value,
          isFalse,
        ); // reason ok, description too short

        store.setDescription(validDescription);
        expect(store.isValid.value, isTrue); // both satisfied
      },
    );
  });

  group('Transaction report eligibility logic', () {
    test(
      'submit() is blocked and repository is never called when form is invalid',
      () async {
        final result = await store.submit();

        expect(result, isFalse);
        verifyNever(
          mockRepository.submitTransactionReport(
            transactionId: anyNamed('transactionId'),
            reason: anyNamed('reason'),
            description: anyNamed('description'),
          ),
        );
      },
    );

    test('eligible submit calls repository and sets success state', () async {
      store.setReason(ReportReason.suspectedFraud);
      store.setDescription(validDescription);

      when(
        mockRepository.submitTransactionReport(
          transactionId: testTransactionId,
          reason: ReportReason.suspectedFraud,
          description: validDescription,
        ),
      ).thenAnswer((_) async {
        return ReportTransactionModel(
          id: 'report_1',
          createdAt: DateTime.now(),
          transactionId: testTransactionId,
          reason: ReportReason.suspectedFraud,
          description: validDescription,
        );
      });

      final result = await store.submit();

      expect(result, isTrue);
      expect(store.isSuccess.value, isTrue);
      expect(store.isSubmitting.value, isFalse);
      expect(store.errorMessage.value, isNull);
    });

    test(
      'eligible submit that fails sets errorMessage, not isSuccess',
      () async {
        store.setReason(ReportReason.suspectedFraud);
        store.setDescription(validDescription);

        const errorText = 'Unable to submit report. Please try again.';
        when(
          mockRepository.submitTransactionReport(
            transactionId: anyNamed('transactionId'),
            reason: anyNamed('reason'),
            description: anyNamed('description'),
          ),
        ).thenThrow(WalletException(WalletErrorType.server, errorText));

        final result = await store.submit();

        expect(result, isFalse);
        expect(store.isSuccess.value, isFalse);
        expect(store.isSubmitting.value, isFalse);
        expect(store.errorMessage.value, errorText);
      },
    );
  });
}
