class Measure extends Object {
  String id;
  String name;

  Measure(this.id, this.name);

  Measure.fromFireJson(String documentId, Map<String, dynamic> json){
    this.id = documentId;
    this.name = json['name'];
  }

  Measure.fromJson(Map<String, dynamic> json){
    this.id = json['id'];
    this.name = json['name'];
  }

  @override
  String toString() {
    return 'Measure{id: $id, name: $name}';
  }

}