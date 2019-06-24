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

  Future<void> updateMeasure(Measure measure) async {
    await Firestore.instance
        .collection('measures')
        .document(measure.id)
        .updateData(measure.toFireJson());
  }

  Future<void> updateMeasurementConversion(
      MeasurementConversion measurementConversion) async {
    await Firestore.instance
        .collection('measurements_conversions')
        .document(measurementConversion.id)
        .updateData(measurementConversion.toFireJson());
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

    return MeasurementConversion(documentId, measureFrom, measureTo, value);
  }

  Future<List<MeasurementConversion>> fetchMeasurementConversionByFrom(
      Measure measureFrom) async {
    List<DocumentSnapshot> docsMeasurementConversion = List<DocumentSnapshot>();
    List<MeasurementConversion> measurementConversionList =
        List<MeasurementConversion>();
    Measure measureTo;
    String measureIdTo;

    /// Looking for the measurement conversion's data
    await Firestore.instance
        .collection('measurements_conversions')
        .where('measureIdFrom', isEqualTo: measureFrom.id)
        .getDocuments()
        .then((docSnapshot) {
      docsMeasurementConversion = docSnapshot.documents;
    });

    /// Iterate each document snapshot to find the measure "to" data
    await Future.forEach(docsMeasurementConversion,
        (docMeasurementConversion) async {
      MeasurementConversion measurementConversion;

      /// Getting the measure id "To"
      measureIdTo = docMeasurementConversion.data['measureIdTo'];

      /// Looking for measure "to" data
      measureTo = await fetchMeasureById(measureIdTo);

      /// Creating the object
      measurementConversion = MeasurementConversion.fromFireJson(
          docMeasurementConversion.documentID,
          measureFrom,
          measureTo,
          docMeasurementConversion.data);

      /// Creating the object Measurement Conversion and adding to the list
      measurementConversionList.add(measurementConversion);
    });
    return measurementConversionList;
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
