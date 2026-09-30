import 'package:flutter/material.dart';
import 'data/repositories/conexion_plus_repository.dart';
import 'domain/usecases/consultar_conexion.dart';
import 'domain/usecases/observar_conexion.dart';
import 'presentation/pantallas/pantalla_foto.dart';
import 'presentation/pantallas/pantalla_stream.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final repositorio = ConexionPlusRepository();
  final consultarConexion = ConsultarConexion(repositorio);
  final observarConexion = ObservarConexion(repositorio);

  runApp(
    MiApp(
      consultarConexion: consultarConexion,
      observarConexion: observarConexion,
    ),
  );
}

class MiApp extends StatefulWidget {
  final ConsultarConexion consultarConexion;
  final ObservarConexion observarConexion;

  const MiApp({
    super.key,
    required this.consultarConexion,
    required this.observarConexion,
  });

  @override
  State<MiApp> createState() => _MiAppState();
}

class _MiAppState extends State<MiApp> {
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    final paginas = [
      PantallaFoto(consultarConexion: widget.consultarConexion),
      PantallaStream(
        consultarConexion: widget.consultarConexion,
        observarConexion: widget.observarConexion,
      ),
    ];

    return MaterialApp(
      title: 'Detector de Conexión (Future vs Stream)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            _indiceActual == 0
                ? 'Conexión con Future (Foto)'
                : 'Conexión con Stream (Película)',
          ),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: _indiceActual,
          children: paginas,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _indiceActual,
          onTap: (index) {
            setState(() {
              _indiceActual = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Con Future',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stream),
              label: 'Con Stream',
            ),
          ],
        ),
      ),
    );
  }
}
