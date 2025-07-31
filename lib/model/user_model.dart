class User {
  final int? userCode;
  final String? userName;
  final String? employeeName;
  final String? email;
  final String? unit;
  final String? department;
  final String? designation;
  final String? empImage;
  final String? phone;

  User({
    this.userCode,
    this.userName,
    this.employeeName,
    this.email,
    this.unit,
    this.department,
    this.designation,
    this.empImage,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userCode: int.tryParse(json['UserCode']?.toString() ?? ''),
      userName: json['UserName'],
      employeeName: json['EmployeeName'],
      email: json['Email'],
      unit: json['Unit'],
      department: json['Department'],
      designation: json['Designation'],
      empImage: json['EmpImage'],
      phone: json['Phone'],
    );
  }

  Map<String, dynamic> toJson() => {
        'UserCode': userCode,
        'UserName': userName,
        'EmployeeName': employeeName,
        'Email': email,
        'Unit': unit,
        'Department': department,
        'Designation': designation,
        'EmpImage': empImage,
        'Phone': phone,
      };
}
