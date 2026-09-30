import 'package:flutter_test/flutter_test.dart';
import 'package:parte_a_contador/domain/repositories/contador_repository.dart';
import 'package:parte_a_contador/domain/usecases/decrementar.dart';
import 'package:parte_a_contador/domain/usecases/incrementar.dart';
import 'package:parte_a_contador/domain/usecases/obtener_contador.dart';
import 'package:parte_a_contador/main.dart';

class FakeContadorRepository implements ContadorRepository {
  int valor = 0;
  @override
  Future<int> leer() async => valor;
  @override
  Future<void> guardar(int v) async => valor = v;
}

void main() {
  testWidgets('Smoke test contador setState', (WidgetTester tester) async {
    final repo = FakeContadorRepository();
    final obtener = ObtenerContador(repo);
    final inc = Incrementar(repo);
    final dec = Decrementar(repo);

    await tester.pumpWidget(
      MiApp(
        obtenerContador: obtener,
        incrementar: inc,
        decrementar: dec,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Contador: 0'), findsOneWidget);
  });
}
