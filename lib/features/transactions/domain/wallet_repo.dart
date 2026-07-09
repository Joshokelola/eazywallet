import 'package:eazywallet/features/transactions/domain/report_transaction_model.dart';
import 'package:eazywallet/features/transactions/domain/transaction_model.dart';
import 'package:eazywallet/features/transactions/domain/user_model.dart';

abstract class WalletRepository {
  Future<UserModel> fetchDashboard();

  Future<List<TransactionModel>> fetchTransactions();

  Future<TransactionModel> fetchTransactionById(String id);

  Future<ReportTransactionModel> submitTransactionReport({
    required String transactionId,
    required ReportReason reason,
    required String description,
  });

  Future<bool> verifyTransactionPin(String pin);

  bool get isPinLocked;
}
