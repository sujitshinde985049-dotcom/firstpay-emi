import 'package:firstpay/features/organizations/data/supabase_organization_repository.dart';
import 'package:firstpay/features/organizations/domain/organization.dart';
import 'package:firstpay/features/organizations/domain/organization_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizationState {
  const OrganizationState({
    this.organizations = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final List<Organization> organizations;
  final String searchQuery;
  final OrganizationStatus? statusFilter;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  List<Organization> get filteredOrganizations {
    final query = searchQuery.trim().toLowerCase();
    return organizations
        .where((organization) {
          final matchesStatus =
              statusFilter == null || organization.status == statusFilter;
          final matchesSearch =
              query.isEmpty ||
              organization.name.toLowerCase().contains(query) ||
              organization.registrationNumber.toLowerCase().contains(query) ||
              organization.city.toLowerCase().contains(query) ||
              organization.contactPerson.toLowerCase().contains(query);
          return matchesStatus && matchesSearch;
        })
        .toList(growable: false);
  }

  OrganizationState copyWith({
    List<Organization>? organizations,
    String? searchQuery,
    OrganizationStatus? statusFilter,
    bool clearStatusFilter = false,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) => OrganizationState(
    organizations: organizations ?? this.organizations,
    searchQuery: searchQuery ?? this.searchQuery,
    statusFilter: clearStatusFilter ? null : statusFilter ?? this.statusFilter,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return SupabaseOrganizationRepository(Supabase.instance.client);
});

final organizationControllerProvider =
    StateNotifierProvider<OrganizationController, OrganizationState>((ref) {
      final controller = OrganizationController(
        ref.watch(organizationRepositoryProvider),
      );
      controller.load();
      return controller;
    });

class OrganizationController extends StateNotifier<OrganizationState> {
  OrganizationController(this._repository) : super(const OrganizationState());

  final OrganizationRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final organizations = await _repository.getOrganizations();
      state = state.copyWith(
        organizations: organizations,
        isLoading: false,
        clearError: true,
      );
    } on OrganizationFailure catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void setStatusFilter(OrganizationStatus? value) {
    state = state.copyWith(
      statusFilter: value,
      clearStatusFilter: value == null,
    );
  }

  Future<Organization> getOrganization(String id) {
    return _repository.getOrganization(id);
  }

  Future<String?> save(Organization organization, {required bool isNew}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final duplicate = await _repository.registrationNumberExists(
        organization.registrationNumber,
        excludeId: isNew ? null : organization.id,
      );
      if (duplicate) {
        state = state.copyWith(isSaving: false);
        return const DuplicateRegistrationNumberFailure().message;
      }
      if (isNew) {
        await _repository.createOrganization(organization);
      } else {
        await _repository.updateOrganization(organization);
      }
      await load();
      state = state.copyWith(isSaving: false);
      return null;
    } on OrganizationFailure catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.message);
      return error.message;
    }
  }

  Future<bool> toggleStatus(Organization organization) async {
    final nextStatus = organization.status == OrganizationStatus.active
        ? OrganizationStatus.inactive
        : OrganizationStatus.active;
    try {
      await _repository.updateStatus(organization.id, nextStatus);
      final updated = state.organizations
          .map(
            (item) => item.id == organization.id
                ? item.copyWith(status: nextStatus)
                : item,
          )
          .toList(growable: false);
      state = state.copyWith(organizations: updated, clearError: true);
      return true;
    } on OrganizationFailure catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    }
  }
}
