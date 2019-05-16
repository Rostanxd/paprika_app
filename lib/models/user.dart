class User extends Object {
  String firstName;
  String lastName;
  int age;
  String role;
  String roleName;

  User(this.firstName, this.lastName, this.age, this.role, this.roleName);

  User.fromJson(Map<String, dynamic> json){
    this.firstName = json['first_name'];
    this.lastName = json['last_name'];
    this.age = json['age'];
    this.role = json['role'];
    this.roleName = json['role_name'];
  }
}