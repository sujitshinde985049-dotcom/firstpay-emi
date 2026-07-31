import 'package:firstpay/features/enach_mandates/application/enach_mandate_controller.dart';
import 'package:firstpay/features/enach_mandates/domain/enach_mandate.dart';
import 'package:firstpay/features/enach_mandates/domain/enach_mandate_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo implements EnachMandateRepository {
  FakeRepo(this.items);
  final List<EnachMandate> items;
  bool cancelled = false;
  @override
  Future<void> cancelDraft(String id) async {
    cancelled = true;
  }

  @override
  Future<EnachMandate> createDraft(EnachMandate v) async {
    items.add(v);
    return v;
  }

  @override
  Future<EnachMandate> getMandate(String id) async =>
      items.singleWhere((x) => x.id == id);
  @override
  Future<List<EnachMandate>> getMandates() async => List.of(items);
  @override
  Future<EnachMandate> updateDraft(EnachMandate v) async => v;
}

EnachMandate mandate({
  String id = '1',
  EnachStatus status = EnachStatus.draft,
}) => EnachMandate(
  id: id,
  referenceNumber: 'ref-$id',
  organizationId: 'org',
  customerId: 'customer',
  accountHolderName: 'Asha',
  bankName: 'Bank',
  branchName: 'Main',
  accountNumber: '123456789',
  ifscCode: 'HDFC0001234',
  accountType: 'savings',
  maximumDebitAmount: 1000,
  frequency: EnachFrequency.monthly,
  startDate: DateTime(2026, 8, 1),
  endDate: DateTime(2027, 8, 1),
  purpose: 'Collection',
  sponsorBank: 'Sponsor',
  destinationBank: 'Destination',
  authenticationMode: EnachAuthenticationMode.netBanking,
  status: status,
);
void main() {
  test('search and status filter combine', () async {
    final c = EnachMandateController(
      FakeRepo([mandate(), mandate(id: '2', status: EnachStatus.cancelled)]),
    );
    await c.load();
    c.search('ref-2');
    c.filterStatus(EnachStatus.cancelled);
    expect(c.state.filtered.single.id, '2');
  });
  test('cancels only draft', () async {
    final v = mandate(), r = FakeRepo([v]), c = EnachMandateController(r);
    await c.load();
    expect(await c.cancel(v), isTrue);
    expect(r.cancelled, isTrue);
    expect(c.state.items.single.status, EnachStatus.cancelled);
  });
  test('rejects editing non-draft', () async {
    final v = mandate(status: EnachStatus.pending),
        c = EnachMandateController(FakeRepo([v]));
    expect(await c.save(v, isNew: false), contains('Only draft'));
  });
}
