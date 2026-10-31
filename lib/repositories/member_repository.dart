import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/member.dart';

class MemberRepository {
  final FirebaseFirestore _db;

  MemberRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Stream<List<Member>> watchAll() {
    return _db
        .collection('users')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Member.fromDoc(d)).toList());
  }

  Future<void> approveMember(Member member) async {
    final generatedId = _generateMembershipId();
    await _db.collection('users').doc(member.id).set({
      'status': 'approved',
      'membershipId': generatedId,
      'approvedAt': DateTime.now().toIso8601String(),
      'fullName': member.fullName?.isNotEmpty == true ? member.fullName : member.email?.split('@').first ?? 'Member',
      'email': member.email ?? '',
    }, SetOptions(merge: true));
  }

  Future<void> deleteMember(Member member) async {
    await _db.collection('users').doc(member.id).delete();
    // If uid is different from doc id, delete that too
    if (member.uid != null && member.uid != member.id) {
      try {
        await _db.collection('users').doc(member.uid).delete();
      } catch (_) {}
    }
  }

  Future<void> batchImport(List<Map<String, dynamic>> rows) async {
    final now = DateTime.now().toIso8601String();
    var batch = _db.batch();
    var count = 0;

    for (final row in rows) {
      final docRef = _db.collection('users').doc();
      final data = {
        ...row,
        'uid': docRef.id,
        'status': 'approved',
        'membershipId': _generateMembershipId(),
        'mustChangePassword': true,
        'defaultPassword': 'Robocek@2026',
        'createdAt': now,
        'approvedAt': now,
      };
      batch.set(docRef, _cleanForFirestore(data));
      count++;
      if (count % 450 == 0) {
        await batch.commit();
        batch = _db.batch();
      }
    }
    if (count % 450 != 0) await batch.commit();
  }

  String _generateMembershipId() {
    final rand = 1000 + DateTime.now().microsecond % 9000;
    return 'ROBOCEK-2026-$rand';
  }

  dynamic _cleanForFirestore(dynamic obj) {
    if (obj == null) return null;
    if (obj is Map) {
      return obj.map((k, v) => MapEntry(k, _cleanForFirestore(v)))
        ..removeWhere((_, v) => v == null);
    }
    if (obj is List) return obj.map(_cleanForFirestore).toList();
    return obj;
  }
}
