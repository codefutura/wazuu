import '../../../../core/domain/tipo_transaccion.dart';

class Categoria {
  const Categoria({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.color,
    required this.icono,
  });

  final int id;
  final String nombre;
  final TipoTransaccion tipo;
  final String color;
  final String icono;
}
