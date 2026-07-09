import 'package:eazywallet/core/errors/wallet_exception.dart';
import 'package:eazywallet/features/transactions/domain/report_transaction_model.dart';
import 'package:eazywallet/features/transactions/domain/wallet_repo.dart';
import 'package:mobx/mobx.dart';

class ReportFormStore {
  ReportFormStore(this.repository, this.transactionId);

  final WalletRepository repository;
  final String transactionId;

  static const int minDescriptionLength = 20;
  static const int maxDescriptionLength = 250;

  final Observable<ReportReason?> reason = Observable(null);
  final Observable<String> description = Observable('');
  final Observable<bool> isSubmitting = Observable(false);
  final Observable<String?> errorMessage = Observable(null);
  final Observable<bool> isSuccess = Observable(false);

  late final Computed<bool> isDescriptionValid = Computed(
    () => description.value.trim().length >= minDescriptionLength &&
        description.value.trim().length <= maxDescriptionLength,
  );

  late final Computed<bool> isValid = Computed(
    () => reason.value != null && isDescriptionValid.value,
  );

  void setReason(ReportReason value) {
    runInAction(() => reason.value = value);
  }

  void setDescription(String value) {
    runInAction(() => description.value = value);
  }

  Future<bool> submit() async {
    if (!isValid.value || isSubmitting.value) return false;

    runInAction(() {
      isSubmitting.value = true;
      errorMessage.value = null;
    });

    try {
      await repository.submitTransactionReport(
        transactionId: transactionId,
        reason: reason.value!,
        description: description.value.trim(),
      );
      runInAction(() {
        isSubmitting.value = false;
        isSuccess.value = true;
      });
      return true;
    } on WalletException catch (e) {
      runInAction(() {
        isSubmitting.value = false;
        errorMessage.value = e.message;
      });
      return false;
    }
  }

  void reset() {
    runInAction(() {
      reason.value = null;
      description.value = '';
      isSubmitting.value = false;
      errorMessage.value = null;
      isSuccess.value = false;
    });
  }
}
