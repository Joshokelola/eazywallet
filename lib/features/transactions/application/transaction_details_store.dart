import 'package:eazywallet/core/errors/wallet_exception.dart';
import 'package:eazywallet/features/transactions/domain/transaction_model.dart';
import 'package:eazywallet/features/transactions/domain/wallet_repo.dart';
import 'package:mobx/mobx.dart';

class TransactionDetailsStore {
  TransactionDetailsStore(this.repository, this.transactionId);

  final WalletRepository repository;
  final String transactionId;

  final Observable<TransactionModel?> transaction = Observable(null);
  final Observable<bool> isLoading = Observable(false);
  final Observable<String?> errorMessage = Observable(null);

  late final Computed<bool> canReport = Computed(() {
    final current = transaction.value;
    if (current == null) return false;
    final eligibleStatus = current.status == TransactionStatus.successful ||
        current.status == TransactionStatus.pending;
    return eligibleStatus && !current.hasActiveReport;
  });

  late final Computed<String?> ineligibleReason = Computed(() {
    final current = transaction.value;
    if (current == null || canReport.value) return null;

    if (current.hasActiveReport) {
      return 'This transaction already has an active report.';
    }

    switch (current.status) {
      case TransactionStatus.failed:
        return 'This transaction cannot be reported because it failed.';
      case TransactionStatus.reversed:
        return 'This transaction cannot be reported because it was reversed.';
      default:
        return 'This transaction cannot be reported.';
    }
  });

  Future<void> load() async {
    runInAction(() {
      isLoading.value = true;
      errorMessage.value = null;
    });

    try {
      final result = await repository.fetchTransactionById(transactionId);
      runInAction(() {
        transaction.value = result;
        isLoading.value = false;
      });
    } on WalletException catch (e) {
      runInAction(() {
        errorMessage.value = e.message;
        isLoading.value = false;
      });
    }
  }

  void markReported() {
    final current = transaction.value;
    if (current == null) return;
    runInAction(() {
      transaction.value = current.copyWith(hasActiveReport: true);
    });
  }
}
