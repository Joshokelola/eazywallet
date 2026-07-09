import 'package:eazywallet/core/errors/wallet_exception.dart';
import 'package:eazywallet/features/transactions/domain/wallet_repo.dart';
import 'package:mobx/mobx.dart';

class PinStore {
  PinStore(this.repository) {
    isLocked = Observable(repository.isPinLocked);
  }

  final WalletRepository repository;

  static const int pinLength = 4;

  final Observable<String> pin = Observable('');
  final Observable<bool> isVerifying = Observable(false);
  final Observable<String?> errorMessage = Observable(null);
  late final Observable<bool> isLocked;

  late final Computed<bool> isPinComplete = Computed(() => pin.value.length == pinLength);

  void setPin(String value) {
    runInAction(() {
      pin.value = value;
      errorMessage.value = null;
    });
  }

  void clear() {
    runInAction(() {
      pin.value = '';
      errorMessage.value = null;
    });
  }

  Future<bool> verify() async {
    if (isLocked.value || !isPinComplete.value || isVerifying.value) return false;

    final submittedPin = pin.value;

    runInAction(() {
      isVerifying.value = true;
    });

    try {
      await repository.verifyTransactionPin(submittedPin);
      runInAction(() {
        isVerifying.value = false;
        pin.value = '';
      });
      return true;
    } on WalletException catch (e) {
      runInAction(() {
        isVerifying.value = false;
        pin.value = '';
        errorMessage.value = e.message;
        if (e.type == WalletErrorType.pinLocked) {
          isLocked.value = true;
        }
      });
      return false;
    }
  }
}
