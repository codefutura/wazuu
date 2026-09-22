# Wazuu — Contexto del proyecto

App Flutter de finanzas personales que lee notificaciones de transacciones bancarias
desde el correo (Gmail API), las categoriza automáticamente y ayuda al usuario a
controlar su presupuesto. Enfocada en el mercado dominicano.

**Dominio:** wazuu.com.do
**Icono de la app:** ya disponible en `assets/images/` — usarlo como fuente para
generar los iconos adaptativos de Android/iOS (no regenerar desde cero).

---

## 1. Principio rector de todo el proyecto

> "Solo miramos, no tocamos." Este proyecto maneja datos financieros sensibles.
> Cada decisión técnica debe poder defenderse frente a esa promesa. Antes de
> implementar algo que toque correos, tokens o datos bancarios, pregúntate:
> ¿esto respeta lectura-only, cifrado en reposo, y cero entrenamiento de IA con
> los datos del usuario?

---

## 2. Stack técnico y convenciones (obligatorias)

- **Flutter**, arquitectura **feature-first Clean Architecture** — cero lógica de
  negocio en widgets.
- **Riverpod exclusivamente con el generador `@riverpod`** — nunca `StateNotifier`
  manual ni `Provider` clásico.
- **Credenciales y claves en `.dart_defines.json`**, nunca en `.env` ni hardcodeadas.
  Ejecutar siempre con `--dart-define-from-file=.dart_defines.json`.
- **Base de datos:** `sqflite` + cifrado (`sqflite_sqlcipher`). La base de datos
  local NUNCA se guarda sin cifrar — esto no es negociable, es parte de la promesa
  de privacidad del producto.
- **Autenticación local:** email + password almacenados localmente con hash
  SHA-256 (mismo patrón usado en FuturaCobros). El login debe funcionar 100%
  offline — el usuario abre la app, entra con su password local, y ve sus datos
  ya sincronizados sin necesidad de internet.
- **Internet solo se requiere para:**
  1. El flujo OAuth de conexión con Gmail (una vez, o al reconectar).
  2. La sincronización periódica que busca correos nuevos de bancos.
  Todo lo demás (ver transacciones, presupuestos, gráficas, tarjetas) debe
  funcionar sin conexión.
- **Tipografía:** `google_fonts` — Space Grotesk (títulos/montos), Inter (cuerpo/UI).
- **Gráficas:** `fl_chart`.
- **Notificaciones locales:** `flutter_local_notifications` (alertas de presupuesto).
- **Gmail API:** `googleapis` + `google_sign_in`, scope único `gmail.readonly`.
  Nunca solicitar `gmail.modify` ni `gmail.send`.
- **Storage seguro de tokens OAuth:** `flutter_secure_storage` (Keychain/Keystore
  nativo), nunca en la base de datos SQLite ni en shared_preferences.

---

## 3. Paleta de colores

| Uso | Color | Hex |
|---|---|---|
| Primario | Teal profundo | `#0F766E` |
| Primario claro / fondos | Mint claro | `#CCFBF1` |
| Acento / sobre-presupuesto | Coral | `#FB7185` |
| Éxito / dentro de presupuesto | Verde | `#22C55E` |
| Advertencia / cerca del límite | Ámbar | `#F59E0B` |
| Fondo neutro (tema claro) | Blanco cálido | `#FFF7ED` |
| Texto principal (tema claro) | Gris casi negro | `#1E293B` |
| Texto secundario | Gris medio | `#64748B` |

**Tema oscuro:** invertir la lógica de fondo/texto manteniendo el mismo teal
primario y el mismo sistema semántico verde/ámbar/coral (estos tres NO cambian
entre temas — son códigos de estado, deben ser reconocibles igual en ambos).
Fondo oscuro sugerido: `#0F172A`, superficie de tarjetas: `#1E293B`.

Implementar con `ThemeData` claro y oscuro usando `ColorScheme`, y respetar
`ThemeMode.system` por defecto (el usuario puede forzar claro/oscuro en ajustes).

---

## 4. Principios UX/UI a aplicar

- **Feedback inmediato:** toda acción (guardar, categorizar, conectar banco) debe
  tener confirmación visual clara (snackbar, animación sutil, no solo silencio).
- **Consistencia:** un mismo componente (ej. tarjeta de transacción, chip de
  categoría) se ve y comporta igual en toda la app.
