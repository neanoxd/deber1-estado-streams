import '../repositories/contador_repository.dart';

class Incrementar {
  final ContadorRepository repository;

  const Incrementar(this.repository);

  Future<int> call() async {
    final actual = await repository.leer();
    final nuevo = actual + 1;
    await repository.guardar(nuevo);
    return nuevo;
  }
}
