import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/models/measure.dart';

class MeasureApi {
  Future<Measure> fetchMeasureById(String measureId) async {
    Measure _measure;

    await Firestore.instance
        .collection('measures')
        .document(measureId)
        .get()
        .then((measure) {
      _measure = Measure.fromFireJson(measure.documentID, measure.data);
      print(_measure.toString());
    });

    return _measure;
  }

  Future<List<Measure>> fetchMeasures() async {
    List<Measure> _measureList = List<Measure>();

    await Firestore.instance.collection('measures').getDocuments().then((measures) {
      _measureList.addAll(measures.documents
          .map((m) => Measure.fromFireJson(m.documentID, m.data)));
    });
    return _measureList;
  }
}
