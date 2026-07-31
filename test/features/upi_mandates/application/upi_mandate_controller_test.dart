import 'package:firstpay/features/upi_mandates/application/upi_mandate_controller.dart';
import 'package:firstpay/features/upi_mandates/domain/upi_mandate.dart';
import 'package:firstpay/features/upi_mandates/domain/upi_mandate_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo implements UpiMandateRepository {
  FakeRepo(this.items);
  final List<UpiMandate> items;
  bool cancelled = false;
  @override
  Future<void> cancelDraft(String id) async {
    cancelled = true;
  }

  @override
  Future<UpiMandate> createDraft(UpiMandate v) async {
    items.add(v);
    return v;
  }

  @override
  Future<UpiMandate> getMandate(String id) async =>
      items.singleWhere((x) => x.id == id);
  @override
  Future<List<UpiMandate>> getMandates() async => List.of(items);
  @override
  Future<UpiMandate> updateDraft(UpiMandate v) async => v;
}

UpiMandate mandate({
  String id = '1',
  MandateStatus status = MandateStatus.draft,
  MandateFrequency frequency = MandateFrequency.monthly,
}) => UpiMandate(
  id: id,
  referenceNumber: 'ref-$id',
  organizationId: 'org',
  customerId: 'customer',
  bankAccount: '123456789',
  upiId: 'user@bank',
  mandateAmount: 100,
  maximumAmount: 500,
  frequency: frequency,
  startDate: DateTime(2026, 8, 1),
  endDate: DateTime(2027, 8, 1),
  purpose: 'Subscription',
  status: status,
);
void main() {
  test('search and filters combine', () async {
    final c = UpiMandateController(
      FakeRepo([
        mandate(),
        mandate(
          id: '2',
          status: MandateStatus.cancelled,
          frequency: MandateFrequency.yearly,
        ),
      ]),
    );
    await c.load();
    c.search('ref-2');
    c.filterStatus(MandateStatus.cancelled);
    c.filterFrequency(MandateFrequency.yearly);
    expect(c.state.filtered.single.id, '2');
  });
  test('cancel changes only a draft', () async {
    final v = mandate(), r = FakeRepo([v]), c = UpiMandateController(r);
    await c.load();
    expect(await c.cancel(v), isTrue);
    expect(r.cancelled, isTrue);
    expect(c.state.items.single.status, MandateStatus.cancelled);
  });
  test('non-draft cannot be edited', () async {
    final v = mandate(status: MandateStatus.pending),
        c = UpiMandateController(FakeRepo([v]));
    expect(await c.save(v, isNew: false), contains('Only draft'));
  });
}
