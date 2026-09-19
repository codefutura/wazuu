import '../entities/banco_conectado.dart';
import '../entities/bank_option.dart';

abstract interface class BanksRepository {
  List<BankOption> supportedBanks();

  Future<void> saveConnectedBanks(Set<String> bankIds);

  Future<Set<String>> connectedBankIds();

  /// Filas reales de `bancos_conectados` (con `id` de base de datos) —
  /// usado para elegir a qué banco pertenece una tarjeta nueva.
  Future<List<BancoConectado>> obtenerConectados();
}
