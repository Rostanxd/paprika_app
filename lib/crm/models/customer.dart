import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/crm/models/person.dart';

class Customer implements Person {
  String customerId;

  String state;

  @override
  String anniversaryDate;

  @override
  DateTime bornDate;

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

  Customer.toFireBase(this.email, this.firstName, this.id, this.lastName,
      this.cellphoneOne, this.telephoneOne, this.bornDate);

  Customer.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.customerId = documentId;
    this.id = json['id'] != null ? json['id'] : '';
    this.state = json['state'] != null ? json['state'] : 'I';
    this.firstName = json['firstName'] != null ? json['firstName'] : '';
    this.lastName = json['lastName'] != null ? json['lastName'] : '';
    this.email = json['email'] != null ? json['email'] : '';
    this.cellphoneOne = json['cellphone'] != null ? json['cellphone'] : '';
    this.telephoneOne = json['telephone'] != null ? json['telephone'] : '';
    this.bornDate =
        DateTime.fromMillisecondsSinceEpoch(json['bornDate'].seconds * 1000);
  }

  Map<String, dynamic> toFireJson() => {
        'id': this.id != null ? this.id : '',
        'firstName': this.firstName != null ? this.firstName : '',
        'lastName': this.lastName != null ? this.lastName : '',
        'email': this.email != null ? this.email : '',
        'cellphone': this.cellphoneOne != null ? this.cellphoneOne : '',
        'telephone': this.telephoneOne != null ? this.telephoneOne : '',
        'bornDate': this.bornDate != null
            ? Timestamp.fromDate(this.bornDate)
            : Timestamp(0, 0),
      };

  @override
  String toString() {
    return 'Customer{customerId: $customerId, state: $state, '
        'anniversaryDate: $anniversaryDate, bornDate: $bornDate, '
        'cellphoneOne: $cellphoneOne, cellphoneTwo: $cellphoneTwo, '
        'civilState: $civilState, email: $email, firstName: $firstName, '
        'gender: $gender, id: $id, lastName: $lastName, passport: $passport, '
        'telephoneOne: $telephoneOne, telephoneTwo: $telephoneTwo}';
  }
}
