import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';
import '../../domain/usecases/observar_conexion.dart';
import '../estado/conexion_cubit.dart';

class PantallaStream extends StatefulWidget {
  final ConsultarConexion consultarConexion;
  final ObservarConexion observarConexion;

  const PantallaStream({
    super.key,
    required this.consultarConexion,
    required this.observarConexion,
  });

  @override
  State<PantallaStream> createState() => _PantallaStreamState();
}

class _PantallaStreamState extends State<PantallaStream> {
  int _cambiosCount = 0;

  String _textoEstado(EstadoConexion estado) {
    switch (estado) {
      case EstadoConexion.wifi:
        return 'Wi-Fi';
      case EstadoConexion.datosMoviles:
        return 'Datos móviles';
      case EstadoConexion.sinConexion:
        return 'Sin conexión';
      case EstadoConexion.otro:
        return 'Consultando...';
    }
  }

  IconData _iconoEstado(EstadoConexion estado) {
    switch (estado) {
      case EstadoConexion.wifi:
        return Icons.wifi;
      case EstadoConexion.datosMoviles:
        return Icons.signal_cellular_alt;
      case EstadoConexion.sinConexion:
        return Icons.signal_wifi_off;
      case EstadoConexion.otro:
        return Icons.hourglass_top;
    }
  }

  Color _colorEstado(EstadoConexion estado) {
    switch (estado) {
      case EstadoConexion.wifi:
      case EstadoConexion.datosMoviles:
        return Colors.green;
      case EstadoConexion.sinConexion:
        return Colors.red;
      case EstadoConexion.otro:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConexionCubit(
        consultarConexion: widget.consultarConexion,
        observarConexion: widget.observarConexion,
      )..iniciar(),
      child: BlocConsumer<ConexionCubit, EstadoConexion>(
        listenWhen: (anterior, actual) => anterior != actual,
        listener: (context, state) {
          setState(() {
            _cambiosCount++;
          });
        },
        builder: (context, estado) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Detección Reactiva en Vivo (Stream)',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Icon(
                    _iconoEstado(estado),
                    size: 90,
                    color: _colorEstado(estado),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _textoEstado(estado),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _colorEstado(estado),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Cambios recibidos: $_cambiosCount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Apaga o enciende el Wi-Fi / modo avión.\nLa pantalla reacciona automáticamente sin pulsar botones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
