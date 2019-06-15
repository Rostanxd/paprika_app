class Role extends Object {
  String id;
  String name;

  Role(this.id, this.name);

  Role.fromFireJson(String documentId, Map<String, dynamic> json){
    this.id = documentId;
    this.name = json['name'];
  }

  Map<String, dynamic> toFireJson() => {
    'name': this.name
  };

  @override
  String toString() {
    return 'Role{id: $id, name: $name}';
  }

}