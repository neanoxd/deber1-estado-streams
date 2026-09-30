# Deber 1 — Manejo de Estado y Uso de Streams en Flutter
**Programación Asistida de Aplicaciones — USFQ**  
**Estudiante:** Leandro Crespo (`neanoxd`)  
**Repositorio:** [deber1-estado-streams](https://github.com/neanoxd/deber1-estado-streams.git)

---

## PARTE A · La misma app, tres veces

### Pregunta 1
> **¿Qué pasó en el paso 3 y por qué? Ojo: el valor sí se guardó en disco. ¿Qué es exactamente lo que quedó desactualizado? Y para que el contador viajara entre las dos pantallas, ¿cuántos lugares del código tuvieron que ponerse de acuerdo?**

#### Qué sucedió y por qué
En el paso 3, al ingresar a `PantallaControl`, incrementar el contador (por ejemplo, de 3 a 4) y presionar el **botón atrás del sistema operativo** (gesto o botón de retroceso de Android), la pantalla anterior (`PantallaVisor`) continuó mostrando el valor anterior (3), en lugar de reflejar el valor incrementado (4).

Esto ocurre porque con `setState`:
1. `PantallaVisor` depende de recibir el nuevo valor como resultado de la ruta de navegación mediante `final valorDevuelto = await Navigator.push(...)`.
2. El botón de la interfaz "Volver" realizaba explícitamente `Navigator.pop(context, _contador)`, retornando el número entero modificado.
3. Al utilizar el botón físico o gesto del sistema operativo, el framework ejecuta un pop por defecto sin argumentos (`Navigator.pop(context, null)`), retornando `null`.
4. Al recibir `null`, la condición de actualización en `PantallaVisor` no se cumple y no se ejecuta `setState(() => _contador = valorDevuelto)`.

#### Qué quedó desactualizado
El dato guardado en disco a través de `SharedPreferences` **sí se actualizó correctamente** (el caso de uso `Incrementar` persistió el valor 4 en almacenamiento local). Lo que quedó desactualizado fue única y exclusivamente el **estado efímero local en memoria** del widget `_PantallaVisorState` (`int _contador`). Si la aplicación se reinicia, el valor 4 se lee sin problemas, evidenciando que el fallo fue de sincronización en la capa de presentación.

#### Lugares del código que tuvieron que ponerse de acuerdo
Para lograr que el contador viajara de ida y vuelta entre ambas pantallas con `setState`, al menos **5 lugares distintos del código** tuvieron que coordinarse de forma acoplada y frágil:
1. `PantallaVisor`: Pasar `_contador` en el constructor de `PantallaControl`.
2. `PantallaControl`: Definir el parámetro `final int valorInicial` en su constructor y clase.
3. `_PantallaControlState`: Inicializar su estado interno a partir de `widget.valorInicial`.
4. `PantallaControl` (botón Volver): Invocar específicamente `Navigator.pop(context, _contador)` pasando el estado interno.
5. `PantallaVisor`: Esperar el resultado de tipo `<int>` en el `await Navigator.push<int>(...)` y llamar a `setState` para reasignarlo.

Cualquier vía alternativa de escape de la pantalla (como el botón nativo de atrás) quiebra este acuerdo.

---

### Pregunta 2
> **¿Por qué ahora el botón atrás del sistema no rompe nada? ¿Dónde vive el contador?**

#### Por qué el botón atrás no rompe la sincronización
Con Riverpod, el botón atrás del sistema no rompe la sincronización porque la comunicación entre pantallas ya no depende de pasar datos por constructor ni de capturar valores devueltos en `Navigator.pop()`. La navegación se reduce a un simple `push` y `pop` sin parámetros ni retornos.

Cuando el usuario pulsa `+1` en `PantallaControl`, se invoca `ref.read(contadorProvider.notifier).incrementar()`. Esta llamada modifica directamente el estado del provider global fuera de la jerarquía visual. Debido a que `PantallaVisor` está suscrita reactivamente al mismo provider con `ref.watch(contadorProvider)`, su método `build` se redibuja automáticamente en el mismo instante en que el provider notifica la mutación. Sin importar si el usuario vuelve pulsando el botón de la app, el botón atrás del sistema o una notificación, el visor ya tiene el estado actualizado en memoria.

#### Dónde vive el contador
El contador vive **fuera del árbol de widgets**, dentro del `ProviderContainer` administrado por `ProviderScope` en el objeto `ContadorNotifier` (`contadorProvider`). Ya no pertenece al ciclo de vida ni a la memoria local de ninguna pantalla individual.

---

### Pregunta 3
> **¿Qué te permite ver el `BlocObserver` que las otras dos versiones no te daban? ¿En qué situación real sería útil ese registro?**

#### Qué permite ver el `BlocObserver`
El `BlocObserver` provee un mecanismo unificado y centralizado de **observabilidad e interceptación de transiciones de estado**. Al implementar `onChange(bloc, change)`, nos permite registrar en la consola:
- La instancia y tipo de Cubit o BLoC que experimentó la mutación (`bloc.runtimeType`).
- El estado exacto anterior (`change.currentState`).
- El estado exacto posterior (`change.nextState`).

En `setState` y Riverpod básico, los cambios de estado ocurren de manera descentralizada y mutacional dentro de cada widget o notifier sin una bitácora automática de transiciones. `BlocObserver` garantiza que **ningún cambio de estado pase desapercibido**.

#### Situaciones reales donde es indispensable
1. **Depuración de errores intermitentes y carreras de estado (Race Conditions):** Cuando ocurre un comportamiento anómalo en flujos complejos (por ejemplo, pantallas de checkout o autenticación con múltiples llamadas asíncronas), el log de `BlocObserver` permite reconstruir cronológicamente cada cambio de estado previo a la falla.
2. **Telemetría, Crash Reporting y Auditoría en Producción:** Permite conectar observadores a plataformas como Sentry, Datadog o Firebase Crashlytics. Cuando ocurre un error no capturado, se envía la lista de los últimos 20 estados por los que pasó la aplicación (breadcrumbs), permitiendo al equipo de ingeniería reproducir el bug con exactitud matemática.

---

### Pregunta 4
> **Pega la salida de los tres comandos en `RESPUESTAS.md`. ¿Qué demuestra que los dos primeros salgan vacíos y el tercero no? Si mañana tuvieras que cambiar Riverpod por otro paquete, ¿qué parte del proyecto tendrías que volver a escribir?**

#### Salida de los tres comandos

```bash
$ git diff version/setstate version/riverpod -- lib/domain lib/data
```
**Salida:**
*(Vacío — 0 líneas)*

```bash
$ git diff version/setstate version/bloc -- lib/domain lib/data
```
**Salida:**
*(Vacío — 0 líneas)*

```bash
$ git diff version/setstate version/bloc --stat -- lib/presentation
```
**Salida:**
```text
 .../lib/presentation/estado/contador_cubit.dart    |  31 +++++
 .../presentation/pantallas/pantalla_control.dart   |  85 ++++----------
 .../lib/presentation/pantallas/pantalla_visor.dart | 128 +++++++--------------
 3 files changed, 95 insertions(+), 149 deletions(-)
```

#### Qué demuestra esta salida
Demuestra empíricamente el valor del **Principio de Inversión de Dependencias y la Arquitectura Limpia**:
- Las capas `domain` (reglas del negocio, contratos abstractos y casos de uso) y `data` (implementación de persistencia con `SharedPreferences`) son **completamente estables, desacopladas e inmunes a los cambios de interfaz**.
- Que los dos primeros comandos salgan completamente vacíos certifica que cambiamos el gestor de estado tres veces (`setState` -> `Riverpod` -> `BLoC / Cubit`) sin tocar una sola línea de lógica o datos.
- Que el tercer comando muestre cambios extensos demuestra con claridad que **el administrador de estado es únicamente un detalle de implementación de la capa `presentation`**.

#### Qué parte del proyecto tendrías que volver a escribir al cambiar de paquete
Si mañana se reemplazara Riverpod por otro paquete (como Signals o MobX), **únicamente se tendría que reescribir la capa `presentation/` (y la inyección inicial en `main.dart`)**. Las entidades, casos de uso (`ObtenerContador`, `Incrementar`, `Decrementar`) y los repositorios (`ContadorRepository`, `ContadorPrefsRepository`) permanecerían al 100% intactos y funcionales.

---

### Pregunta 5
> **Completa la tabla comparativa con lo que observaste. Si la app tuviera una sola pantalla, ¿cuál de las tres elegirías y por qué? ¿Y si tuviera ocho pantallas que comparten cinco datos distintos? Cierra tu respuesta diciendo en dos líneas cuándo sí es la opción correcta.**

#### Tabla Comparativa de la Parte A

| Característica | `setState` | `Riverpod` | `Cubit` (BLoC) |
|---|---|---|---|
| **¿Dónde vive el contador?** | En el objeto `State` local de cada pantalla (`_PantallaVisorState`, `_PantallaControlState`) | Fuera del árbol de widgets, en el `ContadorNotifier` dentro del `ProviderContainer` | Fuera del árbol de widgets, en el `ContadorCubit` inyectado mediante `BlocProvider` |
| **¿Las pantallas se pasan datos?** | **Sí**: por constructor en la navegación y como valor de retorno en `Navigator.pop` | **No**: leen y mutan el provider global de forma autónoma | **No**: interactúan directamente con el Cubit mediante `context.read` y `BlocBuilder` |
| **Archivos de `presentation/` que tocaste** | `pantalla_visor.dart`, `pantalla_control.dart` | `estado/contador_provider.dart`, `pantalla_visor.dart`, `pantalla_control.dart` | `estado/contador_cubit.dart`, `pantalla_visor.dart`, `pantalla_control.dart` |
| **¿Qué pasa con el botón atrás?** | **Falla**: el visor queda desactualizado porque el sistema Android devuelve `null` | **Funciona**: el visor ya está sincronizado sin importar la vía de regreso | **Funciona**: el visor refleja el estado inmutable emitido inmediatamente |
| **¿Tuviste que tocar `domain/`?** | **No** (0 líneas modificadas) | **No** (0 líneas modificadas) | **No** (0 líneas modificadas) |

#### Si la app tuviera una sola pantalla
Elegiría **`setState`**. Si la pantalla no comparte datos con ninguna otra parte de la aplicación y la interacción empieza y termina dentro de su propio árbol, `setState` es directo, ligero, no requiere dependencias externas ni agrega capas de abstracción innecesarias.

#### Si tuviera ocho pantallas que comparten cinco datos distintos
Elegiría **`Cubit` (BLoC)**. Manejar cinco datos compartidos entre ocho pantallas con `setState` requeriría un cableado caótico de constructores (prop drilling) y retornos de navegación propensos a desincronizaciones masivas. `Cubit` proporciona estados inmutables, reactividad predecible, separación clara de responsabilidades y trazabilidad completa mediante `BlocObserver`.

#### Cuándo `setState` SÍ es la opción correcta
`setState` es la opción ideal para **estado efímero y exclusivo de un widget puntual**: controlar una animación local, abrir o cerrar un menú desplegable, manejar el foco de un campo de texto o validar un formulario local antes de enviarlo.

---
---

## PARTE B · Future vs Stream, con algo que cambia de verdad

### Pregunta 6
> **¿Por qué la pantalla siguió mostrando "Wi-Fi" si el Wi-Fi ya estaba apagado? ¿La app tenía un dato incorrecto, o tenía un dato correcto de un momento equivocado?**

#### Por qué siguió mostrando "Wi-Fi"
Un `Future` representa una operación asíncrona que entrega **un único valor en un instante de tiempo cerrado** y luego finaliza su ciclo de vida. Al presionar "Consultar ahora", el `Future` tomó una "foto" del estado de la red en ese instante exacto, actualizó el `_estado` local del widget y culminó. Cuando el usuario apagó el Wi-Fi, el sistema operativo experimentó el cambio, pero el widget no contaba con ningún mecanismo para escuchar ese evento externo. Por ello, la pantalla retuvo la última fotografía que había tomado.

#### ¿Dato incorrecto o dato correcto de un momento equivocado?
La app tenía **un dato correcto de un momento equivocado**. En el segundo preciso en que se ejecutó la consulta (indicado en la hora `HH:mm:ss`), el dispositivo efectivamente tenía conexión Wi-Fi. El problema no fue de exactitud en el dato, sino de **vigencia temporal**: la realidad de la red continuó cambiando, pero la pantalla permaneció congelada en el pasado.

---

### Pregunta 7
> **¿Qué pasaría si borras el `cancel()` del `close()` del Cubit y el usuario entra y sale de esa pantalla cincuenta veces?**

Si se elimina `await _subscription?.cancel()` del método `close()` en `ConexionCubit`, ocurriría una catástrofe de gestión de recursos:

1. **Fuga de memoria severa (Memory Leak):** Cada vez que el usuario ingresa a la pantalla se crea una nueva instancia de `ConexionCubit` y se abre un nuevo `StreamSubscription` escuchando a `Connectivity().onConnectivityChanged`. Al salir, el widget desaparece pero la suscripción sigue viva en memoria, impidiendo que el Garbage Collector libere el Cubit. Si el usuario entra y sale 50 veces, existirán **50 suscripciones zombi y 50 instancias de Cubit** retenidas indefinidamente en la memoria RAM.
2. **Consumo excesivo de batería y procesador:** Cada vez que la conectividad del dispositivo varíe, el sistema operativo notificará a las 50 suscripciones activas, ejecutando 50 callbacks simultáneos para objetos obsoletos.
3. **Excepción no controlada en tiempo de ejecución:** Cuando el listener zombi intente ejecutar `emit(nuevoEstado)` sobre un Cubit que ya fue cerrado por la UI (`isClosed == true`), Flutter BLoC lanzará un fallo crítico:
   ```text
   Bad state: Cannot emit new states after calling close
   ```

---

### Pregunta 8
> **Con lo que viste: ¿por qué decimos que un `Future` es una foto y un `Stream` una película? Explícalo con la conexión, no con la definición del libro. Cierra nombrando dos datos de una app real que pedirías con `Future` y dos que observarías con `Stream`.**

#### Explicación con la conexión (Foto vs Película)
- **`Future` es una foto:** Cuando estás en la pestaña de `Future` y pulsas "Consultar ahora", la app captura un fotograma estático de la red con una marca de tiempo: *"son las 15:30:10 y hay Wi-Fi"*. Si apagas el Wi-Fi a las 15:30:12, la foto pegada en la pantalla sigue mostrando Wi-Fi. La foto no se entera de que el entorno cambió; para ver la nueva realidad tienes que intervenir y presionar el disparador otra vez.
- **`Stream` es una película:** En la pestaña con `Stream`, no hay un disparador manual. La app tiene la cámara grabando en vivo. En el milisegundo exacto en que cortas la señal Wi-Fi, el flujo emite un nuevo fotograma ("Sin conexión"), el Cubit lo recibe y la pantalla cambia por sí sola frente a tus ojos. La iniciativa se invierte: ya no le preguntas a la pantalla qué hay; la pantalla te avisa cuando algo cambia.

#### Datos de una app real con `Future` (se piden una sola vez)
1. **Autenticación / Login de usuario:** Enviar credenciales (correo y contraseña) al endpoint de la API y esperar una única respuesta de éxito con el token JWT o un error de validación.
2. **Procesamiento de una compra o pago con tarjeta:** Enviar la transacción a la pasarela de pagos (e.g. Stripe) y recibir un resultado final único (aprobado o rechazado).

#### Datos de una app real con `Stream` (flujos continuos en el tiempo)
1. **Rastreo GPS en vivo de una orden de delivery o transporte (e.g. Uber / Rappi):** La latitud y longitud del repartidor se emiten continuamente conforme el vehículo se desplaza por las calles.
2. **Chat en tiempo real / Mensajería instantánea:** Los mensajes entrantes deben pintarse en la conversación en el instante exacto en que ingresan por el WebSocket o Firebase, sin recargar la pantalla.

---
## Resumen de Verificaciones de Arquitectura y Comandos

1. **Ramas creadas en Git:**
   - `main`: Núcleo base compartido (`domain/` y `data/`), `parte_b_conexion`, `demo.mp4` y `RESPUESTAS.md`.
   - `version/setstate`: Implementación de presentación con `setState`.
   - `version/riverpod`: Implementación de presentación con Riverpod (`flutter_riverpod`).
   - `version/bloc`: Implementación de presentación con BLoC / Cubit (`flutter_bloc`).

2. **Aislamiento de Imports en Parte B:**
   ```bash
   $ git grep -l "connectivity" lib/
   lib/data/repositories/conexion_plus_repository.dart
   ```
   *Solo aparece un único archivo en todo el proyecto.*
