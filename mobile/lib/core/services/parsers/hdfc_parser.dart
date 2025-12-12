import '../../../features/sms/domain/entities/upi_transaction.dart';
import 'bank_parser.dart';

/// HDFC Bank specific SMS parser
class HdfcParser extends BankParser {
  @override
  String get bankName => 'HDFC Bank';
  
  @override
  List<String> get senderIds => [
    'HDFCBK',
    'HDFC',
    'HDFCBANK',
    'VM-HDFCBK',
    'AD-HDFCBK',
  ];
  
  @override
  bool canHandle({required String sender, required String message}) {
    final upperSender = sender.toUpperCase();
    final normalizedSender = upperSender.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    // Check sender ID
    for (var id in senderIds) {
      if (normalizedSender.contains(id)) {
        return true;
      }
    }
    
    // Fallback: check message content
    return message.toUpperCase().contains('HDFC');
  }
  
  @override
  UpiTransaction? parse(String message, {DateTime? timestamp, String? sender}) {
    final amount = extractAmount(message);
    if (amount == null) return null;
    
    final type = extractTransactionType(message);
    final merchant = extractMerchant(message);
    final upiId = extractUpiId(message);
    final transactionId = extractTransactionId(message);
    final balance = extractBalance(message);
    final accountNumber = extractAccountNumber(message);
    
    return UpiTransaction(
      amount: amount,
      merchant: merchant,
      upiId: upiId,
      transactionId: transactionId,
      timestamp: timestamp ?? DateTime.now(),
      type: type,
      balance: balance,
      bankName: bankName,
      accountNumber: accountNumber,
      rawMessage: message,
    );
  }
}
