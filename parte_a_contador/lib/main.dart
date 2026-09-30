import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/contador_prefs_repository.dart';
import 'domain/usecases/decrementar.dart';
import 'domain/usecases/incrementar.dart';
import 'domain/usecases/obtener_contador.dart';
import 'presentation/estado/contador_cubit.dart';
import 'presentation/pantallas/pantalla_visor.dart';

class ContadorBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType}: ${change.currentState} -> ${change.nextState}');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = ContadorBlocObserver();

  final repositorio = ContadorPrefsRepository();
  final obtenerContador = ObtenerContador(repositorio);
  final incrementar = Incrementar(repositorio);
  final decrementar = Decrementar(repositorio);

  runApp(
    BlocProvider(
      create: (context) => ContadorCubit(
        obtenerContador: obtenerContador,
        incrementarUsecase: incrementar,
        decrementarUsecase: decrementar,
      )..cargar(),
      child: const MiApp(),
    ),
  );
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador Clean Arch (BLoC / Cubit)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PantallaVisor(),
    );
  }
}
