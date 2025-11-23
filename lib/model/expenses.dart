import 'package:budget_gov/model/dep_details.dart'; // Reusing the Money model

class Expense {
  final String code;
  final String description;
  final Money nep;
  final Money gaa;
  final List<ExpenseSubClass> subClasses;

  Expense({
    required this.code,
    required this.description,
    required this.nep,
    required this.gaa,
    required this.subClasses,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      code: json['code'] as String,
      description: json['description'] as String,
      nep: Money.fromJson(json['nep'] as Map<String, dynamic>),
      gaa: Money.fromJson(json['gaa'] as Map<String, dynamic>),
      subClasses: (json['subClasses'] as List<dynamic>)
          .map((e) => ExpenseSubClass.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExpenseSubClass {
  final String code;
  final String description;
  final Money nep;
  final Money gaa;
  final List<ExpenseGroup> groups;

  ExpenseSubClass({
    required this.code,
    required this.description,
    required this.nep,
    required this.gaa,
    required this.groups,
  });

  factory ExpenseSubClass.fromJson(Map<String, dynamic> json) {
    return ExpenseSubClass(
      code: json['code'] as String,
      description: json['description'] as String,
      nep: Money.fromJson(json['nep'] as Map<String, dynamic>),
      gaa: Money.fromJson(json['gaa'] as Map<String, dynamic>),
      groups: (json['groups'] as List<dynamic>)
          .map((e) => ExpenseGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExpenseGroup {
  final String code;
  final String description;
  final Money nep;
  final Money gaa;
  final List<ExpenseObject> objects;

  ExpenseGroup({
    required this.code,
    required this.description,
    required this.nep,
    required this.gaa,
    required this.objects,
  });

  factory ExpenseGroup.fromJson(Map<String, dynamic> json) {
    return ExpenseGroup(
      code: json['code'] as String,
      description: json['description'] as String,
      nep: Money.fromJson(json['nep'] as Map<String, dynamic>),
      gaa: Money.fromJson(json['gaa'] as Map<String, dynamic>),
      objects: (json['objects'] as List<dynamic>)
          .map((e) => ExpenseObject.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExpenseObject {
  final String code;
  final String description;
  final Money nep;
  final Money gaa;

  ExpenseObject({
    required this.code,
    required this.description,
    required this.nep,
    required this.gaa,
  });

  factory ExpenseObject.fromJson(Map<String, dynamic> json) {
    return ExpenseObject(
      code: json['code'] as String,
      description: json['description'] as String,
      nep: Money.fromJson(json['nep'] as Map<String, dynamic>),
      gaa: Money.fromJson(json['gaa'] as Map<String, dynamic>),
    );
  }
}