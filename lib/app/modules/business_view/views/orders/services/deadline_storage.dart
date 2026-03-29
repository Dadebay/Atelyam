import 'package:get_storage/get_storage.dart';

/// Stores and retrieves order deadlines locally on the device using GetStorage.
/// Deadlines are keyed by order ID and stored as ISO date strings (yyyy-MM-dd).
class DeadlineStorage {
  static const String _boxName = 'order_deadlines';
  static final GetStorage _box = GetStorage(_boxName);

  static Future<void> init() async {
    await GetStorage.init(_boxName);
  }

  static String _key(int orderId) => 'deadline_$orderId';

  static void save(int orderId, DateTime? deadline) {
    if (deadline == null) {
      _box.remove(_key(orderId));
    } else {
      _box.write(_key(orderId), deadline.toIso8601String().split('T').first);
    }
  }

  static DateTime? read(int orderId) {
    final raw = _box.read<String?>(_key(orderId));
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static void delete(int orderId) {
    _box.remove(_key(orderId));
  }

  /// Returns a map of orderId → deadline for all given order IDs.
  static Map<int, DateTime> readAll(List<int> orderIds) {
    final result = <int, DateTime>{};
    for (final id in orderIds) {
      final dl = read(id);
      if (dl != null) result[id] = dl;
    }
    return result;
  }
}
