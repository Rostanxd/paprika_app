import 'package:paprika_app/models/customer.dart';
import 'package:paprika_app/services/customer_services.dart';

class CustomerRepository {
  CustomerApi _customerApi = CustomerApi();

  Future<Customer> fetchCustomerById(String id) =>
      _customerApi.fetchCustomerById(id);

  Future<List<Customer>> fetchCustomersById(String id) =>
      _customerApi.fetchCustomersById(id);
}