- **Jerarquía visual clara:** las cifras de dinero son lo más prominente en
  cualquier pantalla — nunca compiten visualmente con iconos decorativos.
- **Tolerancia a errores:** cualquier categorización automática debe ser editable
  con un tap — el usuario nunca debe sentirse "atrapado" por una decisión del
  sistema.
- **Carga progresiva, no bloqueante:** al sincronizar correos, mostrar skeleton
  loaders o datos ya cacheados mientras llega lo nuevo — nunca una pantalla en
  blanco con spinner centrado como única opción.
- **Fluidez:** transiciones de página con `Hero` donde aporte (ej. tarjeta →
  detalle de tarjeta), animaciones de 200-300ms, nunca instantáneas ni lentas.
- **Accesibilidad:** contraste AA mínimo en ambos temas, tamaños de texto que
  respeten el escalado del sistema (no fijar `fontSize` sin `textScaler`).

---

## 5. Flujo de onboarding (primera vez)

**Paso 0 — Carrusel de privacidad (4 tarjetas swipeables), antes que nada:**
1. "Solo miramos, no tocamos" — scope readonly, nunca enviamos/eliminamos.
2. "Tus datos viajan protegidos" — cifrado local, nadie puede leerlo.
3. "Ignoramos el resto de tu correo" — solo procesamos correos de bancos conocidos.
4. "Tu info no entrena ninguna IA" — nunca se usa para publicidad ni entrenar modelos.

**Configuración en 3 pasos (después del carrusel de privacidad):**
1. **Crear cuenta local** — email + password (se guarda hasheado localmente,
   permite login offline desde el primer momento).
2. **Conectar Gmail** — botón "Conectar con Google", flujo OAuth, selección de
   qué bancos monitorear (checklist de bancos soportados).
3. **Presupuesto inicial** — el usuario define un presupuesto total o por
   categoría para empezar (puede editarlo después); si no quiere configurar
   nada aún, permitir "Saltar por ahora".

Cada paso debe poder retomarse si el usuario cierra la app a mitad de camino
(guardar progreso del onboarding en SQLite local).

---

## 6. Modelo de datos (SQLite cifrado)

Tablas principales:

- **usuarios** — email, password_hash, tasa_cambio_referencia, fecha_actualizacion_tasa
- **bancos_conectados** — nombre_banco, remitente_email, activo
- **tarjetas** — apodo, ultimos_4_digitos, tipo (debito/credito), banco_id,
  limite_credito (nullable), fecha_corte (nullable), fecha_pago (nullable)
- **transacciones** — monto, moneda (DOP/USD), fecha, comercio, estado
  (aprobada/declinada), tipo_transaccion (gasto/ingreso), categoria_id,
  tarjeta_id (nullable — puede no haberse podido asociar), banco_id,
  email_id_origen (para deduplicación), hash_dedupe
- **categorias** — nombre, tipo (gasto/ingreso), color, icono
- **reglas_categorizacion** — palabra_clave_comercio, categoria_id (aprendizaje
  simple: cuando el usuario recategoriza, se actualiza/crea la regla)
- **presupuestos** — categoria_id (nullable = presupuesto total), monto_limite,
  periodo (mensual), fecha_inicio

**Deduplicación:** clave = hash de (monto + fecha + comercio + banco_id) —
antes de insertar una transacción nueva, verificar que ese hash no exista ya.

---

## 7. Parsers de correos bancarios (patrón Adapter)

- Interfaz `BankEmailParser` con método `parse(RawEmail) → Transaccion?`.
- Una implementación por banco: `BanreservasParser`, `BhdParser`, `PopularParser`
  — los 3 bancos soportados hasta ahora, cada uno con al menos un correo real
  confirmado.
- Un mismo banco puede necesitar varias plantillas internas (ej. `BhdParser`
  reconoce tanto consumo con tarjeta como transferencia/pago a un beneficiario)
  — cada plantilla se valida por separado dentro del parser y cualquier valor
  no confirmado devuelve `null` en vez de adivinar.
- Cada parser debe tener sus propios tests unitarios con fixtures de HTML/texto
  de correos reales (anonimizados) — sin esto, un cambio de plantilla del banco
  rompe el parser en producción sin aviso.
- Solo procesar correos de remitentes en la tabla `bancos_conectados` — cualquier
  otro correo se ignora sin abrir ni almacenar su contenido.
