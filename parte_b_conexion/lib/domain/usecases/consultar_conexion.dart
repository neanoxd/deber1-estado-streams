import '../entities/estado_conexion.dart';
import '../repositories/conexion_repository.dart';

class ConsultarConexion {
  final ConexionRepository repository;

  const ConsultarConexion(this.repository);

  Future<EstadoConexion> call() => repository.consultarAhora();
}
