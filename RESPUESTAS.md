Deber 1 — Manejo de estado y uso de streams en Flutter

Estudiante: Leandro Crespo
Repositorio: https://github.com/neanoxd/deber1-estado-streams.git

PARTE A · La misma app, tres veces


Pregunta 1
¿Qué pasó en el paso 3 y por qué? Ojo: el valor sí se guardó en disco. ¿Qué es exactamente lo que quedó desactualizado? Y para que el contador viajara entre las dos pantallas, ¿cuántos lugares del código tuvieron que ponerse de acuerdo?

Respuesta:
Al salir de la pantalla de Control usando el botón atrás del sistema (Android), el visor siguió mostrando el valor viejo (3) en lugar del nuevo (4). Esto pasó porque el botón atrás del sistema hace pop devolviendo null, por lo que la condición en el visor nunca recibió el nuevo valor y no ejecutó setState.
El dato en disco sí se guardó correctamente en SharedPreferences; lo que quedó desactualizado fue únicamente la variable en memoria de la pantalla visor (_contador).
Para que el dato viajara entre pantallas tuvieron que coordinarse 5 lugares: el constructor de PantallaControl, el paso del valor desde PantallaVisor al hacer push, la inicialización del State en PantallaControl, el Navigator.pop(context, _contador) del botón Volver, y el await Navigator.push con su setState en PantallaVisor.


Pregunta 2
¿Por qué ahora el botón atrás del sistema no rompe nada? ¿Dónde vive el contador?

Respuesta:
No se rompe porque las pantallas ya no se pasan datos entre sí ni esperan ningún resultado al volver. El contador vive fuera del árbol de widgets, en el provider de Riverpod (ContadorNotifier). Al presionar +1 en Control se modifica el provider directamente; como el Visor está escuchando ese mismo provider con ref.watch, se actualiza automáticamente sin importar cómo regrese el usuario.


Pregunta 3
¿Qué te permite ver el BlocObserver que las otras dos versiones no te daban? ¿En qué situación real sería útil ese registro?

Respuesta:
Permite ver de forma centralizada cada cambio de estado de la app: qué Cubit cambió, cuál era el estado anterior y cuál es el nuevo (ejemplo: ContadorCubit: 3 -> 4).
En una situación real es útil para depurar bugs difíciles de reproducir o para telemetría y monitoreo de errores (como Sentry o Crashlytics), permitiendo ver el historial exacto de estados que ocurrieron justo antes de que la app fallara.


Pregunta 4
Pega la salida de los tres comandos en RESPUESTAS.md. ¿Qué demuestra que los dos primeros salgan vacíos y el tercero no? Si mañana tuvieras que cambiar Riverpod por otro paquete, ¿qué parte del proyecto tendrías que volver a escribir?

Salida de comandos:

1) git diff version/setstate version/riverpod -- lib/domain lib/data
(Salida vacía)

2) git diff version/setstate version/bloc -- lib/domain lib/data
(Salida vacía)

3) git diff version/setstate version/bloc --stat -- lib/presentation
 .../lib/presentation/estado/contador_cubit.dart    |  31 +++++
 .../presentation/pantallas/pantalla_control.dart   |  85 ++++----------
 .../lib/presentation/pantallas/pantalla_visor.dart | 128 +++++++--------------
 3 files changed, 95 insertions(+), 149 deletions(-)

Respuesta:
Demuestra que la lógica de negocio (domain) y el acceso a datos (data) están completamente desacoplados de la interfaz: cambiamos el administrador de estado tres veces sin tocar una sola línea de domain ni data. Solo cambió presentation.
Si mañana se cambia Riverpod por otro paquete, solo hay que reescribir la capa presentation y la configuración en main.dart. Domain y data quedan exactamente iguales.


Pregunta 5
Tabla comparativa y justificación de elección.

Tabla comparativa:

| Criterio | setState | Riverpod | Cubit |
|---|---|---|---|
| ¿Dónde vive el contador? | En el State local de cada pantalla | En el ContadorNotifier (ProviderScope) | En el ContadorCubit (BlocProvider) |
| ¿Las pantallas se pasan datos? | Sí, por constructor y por pop | No, leen y mutan el provider | No, usan context.read y BlocBuilder |
| Archivos de presentation/ tocados | pantalla_visor.dart, pantalla_control.dart | contador_provider.dart, pantalla_visor.dart, pantalla_control.dart | contador_cubit.dart, pantalla_visor.dart, pantalla_control.dart |
| ¿Qué pasa con el botón atrás? | El visor queda desactualizado | Se mantiene actualizado | Se mantiene actualizado |
| ¿Tuviste que tocar domain/? | No | No | No |

Elección según el caso:
- Con una sola pantalla: Elijo setState, porque es simple, nativo y no mete librerías ni código extra donde no se necesitan.
- Con ocho pantallas y cinco datos compartidos: Elijo Cubit (o Riverpod), porque pasar cinco datos por constructor entre ocho pantallas generaría un desorden inmanejable y errores al navegar.
setState sí es la opción correcta cuando se trata de estado efímero y exclusivo de un widget, como abrir un menú, animar un botón o validar un formulario local.

PARTE B · Future vs Stream

Pregunta 6
¿Por qué la pantalla siguió mostrando "Wi-Fi" si el Wi-Fi ya estaba apagado? ¿La app tenía un dato incorrecto, o tenía un dato correcto de un momento equivocado?

Respuesta:
Siguió mostrando "Wi-Fi" porque un Future solo hace una consulta puntual (una foto) y termina. No escucha eventos futuros, así que al apagar el Wi-Fi la pantalla no tenía forma de enterarse.
La app tenía un dato correcto de un momento equivocado: en el segundo exacto en que se presionó el botón sí había Wi-Fi, pero la red cambió después y la pantalla se quedó congelada con el dato del pasado.


Pregunta 7
¿Qué pasaría si borras el cancel() del close() del Cubit y el usuario entra y sale de esa pantalla cincuenta veces?

Respuesta:
Se generaría una fuga de memoria con 50 suscripciones y 50 Cubits acumulados en RAM que el recolector de basura no puede liberar. Cada cambio de red ejecutaría 50 veces el mismo código consumiendo procesador y batería, y además daría un error en consola porque un Cubit cerrado no puede emitir estados (Cannot emit new states after calling close).


Pregunta 8
¿Por qué decimos que un Future es una foto y un Stream una película? Explícalo con la conexión. Cierra nombrando dos datos con Future y dos con Stream.

Respuesta:
El Future es una foto porque congela el estado de la conexión en un solo instante; si la conexión se cae dos segundos después, la foto sigue mostrando Wi-Fi hasta que alguien pulse el botón otra vez. El Stream es una película porque transmite en vivo: en cuanto se apaga el Wi-Fi, emite un nuevo valor de inmediato y la pantalla cambia sola sin tocar nada.

Dos datos con Future en una app real:
1. Iniciar sesión con usuario y contraseña (se consulta una sola vez).
2. Procesar el cobro de una compra con tarjeta.

Dos datos con Stream en una app real:
1. La ubicación GPS de un conductor en una app de viajes o delivery.
2. Los mensajes nuevos que llegan a un chat en tiempo real.
