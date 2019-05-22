class Measure extends Object {
  String id;
  String name;

  Measure(this.id, this.name);

  Measure.fromJson(Map<String, dynamic> json){
    this.id = json['id'];
    this.name = json['name'];
  }
}