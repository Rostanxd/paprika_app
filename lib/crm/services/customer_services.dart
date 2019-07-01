import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/pos/models/invoice.dart';

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

  Future<int> customerNumberOfInvoices(String customerId) async {
    int numberTickets = 0;
    await Firestore.instance
        .collection('invoices')
        .where('customerId', isEqualTo: customerId)
        .getDocuments()
        .then((querySnapshot) {
      numberTickets = querySnapshot.documents.length;
    });
    return numberTickets;
  }

  Future<Invoice> customerLastInvoice(
      Enterprise enterprise, Branch branch, Customer customer) async {
    List<Invoice> invoiceList = List<Invoice>();
    Invoice invoice;
    await Firestore.instance
        .collection('invoices')
        .where('enterpriseId', isEqualTo: enterprise.id)
        .where('customerId', isEqualTo: customer.id)
        .orderBy('creationDate', descending: true)
        .limit(1)
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((i) => invoiceList
          .add(Invoice.fromFireJson(i.documentID, branch, customer, i.data)));
    });
    if (invoiceList.length == 0) return invoice;
    return invoice = invoiceList[0];
  }
}
