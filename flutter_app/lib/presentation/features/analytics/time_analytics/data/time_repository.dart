import '../data/time_storage.dart';
import '/app/utils/net.dart';

class TimeRepository {
  Future<List<Map<String, dynamic>>> getUsageLogs() async {
    final isOnline = await Net.isOnline();

    if (isOnline) {
      final data = await TimeStorage.load();
      return data;
    }

    return await TimeStorage.load();
  }
}
