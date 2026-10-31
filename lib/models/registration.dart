import 'package:cloud_firestore/cloud_firestore.dart';

class EventRegistration {
  final String id;
  final String? eventId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? branch;
  final String? year;
  final String? membershipId;
  final bool isMemberDiscountApplied;
  final String? feePaid;
  final String? utrNumber;
  final String? paymentStatus; // Pending | Verified
  final String? registeredAt;
  final Map<String, dynamic>? customAnswers;

  const EventRegistration({
    required this.id,
    this.eventId,
    this.fullName,
    this.email,
    this.phone,
    this.branch,
    this.year,
    this.membershipId,
    this.isMemberDiscountApplied = false,
    this.feePaid,
    this.utrNumber,
    this.paymentStatus,
    this.registeredAt,
    this.customAnswers,
  });

  bool get isVerified => paymentStatus == 'Verified';
  String get displayName => fullName?.isNotEmpty == true ? fullName! : 'Participant';
  bool get hasMembership => membershipId?.trim().isNotEmpty == true;

  factory EventRegistration.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EventRegistration(
      id: doc.id,
      eventId: _str(data['eventId']),
      fullName: _str(data['fullName']),
      email: _str(data['email']),
      phone: _str(data['phone']),
      branch: _str(data['branch']),
      year: _str(data['year']),
      membershipId: _str(data['membershipId']),
      isMemberDiscountApplied: data['isMemberDiscountApplied'] as bool? ?? false,
      feePaid: _str(data['feePaid']),
      utrNumber: _str(data['utrNumber']),
      paymentStatus: _str(data['paymentStatus']),
      registeredAt: _str(data['registeredAt']),
      customAnswers: data['customAnswers'] as Map<String, dynamic>?,
    );
  }

  static String? _str(dynamic val) {
    if (val == null) return null;
    if (val is String) return val.isEmpty ? null : val;
    return val.toString();
  }
}
