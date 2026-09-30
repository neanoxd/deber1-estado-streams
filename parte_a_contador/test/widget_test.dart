import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parte_a_contador/domain/repositories/contador_repository.dart';
import 'package:parte_a_contador/main.dart';
import 'package:parte_a_contador/presentation/estado/contador_provider.dart';

class FakeContadorRepository implements ContadorRepository {
  int valor = 0;
  @override
  Future<int> leer() async => valor;
  @override
  Future<void> guardar(int v) async => valor = v;
}

void main() {
  testWidgets('Smoke test contador Riverpod', (WidgetTester tester) async {
    final repo = FakeContadorRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contadorRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Contador: 0'), findsOneWidget);
  });
}
