class User extends Object {
  String id;
  String firstName;
  String lastName;
  int age;
  String role;
  String roleName;

  User(this.id, this.firstName, this.lastName, this.age, this.role, this.roleName);

  User.fromJson(String documentId, Map<String, dynamic> json){
    this.id = documentId;
    this.firstName = json['first_name'];
    this.lastName = json['last_name'];
    this.age = json['age'];
    this.role = json['role'];
    this.roleName = json['role_name'];
  }
}