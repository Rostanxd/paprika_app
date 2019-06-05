import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/models/customer.dart';
import 'package:paprika_app/services/customer_services.dart';

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
}
