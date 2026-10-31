import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';
import '../models/registration.dart';

class EventRepository {
  final FirebaseFirestore _db;

  EventRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Stream<List<RobocekEvent>> watchAll() {
    return _db
        .collection('events')
        .snapshots()
        .map((snap) => snap.docs.map((d) => RobocekEvent.fromDoc(d)).toList());
  }

  Stream<List<EventRegistration>> watchRegistrations(String eventId) {
    return _db
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .snapshots()
        .map((snap) => snap.docs.map((d) => EventRegistration.fromDoc(d)).toList());
  }

  Future<void> createEvent(RobocekEvent event) async {
    final data = event.toFirestore();
    data['createdAt'] = DateTime.now().toIso8601String();
    await _db.collection('events').add(data);
  }

  Future<void> updateEvent(RobocekEvent event) async {
    await _db.collection('events').doc(event.id).set(event.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  Future<void> updateStatus(String eventId, String newStatus) async {
    await _db.collection('events').doc(eventId).set({'status': newStatus}, SetOptions(merge: true));
  }

  Future<void> togglePaymentStatus(String eventId, String regId, String? currentStatus) async {
    final newStatus = currentStatus == 'Verified' ? 'Pending' : 'Verified';
    await _db
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .doc(regId)
        .set({'paymentStatus': newStatus}, SetOptions(merge: true));
  }
}
