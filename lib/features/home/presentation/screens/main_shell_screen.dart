import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    setState(() => _sincronizando = true);
    try {
      final servicio = await ref.read(gmailSyncServiceProvider.future);
      final resultado = await servicio.sincronizar();

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
      if (mounted) setState(() => _sincronizando = false);
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
      body: AnimatedSwitcher(
        // Sección 4 de CLAUDE.md: transiciones de 200-300ms, nunca
        // instantáneas ni lentas.
        duration: const Duration(milliseconds: 250),
        child: _screens[index],
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
