import 'package:firstpay/features/enach_mandates/data/supabase_enach_mandate_repository.dart';
import 'package:firstpay/features/enach_mandates/domain/enach_mandate.dart';
import 'package:firstpay/features/enach_mandates/domain/enach_mandate_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnachMandateState {
  const EnachMandateState({
    this.items = const [],
    this.query = '',
    this.statusFilter,
    this.loading = false,
    this.saving = false,
    this.error,
  });
  final List<EnachMandate> items;
  final String query;
  final EnachStatus? statusFilter;
  final bool loading, saving;
  final String? error;
  List<EnachMandate> get filtered {
    final q = query.trim().toLowerCase();
    return items
        .where(
          (m) =>
              (statusFilter == null || m.status == statusFilter) &&
              (q.isEmpty ||
                  m.referenceNumber.toLowerCase().contains(q) ||
                  m.accountHolderName.toLowerCase().contains(q) ||
                  m.accountNumber.contains(q) ||
                  m.purpose.toLowerCase().contains(q)),
        )
        .toList(growable: false);
  }

  EnachMandateState copyWith({
    List<EnachMandate>? items,
    String? query,
    EnachStatus? statusFilter,
    bool clearStatus = false,
    bool? loading,
    bool? saving,
    String? error,
    bool clearError = false,
  }) => EnachMandateState(
    items: items ?? this.items,
    query: query ?? this.query,
    statusFilter: clearStatus ? null : statusFilter ?? this.statusFilter,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    error: clearError ? null : error ?? this.error,
  );
}

final enachMandateRepositoryProvider = Provider<EnachMandateRepository>(
  (ref) => SupabaseEnachMandateRepository(Supabase.instance.client),
);
final enachMandateControllerProvider =
    StateNotifierProvider<EnachMandateController, EnachMandateState>((ref) {
      final c = EnachMandateController(
        ref.watch(enachMandateRepositoryProvider),
      );
      c.load();
      return c;
    });

class EnachMandateController extends StateNotifier<EnachMandateState> {
  EnachMandateController(this.repo) : super(const EnachMandateState());
  final EnachMandateRepository repo;
  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      state = state.copyWith(items: await repo.getMandates(), loading: false);
    } on EnachMandateFailure catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    }
  }

  void search(String v) => state = state.copyWith(query: v);
  void filterStatus(EnachStatus? v) =>
      state = state.copyWith(statusFilter: v, clearStatus: v == null);
  Future<EnachMandate> get(String id) => repo.getMandate(id);
  Future<String?> save(EnachMandate v, {required bool isNew}) async {
    state = state.copyWith(saving: true, clearError: true);
    try {
      if (isNew) {
        await repo.createDraft(v);
      } else {
        if (v.status != EnachStatus.draft) {
          state = state.copyWith(saving: false);
          return 'Only draft e-NACH mandates can be edited.';
        }
        await repo.updateDraft(v);
      }
      await load();
      state = state.copyWith(saving: false);
      return null;
    } on EnachMandateFailure catch (e) {
      state = state.copyWith(saving: false, error: e.message);
      return e.message;
    }
  }

  Future<bool> cancel(EnachMandate v) async {
    if (v.status != EnachStatus.draft) return false;
    try {
      await repo.cancelDraft(v.id);
      state = state.copyWith(
        items: state.items
            .map(
              (x) =>
                  x.id == v.id ? x.copyWith(status: EnachStatus.cancelled) : x,
            )
            .toList(growable: false),
      );
      return true;
    } on EnachMandateFailure catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    }
  }
}
