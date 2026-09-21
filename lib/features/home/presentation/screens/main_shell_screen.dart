import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../budgets/presentation/providers/presupuestos_provider.dart';
import '../../../budgets/presentation/screens/budgets_screen.dart';
import '../../../cards/presentation/providers/tarjetas_consumo_provider.dart';
import '../../../cards/presentation/screens/cards_screen.dart';
import '../../../sync/data/providers/sync_providers.dart';
import '../../../sync/domain/entities/sync_result.dart';
import '../../../transactions/presentation/providers/transacciones_filtro_provider.dart';
import '../../../transactions/presentation/screens/transactions_list_screen.dart';
import '../providers/resumen_mensual_provider.dart';
import '../providers/tab_seleccionado_provider.dart';
import '../widgets/app_drawer.dart';
import 'resumen_mensual_screen.dart';

/// Shell con navegación inferior entre las pantallas principales del
/// MVP (sección 9 de CLAUDE.md): resumen mensual, transacciones,
/// tarjetas y presupuestos.
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  bool _sincronizando = false;
  int? _correosProcesados;
  int? _correosTotal;

  static const _titulos = [
    'Resumen',
    'Transacciones',
    'Tarjetas',
    'Presupuestos',
  ];
  static const _screens = [
    ResumenMensualScreen(),
    TransactionsListScreen(),
    CardsScreen(),
    BudgetsScreen(),
  ];

  Future<void> _sincronizar() async {
    setState(() {
      _sincronizando = true;
      _correosProcesados = null;
      _correosTotal = null;
    });
    try {
      final servicio = await ref.read(gmailSyncServiceProvider.future);
      final resultado = await servicio.sincronizar(
        onProgress: (procesados, total) {
          if (!mounted) return;
          setState(() {
            _correosProcesados = procesados;
            _correosTotal = total;
          });
        },
      );

      ref
        ..invalidate(transaccionesFiltradasProvider)
        ..invalidate(resumenMensualProvider)
        ..invalidate(tarjetasConsumoProvider)
        ..invalidate(presupuestosConProgresoProvider);

      if (!mounted) return;
      final mensaje = resultado.error ?? _mensajeResultado(resultado);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo sincronizar: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _sincronizando = false;
          _correosProcesados = null;
          _correosTotal = null;
        });
      }
    }
  }

  String _mensajeResultado(SyncResult resultado) {
    final partes = <String>[];
    if (resultado.transaccionesNuevas > 0) {
      partes.add('${resultado.transaccionesNuevas} nueva(s)');
    }
    if (resultado.transaccionesVinculadas > 0) {
      partes.add('${resultado.transaccionesVinculadas} vinculada(s) a tarjeta');
    }
    if (partes.isEmpty) return 'No hay transacciones nuevas.';
    return '${partes.join(', ')}.';
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(tabSeleccionadoControllerProvider);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(_titulos[index]),
        actions: [
          IconButton(
            icon: _sincronizando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Sincronizar con Gmail',
            onPressed: _sincronizando ? null : _sincronizar,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_sincronizando) _SyncProgressBar(
            procesados: _correosProcesados,
            total: _correosTotal,
          ),
          Expanded(
            child: AnimatedSwitcher(
              // Sección 4 de CLAUDE.md: transiciones de 200-300ms,
              // nunca instantáneas ni lentas.
              duration: const Duration(milliseconds: 250),
              child: _screens[index],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (nuevoIndex) => ref
            .read(tabSeleccionadoControllerProvider.notifier)
            .establecer(nuevoIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Resumen',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transacciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Tarjetas',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Presupuestos',
          ),
        ],
      ),
    );
  }
}

/// Barra de progreso real de la sincronización, justo debajo del AppBar
/// — reemplaza al spinner indeterminado del ícono con un porcentaje
/// concreto de correos ya procesados (sección 4 de CLAUDE.md: "carga
/// progresiva, no bloqueante").
class _SyncProgressBar extends StatelessWidget {
  const _SyncProgressBar({required this.procesados, required this.total});

  final int? procesados;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final conocido = total != null && total! > 0;
    final valor = conocido ? (procesados ?? 0) / total! : null;
    final porcentaje = conocido ? ((valor ?? 0) * 100).round() : null;

    return Container(
      color: AppColors.teal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: valor,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            conocido
                ? 'Sincronizando correos… $porcentaje% ($procesados/$total)'
                : 'Buscando correos nuevos…',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mintLight,
            ),
          ),
        ],
      ),
    );
  }
}
