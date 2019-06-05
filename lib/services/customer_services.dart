import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/models/customer.dart';

class CustomerApi {
  Future<Customer> fetchCustomerById(String customerId) async {
    Customer customer;
    await Firestore.instance
        .collection('customers')
        .document(customerId)
        .get()
        .then((document) {
      customer = Customer.fromFireJson(document.documentID, document.data);
    });
    return customer;
  }

  Future<List<Customer>> fetchCustomersById(String id) async {
    List<Customer> customerList = List<Customer>();
    await Firestore.instance
        .collection('customers')
        .where('id', isGreaterThanOrEqualTo: id)
        .getDocuments()
        .then((documents) => customerList.addAll(documents.documents
            .map((c) => Customer.fromFireJson(c.documentID, c.data))));
    return customerList;
  }

  Future<void> updateCustomer(String customerId, Customer customer) async {
    await Firestore.instance
        .collection('customers')
        .document(customerId)
        .updateData(customer.toFireJson());
  }

  Future<DocumentReference> createCustomer(Customer customer) async {
    return await Firestore.instance
        .collection('customers')
        .add(customer.toFireJson());
  }
}
