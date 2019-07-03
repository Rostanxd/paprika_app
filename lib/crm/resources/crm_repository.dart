import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/crm/services/customer_services.dart';
import 'package:paprika_app/pos/models/invoice.dart';

class CrmRepository {
  CustomerApi _customerApi = CustomerApi();

  Future<Customer> fetchCustomerById(String id) =>
      _customerApi.fetchCustomerById(id);

  Future<List<Customer>> fetchCustomersById(String id) =>
      _customerApi.fetchCustomersById(id);

  Future<void> updateCustomer(String customerId, Customer customer) =>
      _customerApi.updateCustomer(customerId, customer);

  Future<DocumentReference> createCustomer(Customer customer) =>
      _customerApi.createCustomer(customer);

  Future<int> customerNumberOfInvoices(
          Enterprise enterprise, String customerId) =>
      _customerApi.customerNumberOfInvoices(enterprise, customerId);

  Future<Invoice> customerLastInvoice(
          Enterprise enterprise, Customer customer) =>
      _customerApi.customerLastInvoice(enterprise, customer);
}
