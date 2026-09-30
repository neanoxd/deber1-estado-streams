import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:parte_b_conexion/domain/entities/estado_conexion.dart';
import 'package:parte_b_conexion/domain/repositories/conexion_repository.dart';
import 'package:parte_b_conexion/domain/usecases/consultar_conexion.dart';
import 'package:parte_b_conexion/domain/usecases/observar_conexion.dart';
import 'package:parte_b_conexion/main.dart';

class FakeConexionRepository implements ConexionRepository {
  EstadoConexion estado = EstadoConexion.wifi;
  final StreamController<EstadoConexion> _controller =
      StreamController<EstadoConexion>.broadcast();

  @override
  Future<EstadoConexion> consultarAhora() async => estado;

  @override
  Stream<EstadoConexion> observarCambios() => _controller.stream;
}

void main() {
  testWidgets('Smoke test parte_b_conexion', (WidgetTester tester) async {
    final repo = FakeConexionRepository();
    final consultar = ConsultarConexion(repo);
    final observar = ObservarConexion(repo);

    await tester.pumpWidget(
      MiApp(
        consultarConexion: consultar,
        observarConexion: observar,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Consulta Instantánea (Future)'), findsOneWidget);
  });
}
