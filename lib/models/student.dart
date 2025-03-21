import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 0)
class Student {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String admissionNumber;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final String phoneNumber;

  Student({
    required this.name,
    required this.admissionNumber,
    required this.password,
    required this.phoneNumber,
  });

  @override
  String toString() {
    return 'Student(name: $name, admission: $admissionNumber, phone: $phoneNumber)';
  }
}
