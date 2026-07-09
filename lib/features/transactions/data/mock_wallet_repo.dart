import 'dart:math';
import 'package:eazywallet/core/errors/wallet_exception.dart';
import 'package:eazywallet/features/transactions/domain/report_transaction_model.dart';
import 'package:eazywallet/features/transactions/domain/transaction_model.dart';
import 'package:eazywallet/features/transactions/domain/user_model.dart';
import 'package:eazywallet/features/transactions/domain/wallet_repo.dart';

class MockWalletRepository implements WalletRepository {
  MockWalletRepository({
    Duration? networkDelay,
    Random? random,
    this.forceDashboardError = false,
    this.forceServerError = false,
  })  : networkDelay = networkDelay ?? const Duration(seconds: 1),
        random = random ?? Random();

  final Duration networkDelay;
  final Random random;

  bool forceDashboardError;

  bool forceServerError;

  static const String correctPin = '1234';
  static const int maxPinAttempts = 3;

  static const double randomServerFailureChance = 0.08;

  int pinAttempts = 0;
  
  @override
  bool get isPinLocked => pinAttempts >= maxPinAttempts;

  final UserModel user = UserModel(
    name: 'Chidi',
    walletBalance: 250000.75,
    kycLevel: 'Tier 2',
  );

  final List<TransactionModel> transactions = [
    TransactionModel(
      id: 'txn_001',
      reference: 'PG-20260707-001',
      title: 'Wallet Funding',
      amount: 50000,
      fee: 0,
      type: TransactionType.walletFunding,
      status: TransactionStatus.successful,
      direction: TransactionDirection.credit,
      description: 'Wallet funded via bank transfer',
      date: DateTime.parse('2026-07-07T10:30:00Z'),
      hasActiveReport: false,
    ),
    TransactionModel(
      id: 'txn_002',
      reference: 'PG-20260707-002',
      title: 'Withdrawal',
      amount: 20000,
      fee: 100,
      type: TransactionType.withdrawal,
      status: TransactionStatus.pending,
      direction: TransactionDirection.debit,
      description: 'Withdrawal to saved bank account',
      date: DateTime.parse('2026-07-07T12:10:00Z'),
      hasActiveReport: false,
    ),
    TransactionModel(
      id: 'txn_003',
      reference: 'PG-20260707-003',
      title: 'Gift Card Trade',
      amount: 85000,
      fee: 0,
      type: TransactionType.giftCardTrade,
      status: TransactionStatus.failed,
      direction: TransactionDirection.credit,
      description: 'Gift card trade payout',
      date: DateTime.parse('2026-07-06T09:15:00Z'),
      hasActiveReport: false,
    ),
    TransactionModel(
      id: 'txn_004',
      reference: 'PG-20260707-004',
      title: 'Crypto Trade',
      amount: 120000,
      fee: 500,
      type: TransactionType.cryptoTrade,
      status: TransactionStatus.successful,
      direction: TransactionDirection.credit,
      description: 'Crypto sale payout',
      date: DateTime.parse('2026-07-05T16:45:00Z'),
      hasActiveReport: true,
    ),
    TransactionModel(
      id: 'txn_005',
      reference: 'PG-20260704-005',
      title: 'Withdrawal',
      amount: 15000,
      fee: 50,
      type: TransactionType.withdrawal,
      status: TransactionStatus.reversed,
      direction: TransactionDirection.debit,
      description: 'Withdrawal reversed by bank',
      date: DateTime.parse('2026-07-04T08:00:00Z'),
      hasActiveReport: false,
    ),
  ];

  int reportIdCounter = 0;

  Future<void> delay() => Future.delayed(networkDelay);

  @override
  Future<UserModel> fetchDashboard() async {
    await delay();
    if (forceDashboardError) {
      throw const WalletException(
        WalletErrorType.network,
        'Error loading dashbord. Please try again.',
      );
    }
    return user;
  }

  @override
  Future<List<TransactionModel>> fetchTransactions() async {
    await delay();
    return List.unmodifiable(transactions);
  }

  @override
  Future<TransactionModel> fetchTransactionById(String id) async {
    await delay();
    final transaction = findById(id);
    if (transaction == null) {
      throw const WalletException(
        WalletErrorType.notFound,
        'Transaction not found.',
      );
    }
    return transaction;
  }

  @override
  Future<ReportTransactionModel> submitTransactionReport({
    required String transactionId,
    required ReportReason reason,
    required String description,
  }) async {
    await delay();

    final transaction = findById(transactionId);
    if (transaction == null) {
      throw const WalletException(
        WalletErrorType.notFound,
        'Transaction not found.',
      );
    }

    if (transaction.hasActiveReport) {
      throw const WalletException(
        WalletErrorType.duplicateReport,
        'This transaction already has an active report.',
      );
    }

    if (!isEligibleStatus(transaction.status)) {
      throw WalletException(
        WalletErrorType.ineligibleForReport,
        'This transaction cannot be reported because it ${statusReason(transaction.status)}.',
      );
    }

    if (forceServerError || random.nextDouble() < randomServerFailureChance) {
      forceServerError = false;
      throw const WalletException(
        WalletErrorType.server,
        'Something went wrong on our end. Please try again.',
      );
    }

    final index = transactions.indexWhere((t) => t.id == transactionId);
    transactions[index] = transaction.copyWith(hasActiveReport: true);

    reportIdCounter += 1;
    return ReportTransactionModel(
      id: 'report_$reportIdCounter',
      transactionId: transactionId,
      reason: reason,
      description: description,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<bool> verifyTransactionPin(String pin) async {
    await delay();

    if (isPinLocked) {
      throw const WalletException(
        WalletErrorType.pinLocked,
        'Too many wrong attempts. PIN entry is locked.',
      );
    }

    if (pin != correctPin) {
      pinAttempts += 1;
      if (isPinLocked) {
        throw const WalletException(
          WalletErrorType.pinLocked,
          'Too many wrong attempts. PIN entry is locked.',
        );
      }
      throw const WalletException(
        WalletErrorType.invalidPin,
        'Incorrect PIN. Please try again.',
      );
    }

    pinAttempts = 0;
    return true;
  }

  TransactionModel? findById(String id) {
    for (final transaction in transactions) {
      if (transaction.id == id) return transaction;
    }
    return null;
  }

  bool isEligibleStatus(TransactionStatus status) {
    return status == TransactionStatus.successful ||
        status == TransactionStatus.pending;
  }

  String statusReason(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.failed:
        return 'failed';
      case TransactionStatus.reversed:
        return 'was reversed';
      default:
        return 'is not eligible for reporting';
    }
  }
}
