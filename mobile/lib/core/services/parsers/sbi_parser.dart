import '../../../features/sms/domain/entities/upi_transaction.dart';
import 'bank_parser.dart';

/// SBI (State Bank of India) specific SMS parser
/// Handles all SBI variants including SBIUPI, SBIINB, etc.
class SbiParser extends BankParser {
  @override
  String get bankName => 'State Bank of India';
  
  @override
  List<String> get senderIds => [
    'SBI',
    'SBIUPI',
    'SBIINB',
    'SBMSMS',
    'CBSSBI',
    'VM-SBIUPI',
    'VA-SBIUPI',
    'AD-SBIUPI',
    'JD-SBIBNK',
  ];
  
  @override
  bool canHandle({required String sender, required String message}) {
    final upperSender = sender.toUpperCase();
    final normalizedSender = upperSender.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    // Check sender ID - must contain SBI
    for (var id in senderIds) {
      if (normalizedSender.contains(id)) {
        return true;
      }
    }
    
    // Fallback: check message content
    final upperMessage = message.toUpperCase();
    return upperMessage.contains('SBI') || 
           upperMessage.contains('STATE BANK');
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
    
    // Extract transaction date from SBI-specific patterns
    DateTime? transactionDate = timestamp;
    final datePattern = RegExp(r'on date (\d{2})([A-Za-z]{3})(\d{2})', caseSensitive: false);
    final dateMatch = datePattern.firstMatch(message);
    if (dateMatch != null) {
      try {
        final day = int.parse(dateMatch.group(1)!);
        final monthStr = dateMatch.group(2)!;
        final yearStr = dateMatch.group(3)!;
        
        final monthMap = {
          'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
          'may': 5, 'jun': 6, 'jul': 7, 'aug': 8,
          'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
        };
        final month = monthMap[monthStr.toLowerCase()] ?? DateTime.now().month;
        final year = 2000 + int.parse(yearStr);
        
        transactionDate = DateTime(year, month, day);
      } catch (e) {
        // Keep using SMS timestamp as fallback
      }
    }
    
    return UpiTransaction(
      amount: amount,
      merchant: merchant,
      upiId: upiId,
      transactionId: transactionId,
      timestamp: transactionDate ?? DateTime.now(),
      type: type,
      balance: balance,
      bankName: bankName,
      accountNumber: accountNumber,
      rawMessage: message,
    );
  }
}
