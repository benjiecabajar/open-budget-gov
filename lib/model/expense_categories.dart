class ExpenseCategory {
  final String code;
  final String description;

  ExpenseCategory({
    required this.code,
    required this.description,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      code: json['code'] as String,
      description: json['description'] as String,
    );
  }
}