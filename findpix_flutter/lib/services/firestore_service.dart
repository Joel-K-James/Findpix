import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

import '../app/app.locator.dart';
import '../app/app.logger.dart';
import '../models/appuser.dart';
import '../models/boundary.dart';
import '../models/notification.dart';

class FirestoreService with ListenableServiceMixin {
  final log = getLogger('FirestoreApi');
  final _authenticationService = locator<FirebaseAuthenticationService>();

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection("users");

  Future<bool> createUser({required AppUser user, required keyword}) async {
    log.i('user:$user');
    try {
      final userDocument = _usersCollection.doc(user.id);
      await userDocument.set(user.toJson(keyword), SetOptions(merge: true));
      log.v('UserCreated at ${userDocument.path}');
      return true;
    } catch (error) {
      log.e("Error $error");
      return false;
    }
  }

  Future<AppUser?> getUser({required String userId}) async {
    log.i('userId:$userId');

    if (userId.isNotEmpty) {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        log.v('We have no user with id $userId in our database');
        return null;
      }

      final userData = userDoc.data();
      log.v('User found. Data: $userData');

      return AppUser.fromMap(userData! as Map<String, dynamic>);
    } else {
      log.e("Error no user");
      return null;
    }
  }

  Future<List<AppUser>> searchUsers(String keyword) async {
    log.i("searching for $keyword");
    final query = _usersCollection
        .where('keyword', arrayContains: keyword.toLowerCase())
        .limit(5);

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<bool> updateLocation(double lat, double long, String place) async {
    log.i('Location update');
    try {
      final userDocument =
          _usersCollection.doc(_authenticationService.currentUser!.uid);
      await userDocument.update({
        "lat": lat,
        "long": long,
        "place": place,
      });
      // log.v('UserCreated at ${userDocument.path}');
      return true;
    } catch (error) {
      log.e("Error $error");
      return false;
    }
  }

  Future<bool> updateBystander(String uid) async {
    log.i('Bystander update');
    try {
      final userDocument =
          _usersCollection.doc(_authenticationService.currentUser!.uid);
      await userDocument.update({
        "bystanders": FieldValue.arrayUnion([uid])
      });
      // log.v('UserCreated at ${userDocument.path}');
      return true;
    } catch (error) {
      log.e("Error $error");
      return false;
    }
  }

  Future<List<AppUser>> getUsersWithBystander() async {
    QuerySnapshot querySnapshot = await _usersCollection
        .where('bystanders',
            arrayContains: _authenticationService.currentUser!.uid)
        .get();

    return querySnapshot.docs
        .map((snapshot) =>
            AppUser.fromMap(snapshot.data() as Map<String, dynamic>))
        .toList();
  }

///==================================================================================================
  final CollectionReference _notifications =
  FirebaseFirestore.instance.collection("notifications");

  Future<String?> generateNotificationId() async {
    try {
      // Add a document with an auto-generated ID
      DocumentReference documentReference = _notifications.doc();

      // Retrieve the auto-generated ID from the document reference
      String documentId = documentReference.id;

      // Return the generated document ID
      return documentId;
    } catch (e) {
      // Handle any errors here
      log.e("Error generating document ID: $e");
      return null; // You might want to handle errors more gracefully
    }
  }

  Future<void> addNotificationToFirestore(AppNotification notification) async {
    try {
      // Add the notification to the 'notifications' collection
      final notDoc = _notifications.doc(notification.id);

      await notDoc.set(notification.toMap());

      log.i('Notification added successfully');
    } catch (e) {
      log.e('Error adding notification: $e');
    }
  }

  Stream<List<AppNotification>> getNotificationStream() {
    // Snapshot stream of notifications ordered by time
    return _notifications.orderBy('time', descending: true).snapshots().map(
          (QuerySnapshot querySnapshot) => querySnapshot.docs.map(
            (DocumentSnapshot documentSnapshot) => AppNotification.fromMap(
          documentSnapshot.data() as Map<String, dynamic>,
        ),
      ).toList(),
    );
  }

  Future<void> deleteNotificationFromFirestore(String documentId) async {
    try {
      DocumentReference documentReference = _notifications.doc(documentId);

      // Delete the document
      await documentReference.delete();

      log.i('Notification deleted successfully');
    } catch (e) {
      log.e('Error deleting notification: $e');
    }
  }


  ///==================================================================================================
  final CollectionReference _boundaries =
  FirebaseFirestore.instance.collection("boundaries");
  Future<void> addBoundaryToFirestore(Boundary boundary) async {
    try {

      // Convert the boundary object to a map using the toMap method

      // Add the boundary to the 'boundaries' collection
      final boundDoc = _boundaries.doc(boundary.id);

      await boundDoc.set(boundary.toMap());


      log.i('Boundary added successfully');
    } catch (e) {
      log.e('Error adding boundary: $e');
    }

  }


  Boundary? _boundary;
  Boundary? get  boundary=> _boundary;


  void listenToBoundary(){
    _boundaries.doc('boundary').snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // If the document exists, update the 'boundary' variable with the new data
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        Boundary boundary = Boundary.fromMap(data);
        // Update the 'boundary' variable
        _boundary = boundary;
        notifyListeners();
      } else {
        // If the document does not exist, set the 'boundary' variable to null or handle it accordingly
        _boundary = null;
        notifyListeners();
      }
    });
  }


}
