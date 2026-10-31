import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_form_field.dart';

class CustomForm {
  final String id;
  final String title;
  final String description;
  final String status; // Active | Closed
  final bool isPaid;
  final String? registrationFee;
  final bool isFreeForMembers;
  final String? memberFee;
  final String? nonMemberFee;
  final String? whatsappGroupLink;
  final String? confirmationMessage;
  final List<CustomFormField> fields;
  final String? createdAt;
  final String? updatedAt;
  final String? paymentQr;
  final String? openAt;
  final String? closeAt;
  final int? maxResponses;

  const CustomForm({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.isPaid = false,
    this.registrationFee,
    this.isFreeForMembers = false,
    this.memberFee,
    this.nonMemberFee,
    this.whatsappGroupLink,
    this.confirmationMessage,
    this.fields = const [],
    this.createdAt,
    this.updatedAt,
    this.paymentQr,
    this.openAt,
    this.closeAt,
    this.maxResponses,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory CustomForm.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CustomForm(
      id: doc.id,
      title: _str(data['title']) ?? '',
      description: _str(data['description']) ?? '',
      status: _str(data['status']) ?? 'Active',
      isPaid: data['isPaid'] as bool? ?? false,
      registrationFee: _str(data['registrationFee']),
      isFreeForMembers: data['isFreeForMembers'] as bool? ?? false,
      memberFee: _str(data['memberFee']),
      nonMemberFee: _str(data['nonMemberFee']),
      whatsappGroupLink: _str(data['whatsappGroupLink']),
      confirmationMessage: _str(data['confirmationMessage']),
      fields: (data['fields'] as List?)
              ?.map((e) => CustomFormField.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      createdAt: _str(data['createdAt']),
      updatedAt: _str(data['updatedAt']),
      paymentQr: _str(data['paymentQr']),
      openAt: _str(data['openAt']),
      closeAt: _str(data['closeAt']),
      maxResponses: data['maxResponses'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'isPaid': isPaid,
      if (registrationFee != null) 'registrationFee': registrationFee,
      'isFreeForMembers': isFreeForMembers,
      if (memberFee != null) 'memberFee': memberFee,
      if (nonMemberFee != null) 'nonMemberFee': nonMemberFee,
      if (whatsappGroupLink != null) 'whatsappGroupLink': whatsappGroupLink,
      'confirmationMessage': confirmationMessage ??
          'Registration confirmed. Details and updates will be shared via official channels.',
      'fields': fields.map((f) => f.toMap()).toList(),
      if (paymentQr != null) 'paymentQr': paymentQr,
      if (openAt != null) 'openAt': openAt,
      if (closeAt != null) 'closeAt': closeAt,
      if (maxResponses != null) 'maxResponses': maxResponses,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  static String? _str(dynamic val) {
    if (val == null) return null;
    if (val is String) return val.isEmpty ? null : val;
    return val.toString();
  }
}
