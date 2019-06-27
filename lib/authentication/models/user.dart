class User extends Object {
  String id;
  String firstName;
  String lastName;

  User(this.id, this.firstName, this.lastName);

  User.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;
    this.firstName = json['firstName'];
    this.lastName = json['lastName'];
  }

  @override
  String toString() {
    return 'User{id: $id, firstName: $firstName, lastName: $lastName, ';
  }
}
