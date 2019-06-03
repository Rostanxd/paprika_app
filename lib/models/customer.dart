class Customer extends Object {
  String id;
  String firstName;
  String lastName;
  String state;
  String email;
  String cellphone;
  String telephone;
  String bornDate;

  Customer(this.id, this.firstName, this.lastName, this.email, this.cellphone,
      this.telephone, this.bornDate, this.state);

  Customer.fromFireJson(String documentId, Map<String, dynamic> json){
    this.id = json['id'];
    this.state = json['state'];
    this.firstName = json['firstName'];
    this.lastName = json['lastName'];
    this.email = json['email'];
    this.cellphone = json['cellphone'];
    this.telephone = json['telephone'];
    this.bornDate = json['bornDate'];
  }

  Map<String, dynamic> toFireJson() => {
    'state': this.state,
    'firstName': this.firstName,
    'lastName': this.lastName,
    'email': this.email,
    'cellphone': this.cellphone,
    'telephone': this.telephone,
    'bornDate': this.bornDate
  };

}