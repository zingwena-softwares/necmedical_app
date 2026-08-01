import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/employer/employee_model.dart';
import '../../models/employer/invoice_model.dart';
import '../../models/employer/payment_model.dart';
import '../../models/employer/payment_proof_model.dart';
import '../../models/employer/return_models.dart';
import '../../models/employer/statement_models.dart';
import 'employer_providers.dart';

typedef DateRangeCurrency = ({String dateFrom, String dateTo, int currency});
typedef YearCurrency = ({int year, int currency});

final statementsProvider = FutureProvider.autoDispose.family<StatementsResult, DateRangeCurrency>((ref, args) {
  return ref.watch(employerApiServiceProvider).statements(dateFrom: args.dateFrom, dateTo: args.dateTo, currency: args.currency);
});

final returnsProvider = FutureProvider.autoDispose.family<ReturnsResult, YearCurrency>((ref, args) {
  return ref.watch(employerApiServiceProvider).returns(year: args.year, currency: args.currency);
});

final returnDetailProvider = FutureProvider.autoDispose.family<ReturnDetailResult, int>((ref, rsId) {
  return ref.watch(employerApiServiceProvider).returnDetails(rsId);
});

final invoicesProvider = FutureProvider.autoDispose.family<InvoicesResult, DateRangeCurrency>((ref, args) {
  return ref.watch(employerApiServiceProvider).invoices(dateFrom: args.dateFrom, dateTo: args.dateTo, currency: args.currency);
});

final paymentsProvider = FutureProvider.autoDispose.family<PaymentsResult, DateRangeCurrency>((ref, args) {
  return ref.watch(employerApiServiceProvider).payments(dateFrom: args.dateFrom, dateTo: args.dateTo, currency: args.currency);
});

final employeesProvider = FutureProvider.autoDispose.family<EmployeesResult, String>((ref, search) {
  return ref.watch(employerApiServiceProvider).employees(search: search.isEmpty ? null : search);
});

final paymentProofsProvider = FutureProvider.autoDispose.family<PaymentProofsResult, String>((ref, status) {
  return ref.watch(employerApiServiceProvider).paymentProofs(status: status.isEmpty ? null : status);
});
