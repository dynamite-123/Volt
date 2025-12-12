import '../../../features/sms/domain/entities/upi_transaction.dart';

/// Abstract interface for bank-specific SMS parsers
/// Each bank can implement its own parsing logic for better accuracy
abstract class BankParser {
  /// The name of the bank this parser handles
  String get bankName;
  
  /// List of sender IDs this parser can handle (e.g., 'HDFCBK', 'VM-HDFC')
  List<String> get senderIds;
  
  /// Check if this parser can handle the given message
  /// Returns true if the sender or message content matches this bank
  bool canHandle({required String sender, required String message});
  
  /// Parse the SMS message and extract transaction details
  /// Returns null if the message cannot be parsed
  UpiTransaction? parse(String message, {DateTime? timestamp, String? sender});
  
  /// Extract amount from message (helper for subclasses)
  String? extractAmount(String message) {
    // Try multiple patterns
    final patterns = [
      RegExp(r'(?:RS\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
      RegExp(r'(?:debited|credited|paid|received)\s+(?:by|of|for)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return match.group(1)?.replaceAll(',', '');
      }
    }
    return null;
  }
  
  /// Extract transaction type from message (helper for subclasses)
  TransactionType extractTransactionType(String message) {
    final upperMessage = message.toUpperCase();
    
    // Credit patterns
    if (upperMessage.contains('CREDITED') || 
        upperMessage.contains('CREDIT TO') ||
        upperMessage.contains('RECEIVED') ||
        upperMessage.contains('DEPOSITED') ||
        upperMessage.contains('REFUND') ||
        upperMessage.contains('CASHBACK')) {
      return TransactionType.credit;
    }
    
    // Debit patterns
    if (upperMessage.contains('DEBITED') || 
        upperMessage.contains('DEBIT FROM') ||
        upperMessage.contains('WITHDRAWN') ||
        upperMessage.contains('PAID TO') ||
        upperMessage.contains('PAID AT') ||
        upperMessage.contains('YOU PAID') ||
        upperMessage.contains('PAID RS') ||
        upperMessage.contains('PURCHASE')) {
      return TransactionType.debit;
    }
    
    return TransactionType.unknown;
  }
  
  /// Extract UPI ID from message (helper for subclasses)
  String? extractUpiId(String message) {
    final pattern = RegExp(r'([a-zA-Z0-9.\-_]+@[a-zA-Z]+)', caseSensitive: false);
    final match = pattern.firstMatch(message);
    return match?.group(1);
  }
  
  /// Extract transaction reference number (helper for subclasses)
  String? extractTransactionId(String message) {
    final patterns = [
      RegExp(r'(?:UPI Txn ID|UPI Ref No|Ref No|RefNo|Refno|Txn ?Id|Transaction ?Id|UTR)[:\s]+([A-Z0-9]+)', caseSensitive: false),
      RegExp(r'(?:Ref|Reference)[:\s#]+([A-Z0-9]+)', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }
  
  /// Extract account balance (helper for subclasses)
  String? extractBalance(String message) {
    final pattern = RegExp(
      r'(?:Avl (?:Bal|Balance)|Available Balance|Bal)[:\s]+(?:Rs\.?|INR|₹)?\s*([\d,]+(?:\.\d{2})?)', 
      caseSensitive: false
    );
    final match = pattern.firstMatch(message);
    return match?.group(1)?.replaceAll(',', '');
  }
  
  /// Extract merchant/beneficiary name (helper for subclasses)
  String? extractMerchant(String message) {
    final patterns = [
      RegExp(r'(?:to|from|at)\s+([A-Z][A-Za-z\s]+?)(?:\s+on|\s+UPI|\s+Rs|\s+Ref)', caseSensitive: false),
      RegExp(r'(?:paid to|received from|trf to)\s+([A-Z][A-Za-z\s]+?)(?:\s+Refno|\s+on|\s+UPI)', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    return null;
  }
  
  /// Extract account number (last 4 digits) (helper for subclasses)
  String? extractAccountNumber(String message) {
    final patterns = [
      RegExp(r'A/c\s+(?:XX|x{2,4})?(\d{4})', caseSensitive: false),
      RegExp(r'account\s+(?:ending|no)?\.?\s*(?:XX|x{2,4})?(\d{4})', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }
}
