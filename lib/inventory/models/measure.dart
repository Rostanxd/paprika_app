import 'package:paprika_app/authentication/models/enterprise.dart';

class Measure extends Object {
  String id;
  String name;
  bool standard;
  Enterprise enterprise;

  Measure(this.id, this.name, this.standard, this.enterprise);

  Measure.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;
    this.name = json['name'];
    this.standard = json['standard'];
  }

  Measure.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.name = json['name'];
    this.standard = json['standard'];
  }

  Map<String, dynamic> toFireJson() => {
        'name': this.name,
        'standard': this.standard,
        'enterpriseId': this.enterprise.id
      };

  @override
  String toString() {
    return 'Measure{id: $id, name: $name, standard: $standard}';
  }
}

class MeasurementConversion extends Object {
  String id;
  Measure measureFrom;
  Measure measureTo;
  double value;

  MeasurementConversion(this.measureFrom, this.measureTo, this.value);

  MeasurementConversion.fromFireJson(String documentId, Measure measureFrom,
      Measure measureTo, Map<String, dynamic> json) {
    this.id = documentId;
    this.measureFrom = measureFrom;
    this.measureTo = measureTo;
    this.value = json['value'];
  }

  Map<String, dynamic> toFireJson() => {
        'measureIdFrom': this.measureFrom.id,
        'measureIdTo': this.measureTo.id,
        'value': this.value
      };
}
