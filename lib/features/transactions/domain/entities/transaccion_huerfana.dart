/// Proyección mínima de una transacción sin tarjeta asociada — ver
/// `TransaccionesRepository.obtenerHuerfanasPorBanco`.
class TransaccionHuerfana {
  const TransaccionHuerfana({required this.id, required this.emailIdOrigen});

  final int id;
  final String emailIdOrigen;
}
