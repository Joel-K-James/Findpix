import 'dart:async';

import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../models/device.dart';
import '../../../services/database_service.dart';


class HomeViewModel extends BaseViewModel {
  final log = getLogger('StatusWidget');

  final _dbService = locator<DatabaseService>();

  DeviceReading? get node => _dbService.node;

  bool _isOnline = false;

  bool get isOnline => _isOnline;

  late Timer timer;

  // Initialize the view model
  void initialize() {
    setTimer();
  }

  // Check if the device is online based on last seen time
  bool isOnlineCheck(DateTime? time) {
    if (time == null) return false;
    final DateTime now = DateTime.now();
    final difference = now.difference(time).inSeconds;
    return difference.abs() <= 5;
  }

  // Set up a timer to periodically update online status
  void setTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        _isOnline = isOnlineCheck(node?.lastSeen);
        notifyListeners();
      },
    );
  }

  // Calculate the time since the device was last seen
  String lastSeen() {
    if (node?.lastSeen != null) {
      final lastSeenTime = node!.lastSeen;
      final difference = DateTime.now().difference(lastSeenTime);
      // Format the difference to display in a readable format
      if (difference.inSeconds < 60) {
        return 'Last seen: ${difference.inSeconds} seconds ago';
      } else if (difference.inMinutes < 60) {
        return 'Last seen: ${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return 'Last seen: ${difference.inHours} hours ago';
      } else {
        return 'Last seen: ${difference.inDays} days ago';
      }
    } else {
      return 'Last seen: Unknown';
    }
  }

  // Cancel the timer when the view model is disposed
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
