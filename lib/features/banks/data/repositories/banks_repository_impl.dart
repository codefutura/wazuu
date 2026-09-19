import '../../domain/entities/banco_conectado.dart';
import '../../domain/entities/bank_option.dart';
import '../../domain/repositories/banks_repository.dart';
import '../datasources/banks_sql_data_source.dart';

class BanksRepositoryImpl implements BanksRepository {
  BanksRepositoryImpl(this._dataSource);

  final BanksSqlDataSource _dataSource;

  @override
  List<BankOption> supportedBanks() => supportedBanksCatalog;

  @override
  Future<void> saveConnectedBanks(Set<String> bankIds) {
    final banks = supportedBanksCatalog
        .where((bank) => bankIds.contains(bank.id))
        .toList();
    return _dataSource.replaceConnected(banks);
  }

  @override
  Future<Set<String>> connectedBankIds() async {
    final names = await _dataSource.readConnectedNames();
    return supportedBanksCatalog
        .where((bank) => names.contains(bank.name))
        .map((bank) => bank.id)
        .toSet();
  }

  @override
  Future<List<BancoConectado>> obtenerConectados() =>
      _dataSource.readConnectedRows();
}
