import 'package:flutter/foundation.dart';

import '../data/models/duty_task.dart';
import '../data/remote/api_exception.dart';
import '../data/repositories/task_repository.dart';

/// Loads today's duty tasks from the cache and refreshes them when online.
class TaskController extends ChangeNotifier {
  TaskController({
    required TaskRepository repository,
    required String? Function() tokenProvider,
  })  : _repository = repository,
        _tokenProvider = tokenProvider;

  final TaskRepository _repository;
  final String? Function() _tokenProvider;

  List<DutyTask> _tasks = const <DutyTask>[];
  bool _loading = false;
  bool _fromCache = false;
  ApiException? _failure;

  List<DutyTask> get tasks => _tasks;

  bool get loading => _loading;

  /// `true` while the list shown comes from the device cache only.
  bool get fromCache => _fromCache;

  ApiException? get failure => _failure;

  /// Shows the cached tasks immediately and then tries the backend.
  Future<void> load() async {
    _tasks = await _repository.cached();
    _fromCache = true;
    notifyListeners();

    final String? token = _tokenProvider();
    if (token == null) return;

    _loading = true;
    notifyListeners();
    try {
      _tasks = await _repository.refresh(token);
      _fromCache = false;
      _failure = null;
    } on ApiException catch (error) {
      _failure = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
