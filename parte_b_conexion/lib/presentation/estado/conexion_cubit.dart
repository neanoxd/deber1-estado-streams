import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';
import '../../domain/usecases/observar_conexion.dart';

class ConexionCubit extends Cubit<EstadoConexion> {
  final ConsultarConexion consultarConexion;
  final ObservarConexion observarConexion;

  StreamSubscription<EstadoConexion>? _subscription;

  ConexionCubit({
    required this.consultarConexion,
    required this.observarConexion,
  }) : super(EstadoConexion.otro);

  Future<void> iniciar() async {
    final inicial = await consultarConexion();
    emit(inicial);

    await _subscription?.cancel();
    _subscription = observarConexion().listen((nuevoEstado) {
      emit(nuevoEstado);
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
