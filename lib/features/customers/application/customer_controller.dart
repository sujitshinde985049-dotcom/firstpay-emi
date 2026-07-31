import 'package:firstpay/features/customers/data/supabase_customer_repository.dart';
import 'package:firstpay/features/customers/domain/customer.dart';
import 'package:firstpay/features/customers/domain/customer_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerState {
  const CustomerState({
    this.customers = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });
  final List<Customer> customers;
  final String searchQuery;
  final CustomerStatus? statusFilter;
  final bool isLoading, isSaving;
  final String? errorMessage;
  List<Customer> get filteredCustomers {
    final q = searchQuery.trim().toLowerCase();
    return customers
        .where(
          (c) =>
              (statusFilter == null || c.status == statusFilter) &&
              (q.isEmpty ||
                  c.fullName.toLowerCase().contains(q) ||
                  c.mobile.contains(q) ||
                  (c.aadhaarNumber ?? '').contains(q) ||
                  (c.panNumber ?? '').toLowerCase().contains(q) ||
                  c.accountNumber.contains(q)),
        )
        .toList(growable: false);
  }

  CustomerState copyWith({
    List<Customer>? customers,
    String? searchQuery,
    CustomerStatus? statusFilter,
    bool clearStatus = false,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) => CustomerState(
    customers: customers ?? this.customers,
    searchQuery: searchQuery ?? this.searchQuery,
    statusFilter: clearStatus ? null : statusFilter ?? this.statusFilter,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => SupabaseCustomerRepository(Supabase.instance.client),
);
final customerControllerProvider =
    StateNotifierProvider<CustomerController, CustomerState>((ref) {
      final c = CustomerController(ref.watch(customerRepositoryProvider));
      c.load();
      return c;
    });

class CustomerController extends StateNotifier<CustomerState> {
  CustomerController(this._repository) : super(const CustomerState());
  final CustomerRepository _repository;
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      state = state.copyWith(
        customers: await _repository.getCustomers(),
        isLoading: false,
        clearError: true,
      );
    } on CustomerFailure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  void setSearchQuery(String v) => state = state.copyWith(searchQuery: v);
  void setStatusFilter(CustomerStatus? v) =>
      state = state.copyWith(statusFilter: v, clearStatus: v == null);
  Future<Customer> getCustomer(String id) => _repository.getCustomer(id);
  Future<String?> save(Customer c, {required bool isNew}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      if (await _repository.mobileExists(
        c.organizationId,
        c.mobile,
        excludeId: isNew ? null : c.id,
      )) {
        state = state.copyWith(isSaving: false);
        return const DuplicateCustomerMobileFailure().message;
      }
      if (isNew) {
        await _repository.createCustomer(c);
      } else {
        await _repository.updateCustomer(c);
      }
      await load();
      state = state.copyWith(isSaving: false);
      return null;
    } on CustomerFailure catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.message);
      return e.message;
    }
  }

  Future<bool> toggleStatus(Customer c) async {
    final next = c.status == CustomerStatus.active
        ? CustomerStatus.inactive
        : CustomerStatus.active;
    try {
      await _repository.updateStatus(c.id, next);
      state = state.copyWith(
        customers: state.customers
            .map((x) => x.id == c.id ? x.copyWith(status: next) : x)
            .toList(growable: false),
        clearError: true,
      );
      return true;
    } on CustomerFailure catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }
}
