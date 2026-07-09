import 'package:eazywallet/core/errors/wallet_exception.dart';
import 'package:eazywallet/features/transactions/domain/transaction_model.dart';
import 'package:eazywallet/features/transactions/domain/user_model.dart';
import 'package:eazywallet/features/transactions/domain/wallet_repo.dart';
import 'package:mobx/mobx.dart';

class DashboardStore {
  DashboardStore(this.repository);

  final WalletRepository repository;

  final Observable<UserModel?> user = Observable(null);
  final ObservableList<TransactionModel> transactions = ObservableList<TransactionModel>();
  final Observable<bool> isLoading = Observable(false);
  final Observable<String?> errorMessage = Observable(null);

  late final Computed<bool> isEmpty = Computed(
    () => !isLoading.value && errorMessage.value == null && transactions.isEmpty,
  );

  Future<void> load() async {
    runInAction(() {
      isLoading.value = true;
      errorMessage.value = null;
    });

    try {
      final fetchedUser = await repository.fetchDashboard();
      final fetchedTransactions = await repository.fetchTransactions();

      runInAction(() {
        user.value = fetchedUser;
        transactions
          ..clear()
          ..addAll(fetchedTransactions);
        isLoading.value = false;
      });
    } on WalletException catch (e) {
      runInAction(() {
        errorMessage.value = e.message;
        isLoading.value = false;
      });
    }
  }

  Future<void> refresh() => load();
}
