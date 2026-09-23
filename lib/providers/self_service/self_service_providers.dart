import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/self_service_api_client.dart';
import '../../services/self_service/self_service_api_service.dart';
import 'self_service_employer_providers.dart';

final selfServiceApiClientProvider = Provider<SelfServiceApiClient>((ref) {
  return SelfServiceApiClient(onUnauthorized: () => ref.read(selfServiceEmployerAuthProvider.notifier).handleUnauthorized());
});

final selfServiceApiServiceProvider = Provider<SelfServiceApiService>((ref) {
  return SelfServiceApiService(ref.watch(selfServiceApiClientProvider));
});
