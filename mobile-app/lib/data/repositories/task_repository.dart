import '../local/local_store.dart';
import '../models/duty_task.dart';
import '../remote/api_client.dart';

/// Duty tasks of the current day, cached on the device.
class TaskRepository {
  TaskRepository({required LocalStore store, required ApiClient api})
      : _store = store,
        _api = api;

  final LocalStore _store;
  final ApiClient _api;

  /// Tasks stored on the device by the last successful refresh.
  Future<List<DutyTask>> cached() => _store.tasks();

  /// Downloads today's tasks and replaces the cached list.
  ///
  /// Throws an [ApiException] when the backend cannot be reached, in which case
  /// the caller keeps showing the cached tasks.
  Future<List<DutyTask>> refresh(String token) async {
    final List<DutyTask> tasks = await _api.fetchTodayTasks(token);
    if (tasks.isNotEmpty) {
      await _store.replaceTasks(tasks);
    }
    return tasks;
  }
}
