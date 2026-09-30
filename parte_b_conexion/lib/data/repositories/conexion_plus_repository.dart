import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/estado_conexion.dart';
import '../../domain/repositories/conexion_repository.dart';

class ConexionPlusRepository implements ConexionRepository {
  final Connectivity _connectivity;

  ConexionPlusRepository({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  EstadoConexion _mapearResultados(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      return EstadoConexion.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return EstadoConexion.datosMoviles;
    }
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return EstadoConexion.sinConexion;
    }
    return EstadoConexion.otro;
  }

  @override
  Future<EstadoConexion> consultarAhora() async {
    final results = await _connectivity.checkConnectivity();
    return _mapearResultados(results);
  }

  @override
  Stream<EstadoConexion> observarCambios() {
    return _connectivity.onConnectivityChanged.map(_mapearResultados);
  }
}
