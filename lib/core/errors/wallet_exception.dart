enum WalletErrorType {
  network,

  notFound,

  ineligibleForReport,

  duplicateReport,

  invalidPin,

  pinLocked,

  server,
}

class WalletException implements Exception {
  final WalletErrorType type;
  final String message;

  const WalletException(this.type, this.message);

  @override
  String toString() => 'WalletException(${type.name}): $message';
}
