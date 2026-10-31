class CustomFormField {
  final String id;
  final String label;
  final String type; // text | email | tel | number | select | textarea
  final String? placeholder;
  final bool required;
  final List<String>? options;

  const CustomFormField({
    required this.id,
    required this.label,
    required this.type,
    this.placeholder,
    required this.required,
    this.options,
  });

  factory CustomFormField.fromMap(Map<String, dynamic> map) {
    return CustomFormField(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label: map['label'] as String? ?? '',
      type: map['type'] as String? ?? 'text',
      placeholder: map['placeholder'] as String?,
      required: map['required'] as bool? ?? false,
      options: (map['options'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'type': type,
      if (placeholder != null) 'placeholder': placeholder,
      'required': required,
      if (options != null) 'options': options,
    };
  }

  CustomFormField copyWith({
    String? id,
    String? label,
    String? type,
    String? placeholder,
    bool? required,
    List<String>? options,
  }) {
    return CustomFormField(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      placeholder: placeholder ?? this.placeholder,
      required: required ?? this.required,
      options: options ?? this.options,
    );
  }
}
