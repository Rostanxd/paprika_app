import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/services/branch_services.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/pos/models/document.dart';

class CustomerApi {
  BranchFirebaseApi _branchFirebaseApi = BranchFirebaseApi();

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

  Future<List<Customer>> fetchCustomersById(String idToFind) async {
    List<Customer> customerList = List<Customer>();
    await Firestore.instance
        .collection('customers')
        .where('id', isGreaterThanOrEqualTo: idToFind)
        .getDocuments()
        .then((documents) {
      customerList.addAll(documents.documents.where((doc) {
        String id = doc.data['id'];
        return id.contains(idToFind);
      }).map((c) => Customer.fromFireJson(c.documentID, c.data)));
    });
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

  Future<int> customerNumberOfInvoices(
      Enterprise enterprise, String customerId) async {
    int numberTickets = 0;
    Branch branch;
    List<DocumentSnapshot> invoiceDocsSnapshot = List<DocumentSnapshot>();

    await Firestore.instance
        .collection('documents')
        .where('customerId', isEqualTo: customerId)
        .where('type', isEqualTo: 'I')
        .where('state', isEqualTo: 'A')
        .getDocuments()
        .then((querySnapshot) {
      invoiceDocsSnapshot.addAll(querySnapshot.documents);
    });

    /// Invoices details
    await Future.forEach(invoiceDocsSnapshot, (doc) async {
      branch = await _branchFirebaseApi.fetchBranchById(doc.data['branchId']);

      /// Only our enterprise
      if (branch.enterprise.id == enterprise.id) {
        numberTickets += 1;
      }
    });

    return numberTickets;
  }

  Future<Document> customerLastInvoice(
      Enterprise enterprise, Customer customer) async {
    Document invoice;
    List<Document> invoiceList = List<Document>();
    List<DocumentSnapshot> invoiceDocsSnapshot = List<DocumentSnapshot>();

    /// Invoices
    await Firestore.instance
        .collection('documents')
        .where('customerId', isEqualTo: customer.customerId)
        .where('type', isEqualTo: 'I')
        .where('state', isEqualTo: 'A')
        .orderBy('creationDate', descending: true)
        .limit(1)
        .getDocuments()
        .then((querySnapshot) {
      invoiceDocsSnapshot.addAll(querySnapshot.documents);
    });

    /// We need to validate our enterprise here!!
    invoiceDocsSnapshot.forEach((doc) =>
        invoiceList.add(Document.fromFireJson(doc.documentID, doc.data)));

    if (invoiceList.length == 0) return invoice;
    return invoiceList[0];
  }
}
