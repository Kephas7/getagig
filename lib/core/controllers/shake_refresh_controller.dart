import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

typedef ShakeRefreshCallback = Future<void> Function();

class ShakeRefreshController {
  final ShakeRefreshCallback onShake;
  final double threshold;
  final Duration cooldown;

  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastTriggerAt;
  bool _isRefreshing = false;
  bool _isStarted = false;

  ShakeRefreshController({
    required this.onShake,
    this.threshold = 22,
    this.cooldown = const Duration(seconds: 2),
  });

  void start() {
    if (_isStarted) return;
    _isStarted = true;
    _subscription = accelerometerEventStream().listen(_onAccelerometerEvent);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isStarted = false;
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final now = DateTime.now();

    if (_lastTriggerAt != null && now.difference(_lastTriggerAt!) < cooldown) {
      return;
    }

    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    if (magnitude < threshold) {
      return;
    }

    _lastTriggerAt = now;
    _triggerRefresh();
  }

  void _triggerRefresh() {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    unawaited(_runRefresh());
  }

  Future<void> _runRefresh() async {
    try {
      await onShake();
    } finally {
      _isRefreshing = false;
    }
  }
}
