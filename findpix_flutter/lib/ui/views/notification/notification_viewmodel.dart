import 'package:findpix_flutter/app/app.dart';
import 'package:findpix_flutter/models/notification.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../services/firestore_service.dart';

class NotificationViewModel extends StreamViewModel<List<AppNotification>> {

  final _firestoreService = locator<FirestoreService>();

  @override
  Stream<List<AppNotification>> get stream => _firestoreService.getNotificationStream();

      void deleteNotification(AppNotification notification){
        _firestoreService.deleteNotificationFromFirestore(notification.id);
      }

}
