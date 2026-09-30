import '../repositories/contador_repository.dart';

class Decrementar {
  final ContadorRepository repository;

  const Decrementar(this.repository);

  Future<int> call() async {
    final actual = await repository.leer();
    final nuevo = actual - 1;
    await repository.guardar(nuevo);
    return nuevo;
  }
}
