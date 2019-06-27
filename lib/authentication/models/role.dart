class Role extends Object {
  String systemId;
  String name;

  Role(this.systemId, this.name);

  Role.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.systemId = json['systemId'];
    this.name = json['name'];
  }

  Map<String, dynamic> toFireJson() => {
        'systemId': this.systemId,
        'name': this.name,
      };

  @override
  String toString() {
    return 'Role{sistemId: $systemId, name: $name}';
  }
}
