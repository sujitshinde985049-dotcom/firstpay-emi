import 'package:firstpay/features/upi_mandates/data/supabase_upi_mandate_repository.dart';
import 'package:firstpay/features/upi_mandates/domain/upi_mandate.dart';
import 'package:firstpay/features/upi_mandates/domain/upi_mandate_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpiMandateState {
  const UpiMandateState({
    this.items = const [],
    this.query = '',
    this.statusFilter,
    this.frequencyFilter,
    this.loading = false,
    this.saving = false,
    this.error,
  });
  final List<UpiMandate> items;
  final String query;
  final MandateStatus? statusFilter;
  final MandateFrequency? frequencyFilter;
  final bool loading, saving;
  final String? error;
  List<UpiMandate> get filtered {
    final q = query.trim().toLowerCase();
    return items
        .where(
          (m) =>
              (statusFilter == null || m.status == statusFilter) &&
              (frequencyFilter == null || m.frequency == frequencyFilter) &&
              (q.isEmpty ||
                  m.referenceNumber.toLowerCase().contains(q) ||
                  m.upiId.toLowerCase().contains(q) ||
                  m.purpose.toLowerCase().contains(q) ||
                  m.bankAccount.contains(q)),
        )
        .toList(growable: false);
  }

  UpiMandateState copyWith({
    List<UpiMandate>? items,
    String? query,
    MandateStatus? statusFilter,
    MandateFrequency? frequencyFilter,
    bool clearStatus = false,
    bool clearFrequency = false,
    bool? loading,
    bool? saving,
    String? error,
    bool clearError = false,
  }) => UpiMandateState(
    items: items ?? this.items,
    query: query ?? this.query,
    statusFilter: clearStatus ? null : statusFilter ?? this.statusFilter,
    frequencyFilter: clearFrequency
        ? null
        : frequencyFilter ?? this.frequencyFilter,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    error: clearError ? null : error ?? this.error,
  );
}

final upiMandateRepositoryProvider = Provider<UpiMandateRepository>(
  (ref) => SupabaseUpiMandateRepository(Supabase.instance.client),
);
final upiMandateControllerProvider =
    StateNotifierProvider<UpiMandateController, UpiMandateState>((ref) {
      final c = UpiMandateController(ref.watch(upiMandateRepositoryProvider));
      c.load();
      return c;
    });

class UpiMandateController extends StateNotifier<UpiMandateState> {
  UpiMandateController(this.repo) : super(const UpiMandateState());
  final UpiMandateRepository repo;
  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      state = state.copyWith(items: await repo.getMandates(), loading: false);
    } on UpiMandateFailure catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    }
  }

  void search(String v) => state = state.copyWith(query: v);
  void filterStatus(MandateStatus? v) =>
      state = state.copyWith(statusFilter: v, clearStatus: v == null);
  void filterFrequency(MandateFrequency? v) =>
      state = state.copyWith(frequencyFilter: v, clearFrequency: v == null);
  Future<UpiMandate> get(String id) => repo.getMandate(id);
  Future<String?> save(UpiMandate v, {required bool isNew}) async {
    state = state.copyWith(saving: true, clearError: true);
    try {
      if (isNew) {
        await repo.createDraft(v);
      } else {
        if (v.status != MandateStatus.draft) {
          state = state.copyWith(saving: false);
          return 'Only draft mandates can be edited.';
        }
        await repo.updateDraft(v);
      }
      await load();
      state = state.copyWith(saving: false);
      return null;
    } on UpiMandateFailure catch (e) {
      state = state.copyWith(saving: false, error: e.message);
      return e.message;
    }
  }

  Future<bool> cancel(UpiMandate v) async {
    if (v.status != MandateStatus.draft) return false;
    try {
      await repo.cancelDraft(v.id);
      state = state.copyWith(
        items: state.items
            .map(
              (x) => x.id == v.id
                  ? x.copyWith(status: MandateStatus.cancelled)
                  : x,
            )
            .toList(growable: false),
      );
      return true;
    } on UpiMandateFailure catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    }
  }
}
