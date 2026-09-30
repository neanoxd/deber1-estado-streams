import 'package:flutter/material.dart';
import 'data/repositories/contador_prefs_repository.dart';
import 'domain/usecases/decrementar.dart';
import 'domain/usecases/incrementar.dart';
import 'domain/usecases/obtener_contador.dart';
import 'presentation/pantallas/pantalla_visor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final repositorio = ContadorPrefsRepository();
  final obtenerContador = ObtenerContador(repositorio);
  final incrementar = Incrementar(repositorio);
  final decrementar = Decrementar(repositorio);

  runApp(
    MiApp(
      obtenerContador: obtenerContador,
      incrementar: incrementar,
      decrementar: decrementar,
    ),
  );
}

class MiApp extends StatelessWidget {
  final ObtenerContador obtenerContador;
  final Incrementar incrementar;
  final Decrementar decrementar;

  const MiApp({
    super.key,
    required this.obtenerContador,
    required this.incrementar,
    required this.decrementar,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador Clean Arch (setState)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: PantallaVisor(
        obtenerContador: obtenerContador,
        incrementar: incrementar,
        decrementar: decrementar,
      ),
    );
  }
}
