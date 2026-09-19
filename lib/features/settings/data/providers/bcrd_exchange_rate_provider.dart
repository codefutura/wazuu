import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../datasources/bcrd_exchange_rate_data_source.dart';

part 'bcrd_exchange_rate_provider.g.dart';

@riverpod
BcrdExchangeRateDataSource bcrdExchangeRateDataSource(Ref ref) =>
    const BcrdExchangeRateDataSource();
