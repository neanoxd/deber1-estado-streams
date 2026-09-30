import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';
import '../../domain/usecases/obtener_contador.dart';

class ContadorCubit extends Cubit<int> {
  final ObtenerContador obtenerContador;
  final Incrementar incrementarUsecase;
  final Decrementar decrementarUsecase;

  ContadorCubit({
    required this.obtenerContador,
    required this.incrementarUsecase,
    required this.decrementarUsecase,
  }) : super(0);

  Future<void> cargar() async {
    final valor = await obtenerContador();
    emit(valor);
  }

  Future<void> incrementar() async {
    final nuevo = await incrementarUsecase();
    emit(nuevo);
  }

  Future<void> decrementar() async {
    final nuevo = await decrementarUsecase();
    emit(nuevo);
  }
}
