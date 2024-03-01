import 'package:findpix_flutter/models/boundary.dart';
import 'package:findpix_flutter/models/notification.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
// import 'package:geolocator/geolocator.dart';

import '../app/app.locator.dart';
import '../app/app.logger.dart';
import '../models/device.dart';
import 'package:firebase_database/firebase_database.dart';

import 'firestore_service.dart';

const dbCode = "KrPN4ntcsKSSFFw3M2zgzIh0pXT2";

class DatabaseService with ListenableServiceMixin {
  final log = getLogger('RealTimeDB_Service');
  final _snackbarService = locator<SnackbarService>();
  final _firestoreService = locator<FirestoreService>();


  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DeviceReading? _node;
  DeviceReading? get node => _node;

  Boundary? get boundary=> _firestoreService.boundary;


  void setupNodeListening() {
    log.i("Setting up..");
    DatabaseReference starCountRef =
        _db.ref('/devices/$dbCode/reading');
    log.i("R ${starCountRef.key}");
    try {
      starCountRef.onValue.listen((DatabaseEvent event) {
        // log.i("Reading..");
        if (event.snapshot.exists) {
          _node = DeviceReading.fromMap(event.snapshot.value as Map);
          // log.v(_node?.lastSeen); //data['time']
          if(node!=null){
            if(node!.sos) {
              createNotification("SOS", "Sos alert clicked on: ${DateTime.now().toIso8601String()}");
              showNotification("SOS ALERT!");
            }
            // Coordinate coord1 = Coordinate(52.5200, 13.4050); // Berlin, Germany
            // Coordinate coord2 = Coordinate(48.8566, 2.3522); // Paris, France
            //
            // double distance = calculateDistance(coord1, coord2)
            if(boundary!=null) {
              double distance = Geolocator.distanceBetween(
                  boundary!.currentLat,
                  boundary!.currentLong,
                  node!.lat,
                  node!.long) / 1000;
              if(distance > boundary!.boundaryMeters){
                createNotification("Boundary Breach", "Child is out of the boundary set, Distance: $distance meter");
                showNotification("Boundary Breach!");
              }
            }

            setActivity(lastSeen: node!.lastSeen, speed: node!.speed, acl_x: node!.acl_x, acl_y: node!.acl_y, acl_z: node!.acl_z, gyro_x: node!.gyro_x, gyro_y: node!.gyro_y, gyro_z: node!.gyro_z);

            //
          }
          notifyListeners();
        }
      });
    } catch (e) {
      log.e("Error: $e");
    }
  }

  void createNotification(String title, String content) async {
    String? notId = await _firestoreService.generateNotificationId();
     notId = await _firestoreService.generateNotificationId();
    if(notId!=null) {
      _firestoreService.addNotificationToFirestore(AppNotification(title: title, description: content, time: DateTime.now(), id: notId),);
    }
  }


  void showNotification(String message){
    _snackbarService.showSnackbar(message: message, title: "Notification");
  }

  String _childActivity = 'idle';
  String get childActivity => _childActivity;
  List<String> activities = ['idle', 'running', 'vehicle', 'walking'];
   double? acl_x_last;
   double? acl_y_last;
   double? acl_z_last;
  void setActivity({
    required DateTime lastSeen,
    required double speed,
    required double acl_x,
    required double acl_y,
    required double acl_z,
    required double gyro_x,
    required double gyro_y,
    required double gyro_z,
  }){
    if(acl_x_last == null){
      acl_x_last = acl_x;
      acl_y_last = acl_y;
      acl_z_last = acl_z;
    }

      DateTime now = DateTime.now();
      final int difference = now.difference(lastSeen).inSeconds;
      int timeDiff =  difference.abs();
      if(speed > 10) {
        _childActivity = activities[2];
      } else if(timeDiff < 5) {
        // log.i("Data");
        // log.i(gyro_x);//0.4
        // log.i(gyro_y);//0.00
        // log.i(gyro_z);//0.00
        log.i("acl");
        log.i(speed);
        // log.i(acl_x_last! - acl_x);//
        // log.i(acl_y_last! - acl_y);//
        // log.i(acl_z_last! - acl_z);//
        if(acl_x_last! - acl_x > 5 || acl_x_last! - acl_x < -5 || acl_y_last! - acl_y > 5 || acl_y_last! - acl_y < -5 || acl_z_last! - acl_z > 5 || acl_z_last! - acl_z < -5 ){
          _childActivity = activities[1];
        }
        else if(gyro_x > 0.6 || gyro_x < -0.6 || gyro_y > 0.6 || gyro_y < -0.6 || gyro_z > 0.6 || gyro_z < -0.6 ){
          _childActivity = activities[3];
        } else {
          _childActivity = activities[0];
        }


        acl_x_last = acl_x;
        acl_y_last = acl_y;
        acl_z_last = acl_z;
      } else {
        _childActivity = activities[0];
      }


  }
}


