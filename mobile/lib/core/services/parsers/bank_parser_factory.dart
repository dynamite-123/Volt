import '../../../features/sms/domain/entities/upi_transaction.dart';
import 'bank_parser.dart';
import 'hdfc_parser.dart';
import 'sbi_parser.dart';
import 'icici_parser.dart';
import 'axis_parser.dart';
import 'phonepe_parser.dart';
import 'gpay_parser.dart';
import 'paytm_parser.dart';

/// Factory class that manages all bank parsers and selects the appropriate one
/// for each SMS message. Parsers are tried in priority order.
class BankParserFactory {
  final List<BankParser> _parsers;
  
  BankParserFactory({List<BankParser>? customParsers})
      : _parsers = customParsers ?? _defaultParsers();
  
  /// Default parsers in priority order
  /// Bank-specific parsers are tried first for better accuracy
  static List<BankParser> _defaultParsers() {
    return [
      // Major banks
      SbiParser(),
      HdfcParser(),
      IciciParser(),
      AxisParser(),
      
      // UPI apps
      PhonePeParser(),
      GPayParser(),
      PaytmParser(),
    ];
  }
  
  /// Parse a message using the most appropriate parser
  /// Returns null if no parser can handle the message
  UpiTransaction? parse(
    String message, {
    String? sender,
    String? address,
    DateTime? timestamp,
  }) {
    // Normalize sender for matching
    final effectiveSender = sender ?? address ?? '';
    
    // Try each parser in order
    for (final parser in _parsers) {
      if (parser.canHandle(sender: effectiveSender, message: message)) {
        print('🏦 Using ${parser.bankName} parser for message');
        final result = parser.parse(
          message,
          timestamp: timestamp,
          sender: effectiveSender,
        );
        
        if (result != null) {
          print('✅ Successfully parsed with ${parser.bankName} parser');
          return result;
        }
      }
    }
    
    print('⚠️ No bank-specific parser matched, will use fallback');
    return null;
  }
  
  /// Get all registered parsers
  List<BankParser> get parsers => List.unmodifiable(_parsers);
  
  /// Get parser for a specific bank name
  BankParser? getParserByBankName(String bankName) {
    try {
      return _parsers.firstWhere(
        (parser) => parser.bankName.toLowerCase() == bankName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Check if a sender can be handled by any parser
  bool canHandleSender(String sender) {
    return _parsers.any(
      (parser) => parser.canHandle(sender: sender, message: ''),
    );
  }
}
