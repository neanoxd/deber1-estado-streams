import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parte_a_contador/domain/repositories/contador_repository.dart';
import 'package:parte_a_contador/domain/usecases/decrementar.dart';
import 'package:parte_a_contador/domain/usecases/incrementar.dart';
import 'package:parte_a_contador/domain/usecases/obtener_contador.dart';
import 'package:parte_a_contador/main.dart';
import 'package:parte_a_contador/presentation/estado/contador_cubit.dart';

class FakeContadorRepository implements ContadorRepository {
  int valor = 0;
  @override
  Future<int> leer() async => valor;
  @override
  Future<void> guardar(int v) async => valor = v;
}

void main() {
  testWidgets('Smoke test contador BLoC', (WidgetTester tester) async {
    final repo = FakeContadorRepository();
    final cubit = ContadorCubit(
      obtenerContador: ObtenerContador(repo),
      incrementarUsecase: Incrementar(repo),
      decrementarUsecase: Decrementar(repo),
    )..cargar();

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Contador: 0'), findsOneWidget);
  });
}
