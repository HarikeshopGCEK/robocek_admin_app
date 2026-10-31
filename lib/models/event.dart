import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_form_field.dart';

class RobocekEvent {
  final String id;
  final String title;
  final String category;
  final String date;
  final String? time;
  final String? venue;
  final String? location;
  final String description;
  final String? registrationUrl;
  final String? imageUrl;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final bool hasRegistrationForm;
  final bool isPaid;
  final String? registrationFee;
  final bool isFreeForMembers;
  final String? memberFee;
  final String? nonMemberFee;
  final String? whatsappGroupLink;
  final String? confirmationMessage;
  final List<CustomFormField> customFields;
  final String? paymentQr;
  final String? openAt;
  final String? closeAt;
  final int? maxResponses;

  const RobocekEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.time,
    this.venue,
    this.location,
    required this.description,
    this.registrationUrl,
    this.imageUrl,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.hasRegistrationForm = false,
    this.isPaid = false,
    this.registrationFee,
    this.isFreeForMembers = false,
    this.memberFee,
    this.nonMemberFee,
    this.whatsappGroupLink,
    this.confirmationMessage,
    this.customFields = const [],
    this.paymentQr,
    this.openAt,
    this.closeAt,
    this.maxResponses,
  });

  String get displayVenue => venue ?? location ?? 'GCE Kannur Campus';
  String get displayStatus => status ?? 'Upcoming';

  factory RobocekEvent.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return RobocekEvent(
      id: doc.id,
      title: _str(data['title']) ?? '',
      category: _str(data['category']) ?? 'Workshop',
      date: _str(data['date']) ?? '',
      time: _str(data['time']),
      venue: _str(data['venue']),
      location: _str(data['location']),
      description: _str(data['description']) ?? '',
      registrationUrl: _str(data['registrationUrl']),
      imageUrl: _str(data['imageUrl']),
      status: _str(data['status']),
      createdAt: _str(data['createdAt']),
      updatedAt: _str(data['updatedAt']),
      hasRegistrationForm: data['hasRegistrationForm'] as bool? ?? false,
      isPaid: data['isPaid'] as bool? ?? false,
      registrationFee: _str(data['registrationFee']),
      isFreeForMembers: data['isFreeForMembers'] as bool? ?? false,
      memberFee: _str(data['memberFee']),
      nonMemberFee: _str(data['nonMemberFee']),
      whatsappGroupLink: _str(data['whatsappGroupLink']),
      confirmationMessage: _str(data['confirmationMessage']),
      customFields: (data['customFields'] as List?)
              ?.map((e) => CustomFormField.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      paymentQr: _str(data['paymentQr']),
      openAt: _str(data['openAt']),
      closeAt: _str(data['closeAt']),
      maxResponses: data['maxResponses'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'title': title,
      'category': category,
      'date': date,
      if (time != null) 'time': time,
      'venue': displayVenue,
      'location': displayVenue,
      'description': description,
      if (registrationUrl != null) 'registrationUrl': registrationUrl,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'status': displayStatus,
      'hasRegistrationForm': hasRegistrationForm,
      'isPaid': isPaid,
      if (registrationFee != null) 'registrationFee': registrationFee,
      'isFreeForMembers': isFreeForMembers,
      if (memberFee != null) 'memberFee': memberFee,
      if (nonMemberFee != null) 'nonMemberFee': nonMemberFee,
      if (whatsappGroupLink != null) 'whatsappGroupLink': whatsappGroupLink,
      'confirmationMessage': confirmationMessage ??
          'Registration confirmed. Details and updates will be shared via official channels.',
      'customFields': customFields.map((f) => f.toMap()).toList(),
      if (paymentQr != null) 'paymentQr': paymentQr,
      if (openAt != null) 'openAt': openAt,
      if (closeAt != null) 'closeAt': closeAt,
      if (maxResponses != null) 'maxResponses': maxResponses,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    return map;
  }

  static String? _str(dynamic val) {
    if (val == null) return null;
    if (val is String) return val.isEmpty ? null : val;
    return val.toString();
  }
}