- Reconocer tanto correos de gasto (compra/consumo) como de ingreso
  (depósito/transferencia recibida) — son plantillas distintas dentro del mismo
  banco.
- Un parser puede sugerir una categoría (`Transaccion.categoriaSugerida`) cuando
  el "comercio" no sirve como palabra clave reutilizable (ej. el beneficiario de
  una transferencia, que varía en cada correo) — ver sección 8.

---

## 8. Categorización

- Basada en reglas (keyword matching contra `reglas_categorizacion`), NO machine
  learning ni llamadas a ningún LLM externo con el contenido de los correos —
  esto rompería la promesa de privacidad del producto.
- Categorías base: Compras, Alimentos, Finanzas, Servicios, Transporte,
  Suscripciones, Otro (+ categorías de ingreso: Nómina, Transferencia, Otro ingreso).
- Orden de prioridad al categorizar: 1) una regla aprendida que calce (el
  usuario ya recategorizó ese comercio a mano — siempre gana), 2) la
  `categoriaSugerida` que trajo el parser si la hay (ver sección 7), 3) "Otro"
  / "Otro ingreso" según el tipo.
- Si no hay match, cae en "Otro" y el usuario puede recategorizar — esa
  corrección debe crear o actualizar una regla automáticamente.

---

## 9. Pantallas principales del MVP

1. **Onboarding** (carrusel privacidad + 3 pasos) — ver sección 5.
2. **Resumen mensual (home):** ingresos, gastos, balance neto, tendencia vs. mes
   anterior, desglose por moneda (DOP/USD) + consolidado usando tasa de cambio
   configurable, gráfica de tendencia de 6 meses.
3. **Vista de tarjetas:** carrusel de tarjetas con consumo del período, barra de
   progreso si es crédito, total consolidado siempre visible.
4. **Lista de transacciones:** filtrable por fecha, categoría, tarjeta.
5. **Presupuestos:** por categoría, con alertas en 80%/100%.
6. **Ajustes:** tema claro/oscuro, tasa de cambio manual, bancos conectados,
   gestión de tarjetas.

---

## 10. Plan de trabajo por fases (para Claude Code)

Seguir este orden. Al completar cada fase, detente y espera confirmación antes
de continuar a la siguiente — no avanzar automáticamente varias fases sin revisión.

- **Fase 1 — Fundaciones:** estructura de carpetas feature-first, tema claro/oscuro
  con la paleta definida, tipografía, `.dart_defines.json` de ejemplo, icono
  adaptativo desde `assets/images/`.
- **Fase 2 — Autenticación local + onboarding:** registro/login offline con hash
  SHA-256, carrusel de privacidad, wizard de 3 pasos (sin conexión Gmail real
  todavía — usar mocks).
- **Fase 3 — Esquema de base de datos:** todas las tablas de la sección 6,
  cifrado con sqlcipher, migraciones iniciales.
- **Fase 4 — Integración Gmail real:** OAuth con `google_sign_in` + `googleapis`,
  scope readonly, storage seguro de tokens, selección de bancos.
- **Fase 5 — Parsers de los bancos disponibles:** con tests unitarios y
  fixtures reales (Banreservas, BHD, Popular hasta ahora).
- **Fase 6 — Motor de categorización:** reglas + aprendizaje simple por
  recategorización manual.
- **Fase 7 — Pantallas principales:** resumen mensual, lista de transacciones,
  vista de tarjetas.
- **Fase 8 — Presupuestos y alertas:** notificaciones locales en 80%/100%.
- **Fase 9 — Pulido UX:** animaciones, skeleton loaders, accesibilidad, ajustes.
- **Fase 10 — Preparación de lanzamiento:** verificación OAuth de Google
  (requerida para `gmail.readonly` en producción), política de privacidad
  alineada al carrusel de la sección 5, capturas de tienda.

---

## 11. Paquetes recomendados (pubspec)

```yaml
riverpod: ^latest
riverpod_generator: ^latest
sqflite_sqlcipher: ^latest
flutter_secure_storage: ^latest
google_sign_in: ^latest
googleapis: ^latest
fl_chart: ^latest
flutter_local_notifications: ^latest
google_fonts: ^latest
```

(Fijar versiones exactas al momento de implementar, no usar `latest` literal en
el pubspec real.)
