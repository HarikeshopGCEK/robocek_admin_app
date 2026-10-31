import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String id;
  final String? uid;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? phoneNumber;
  final String? branch;
  final String? year;
  final String? yearSemester;
  final String? status;
  final String? membershipId;
  final String? createdAt;
  final String? approvedAt;
  final Map<String, dynamic> extra;

  const Member({
    required this.id,
    this.uid,
    this.fullName,
    this.email,
    this.phone,
    this.phoneNumber,
    this.branch,
    this.year,
    this.yearSemester,
    this.status,
    this.membershipId,
    this.createdAt,
    this.approvedAt,
    this.extra = const {},
  });

  bool get isApproved {
    final st = (status ?? '').trim().toLowerCase();
    return st == 'approved' || st == 'approved member';
  }

  String get displayName => fullName?.isNotEmpty == true ? fullName! : (email?.split('@').first ?? 'Member');
  String get displayPhone => phone ?? phoneNumber ?? '';
  String get displayYear => yearSemester ?? year ?? '';
  String get displayStatus => isApproved ? 'Approved' : 'Pending';

  factory Member.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Member(
      id: doc.id,
      uid: _str(data['uid']) ?? doc.id,
      fullName: _str(data['fullName']),
      email: _str(data['email']),
      phone: _str(data['phone']),
      phoneNumber: _str(data['phoneNumber']),
      branch: _str(data['branch']),
      year: _str(data['year']),
      yearSemester: _str(data['yearSemester']),
      status: _str(data['status']),
      membershipId: _str(data['membershipId']),
      createdAt: _str(data['createdAt']),
      approvedAt: _str(data['approvedAt']),
      extra: Map<String, dynamic>.from(data),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (uid != null) 'uid': uid,
      if (fullName != null) 'fullName': fullName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (branch != null) 'branch': branch,
      if (year != null) 'year': year,
      if (yearSemester != null) 'yearSemester': yearSemester,
      if (status != null) 'status': status,
      if (membershipId != null) 'membershipId': membershipId,
      if (createdAt != null) 'createdAt': createdAt,
      if (approvedAt != null) 'approvedAt': approvedAt,
    };
  }

  static String? _str(dynamic val) {
    if (val == null) return null;
    if (val is String) return val.isEmpty ? null : val;
    return val.toString();
  }
}
