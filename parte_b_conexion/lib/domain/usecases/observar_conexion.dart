import '../entities/estado_conexion.dart';
import '../repositories/conexion_repository.dart';

class ObservarConexion {
  final ConexionRepository repository;

  const ObservarConexion(this.repository);

  Stream<EstadoConexion> call() => repository.observarCambios();
}
