import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/self_service/levy_model.dart';
import '../../models/self_service/reference_models.dart';
import 'self_service_providers.dart';

final selfServiceLookupsProvider = FutureProvider.autoDispose<SelfServiceLookups>((ref) {
  return ref.watch(selfServiceApiServiceProvider).lookups();
});

final selfServiceLeviesProvider = FutureProvider.autoDispose<List<Levy>>((ref) {
  return ref.watch(selfServiceApiServiceProvider).levies();
});

final selfServiceLeviesBalanceProvider = FutureProvider.autoDispose<LeviesBalance>((ref) {
  return ref.watch(selfServiceApiServiceProvider).leviesBalance();
});

final selfServiceLevyPaymentsProvider = FutureProvider.autoDispose<List<LevyPayment>>((ref) {
  return ref.watch(selfServiceApiServiceProvider).payments();
});
