class Enterprise extends Object {
  String id;
  String ruc;
  String name;
  String state;
  String address;
  DateTime creationDate;
  String creationUser;
  DateTime modificationDate;
  String modificationUser;

  Enterprise(
      this.id,
      this.ruc,
      this.name,
      this.state,
      this.address,
      this.creationDate,
      this.creationUser,
      this.modificationDate,
      this.modificationUser);

  Enterprise.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;
    this.ruc = json['ruc'];
    this.name = json['name'];
    this.state = json['state'];
    this.address = json['address'];
//    this.creationDate = json['creationDate'];
//    this.creationUser = json['creationUser'];
//    this.modificationDate = json['modificationDate'];
//    this.modificationUser = json ['modificationUser'];
  }

  @override
  String toString() {
    return 'Enterprise{id: $id, ruc: $ruc, name: $name, state: $state, '
        'address: $address, creationDate: $creationDate, '
        'creationUser: $creationUser, modificationDate: $modificationDate, '
        'modificationUser: $modificationUser}';
  }

}
