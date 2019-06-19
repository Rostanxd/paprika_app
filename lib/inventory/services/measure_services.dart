import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/inventory/models/measure.dart';

class MeasureApi {
  Future<Measure> fetchMeasureById(String measureId) async {
    Measure _measure;

    await Firestore.instance
        .collection('measures')
        .document(measureId)
        .get()
        .then((measure) {
      _measure = Measure.fromFireJson(measure.documentID, measure.data);
    });

    return _measure;
  }

  Future<DocumentReference> createMeasure(Measure measure) async {
    return await Firestore.instance
        .collection('measures')
        .add(measure.toFireJson());
  }

  Future<DocumentReference> createMeasurementConversion(
      MeasurementConversion measureConversion) async {
    return await Firestore.instance
        .collection('measurements_conversions')
        .add(measureConversion.toFireJson());
  }

  Future<List<Measure>> fetchMeasures() async {
    List<Measure> _measureList = List<Measure>();

    await Firestore.instance
        .collection('measures')
        .getDocuments()
        .then((measures) {
      _measureList.addAll(measures.documents
          .map((m) => Measure.fromFireJson(m.documentID, m.data)));
    });

    return _measureList;
  }

  Future<MeasurementConversion> fetchMeasurementConversionById(
      String documentId) async {
    double value;
    String measureIdFrom, measureIdTo;
    Measure measureFrom, measureTo;

    /// Looking for the measurement conversion's data
    await Firestore.instance
        .collection('measurement_conversion')
        .document(documentId)
        .get()
        .then((docSnapshot) {
      value = docSnapshot.data['value'];
      measureIdFrom = docSnapshot.data['measureIdFrom'];
      measureIdTo = docSnapshot.data['measureIdTo'];
    });

    /// Getting the object measure "from"
    measureFrom = await Firestore.instance
        .collection('measure')
        .document(measureIdFrom)
        .get()
        .then((docSnapshot) =>
            Measure.fromFireJson(docSnapshot.documentID, docSnapshot.data));

    /// Getting the object measure "to"
    measureTo = await Firestore.instance
        .collection('measure')
        .document(measureIdTo)
        .get()
        .then((docSnapshot) =>
            Measure.fromFireJson(docSnapshot.documentID, docSnapshot.data));

    return MeasurementConversion(measureFrom, measureTo, value);
  }

  Future<double> fetchMeasurementConversionValue(
      String measureIdFrom, String measureIdTo) async {
    /// Looking for the measurement conversion's data
    return await Firestore.instance
        .collection('measurement_conversion')
        .where('measureIdFrom', isEqualTo: measureIdFrom)
        .where('measureIdTo', isEqualTo: measureIdTo)
        .limit(1)
        .getDocuments()
        .then((docsSnapshot) => docsSnapshot.documents[0]['value']);
  }
}
