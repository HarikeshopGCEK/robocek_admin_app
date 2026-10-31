import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/custom_form.dart';
import '../models/registration.dart';

class FormRepository {
  final FirebaseFirestore _db;

  FormRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Stream<List<CustomForm>> watchAll() {
    return _db
        .collection('custom_forms')
        .snapshots()
        .map((snap) => snap.docs.map((d) => CustomForm.fromDoc(d)).toList());
  }

  Stream<List<EventRegistration>> watchResponses(String formId) {
    return _db
        .collection('custom_forms')
        .doc(formId)
        .collection('responses')
        .snapshots()
        .map((snap) => snap.docs.map((d) => EventRegistration.fromDoc(d)).toList());
  }

  Future<void> saveForm(CustomForm form) async {
    // Build slug from title if id is empty
    final formId = form.id.isNotEmpty
        ? form.id
        : form.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-').replaceAll(RegExp(r'^-+|-+$'), '');

    final data = form.toFirestore();
    data['createdAt'] = DateTime.now().toIso8601String();

    await _db.collection('custom_forms').doc(formId).set(data, SetOptions(merge: true));
  }

  Future<void> deleteForm(String formId) async {
    await _db.collection('custom_forms').doc(formId).delete();
  }

  Future<void> togglePaymentStatus(String formId, String responseId, String? currentStatus) async {
    final newStatus = currentStatus == 'Verified' ? 'Pending' : 'Verified';
    await _db
        .collection('custom_forms')
        .doc(formId)
        .collection('responses')
        .doc(responseId)
        .set({'paymentStatus': newStatus}, SetOptions(merge: true));
  }
}
