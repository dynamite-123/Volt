import '../../../features/sms/domain/entities/upi_transaction.dart';
import 'bank_parser.dart';

/// Paytm specific SMS parser
class PaytmParser extends BankParser {
  @override
  String get bankName => 'Paytm';
  
  @override
  List<String> get senderIds => [
    'PAYTM',
    'PYTM',
    'VM-PAYTM',
    'AD-PAYTM',
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
    return message.toUpperCase().contains('PAYTM');
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
    
    return UpiTransaction(
      amount: amount,
      merchant: merchant,
      upiId: upiId,
      transactionId: transactionId,
      timestamp: timestamp ?? DateTime.now(),
      type: type,
      balance: balance,
      bankName: bankName,
      accountNumber: null,
      rawMessage: message,
    );
  }
}
