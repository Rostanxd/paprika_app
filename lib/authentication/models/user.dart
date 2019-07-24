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

  User.fromSimpleMap(Map<String, dynamic> json) {
    this.id = json['id'];
    this.firstName = json['firstName'];
    this.lastName = json['lastName'];
  }

  Map<String, dynamic> toSimpleMap() => {
    'id': this.id,
    'firstName': this.firstName,
    'lastName': this.lastName,
  };

  @override
  String toString() {
    return 'User{id: $id, firstName: $firstName, lastName: $lastName, ';
  }
}
