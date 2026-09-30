import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/contador_repository.dart';
import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';
import '../../domain/usecases/obtener_contador.dart';

/// Provider base para el repositorio. Es sobreescrito en main.dart
/// manteniendo presentation completamente libre de referencias a la capa data.
final contadorRepositoryProvider = Provider<ContadorRepository>((ref) {
  throw UnimplementedError('El repositorio debe proveerse en main.dart');
});

/// Providers para los casos de uso
final obtenerContadorProvider = Provider<ObtenerContador>((ref) {
  final repo = ref.watch(contadorRepositoryProvider);
  return ObtenerContador(repo);
});

final incrementarProvider = Provider<Incrementar>((ref) {
  final repo = ref.watch(contadorRepositoryProvider);
  return Incrementar(repo);
});

final decrementarProvider = Provider<Decrementar>((ref) {
  final repo = ref.watch(contadorRepositoryProvider);
  return Decrementar(repo);
});

/// Notifier (API actual de Riverpod) que administra el estado del contador
/// llamando SIEMPRE a los casos de uso del domain.
class ContadorNotifier extends Notifier<int> {
  @override
  int build() {
    cargar();
    return 0;
  }

  Future<void> cargar() async {
    final caso = ref.read(obtenerContadorProvider);
    state = await caso();
  }

  Future<void> incrementar() async {
    final caso = ref.read(incrementarProvider);
    state = await caso();
  }

  Future<void> decrementar() async {
    final caso = ref.read(decrementarProvider);
    state = await caso();
  }
}

final contadorProvider = NotifierProvider<ContadorNotifier, int>(
  ContadorNotifier.new,
);
