import 'package:paprika_app/models/person.dart';

class Customer implements Person {
  String customerId;

  String state;

  @override
  String anniversaryDate;

  @override
  String bornDate;

  @override
  String cellphoneOne;

  @override
  String cellphoneTwo;

  @override
  String civilState;

  @override
  String email;

  @override
  String firstName;

  @override
  String gender;

  @override
  String id;

  @override
  String lastName;

  @override
  String passport;

  @override
  String telephoneOne;

  @override
  String telephoneTwo;

  Customer(this.customerId, this.id, this.firstName, this.lastName, this.email,
      this.cellphoneOne, this.telephoneOne, this.bornDate, this.state);

  Customer.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.customerId = documentId;
    this.id = json['id'];
    this.state = json['state'];
    this.firstName = json['firstName'];
    this.lastName = json['lastName'];
    this.email = json['email'];
    this.cellphoneOne = json['cellphone'];
    this.telephoneOne = json['telephone'];
    this.bornDate = json['bornDate'];
  }

  Map<String, dynamic> toFireJson() => {
        'id': this.id,
        'state': this.state,
        'firstName': this.firstName,
        'lastName': this.lastName,
        'email': this.email,
        'cellphone': this.cellphoneOne,
        'telephone': this.telephoneOne,
        'bornDate': this.bornDate
      };
}
