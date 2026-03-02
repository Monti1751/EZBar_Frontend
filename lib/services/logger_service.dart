import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    // En producción (release mode), solo mostramos errores críticos o desactivamos
    filter: ProductionFilter(),
    level: kDebugMode ? Level.trace : Level.error,
  );

  // Getters para facilitar el uso
  static void v(String message) => _logger.t(message); // Trace
  static void d(String message) => _logger.d(message); // Debug
  static void i(String message) => _logger.i(message); // Info
  static void w(String message) => _logger.w(message); // Warning
  static void e(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
  static void f(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}

class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kDebugMode) return true;
    // En producción solo logueamos errores y fatales
    return event.level.index >= Level.error.index;
  }
}
