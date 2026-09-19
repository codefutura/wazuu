import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_flow/app_flow_controller.dart';
import '../../../../core/theme/app_colors.dart';

class _PrivacyCard {
  const _PrivacyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

/// Carrusel de privacidad — 4 tarjetas swipeables, primer contacto del
/// usuario con la app (ver sección 5 de CLAUDE.md). Los textos son los
/// definidos ahí, no se parafrasean.
class PrivacyCarouselScreen extends ConsumerStatefulWidget {
  const PrivacyCarouselScreen({super.key});

  @override
  ConsumerState<PrivacyCarouselScreen> createState() =>
      _PrivacyCarouselScreenState();
}

class _PrivacyCarouselScreenState
    extends ConsumerState<PrivacyCarouselScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _cards = [
    _PrivacyCard(
      icon: Icons.visibility_outlined,
      title: 'Solo miramos, no tocamos',
      subtitle:
          'Accedemos a tu correo en modo solo lectura. Nunca enviamos ni '
          'eliminamos nada en tu nombre.',
    ),
    _PrivacyCard(
      icon: Icons.lock_outline,
      title: 'Tus datos viajan protegidos',
      subtitle:
          'Toda tu información financiera se guarda cifrada en tu '
          'dispositivo. Nadie más puede leerla.',
    ),
    _PrivacyCard(
      icon: Icons.mark_email_read_outlined,
      title: 'Ignoramos el resto de tu correo',
      subtitle:
          'Solo procesamos los correos de los bancos que tú conectes. El '
          'resto de tu bandeja nunca se abre ni se guarda.',
    ),
    _PrivacyCard(
      icon: Icons.smart_toy_outlined,
      title: 'Tu info no entrena ninguna IA',
      subtitle:
          'Tus datos nunca se usan para publicidad ni para entrenar '
          'modelos de inteligencia artificial.',
    ),
  ];

  bool get _isLastPage => _page == _cards.length - 1;

  void _next() {
    if (_isLastPage) {
      ref.read(appFlowControllerProvider.notifier).completePrivacyCarousel();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _cards.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: AppColors.mintLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            card.icon,
                            size: 44,
                            color: AppColors.teal,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          card.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          card.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _cards.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == _page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _page
                        ? AppColors.teal
                        : Theme.of(context).colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: _next,
                child: Text(_isLastPage ? 'Comenzar' : 'Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
