import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';

class SyncProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();

  bool get isOnline => _syncService.isOnline;
  bool get isSyncing => _syncService.isSyncing;
  int get pendingOperations => _syncService.pendingOperations;
  DateTime? get lastSyncTime => _syncService.lastSyncTime;

  SyncProvider() {
    _syncService.addListener(_onSyncServiceChanged);
  }

  void _onSyncServiceChanged() {
    notifyListeners();
  }

  Future<void> forceSyncNow() async {
    await _syncService.forceSyncNow();
  }

  Future<void> loadInitialData() async {
    await _syncService.loadInitialData();
  }

  @override
  void dispose() {
    _syncService.removeListener(_onSyncServiceChanged);
    super.dispose();
  }
}
