import 'package:flutter/material.dart';
import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';

class PantallaFoto extends StatefulWidget {
  final ConsultarConexion consultarConexion;

  const PantallaFoto({
    super.key,
    required this.consultarConexion,
  });

  @override
  State<PantallaFoto> createState() => _PantallaFotoState();
}

class _PantallaFotoState extends State<PantallaFoto> {
  EstadoConexion? _estado;
  DateTime? _horaConsulta;
  bool _cargando = false;

  Future<void> _consultar() async {
    setState(() => _cargando = true);
    final resultado = await widget.consultarConexion();
    if (mounted) {
      setState(() {
        _estado = resultado;
        _horaConsulta = DateTime.now();
        _cargando = false;
      });
    }
  }

  String _formatearHora(DateTime fecha) {
    final h = fecha.hour.toString().padLeft(2, '0');
    final m = fecha.minute.toString().padLeft(2, '0');
    final s = fecha.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _textoEstado(EstadoConexion estado) {
    switch (estado) {
      case EstadoConexion.wifi:
        return 'Wi-Fi';
      case EstadoConexion.datosMoviles:
        return 'Datos móviles';
      case EstadoConexion.sinConexion:
        return 'Sin conexión';
      case EstadoConexion.otro:
        return 'Otra conexión';
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
        return Icons.devices_other;
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Consulta Instantánea (Future)',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            if (_cargando)
              const CircularProgressIndicator()
            else if (_estado != null) ...[
              Icon(
                _iconoEstado(_estado!),
                size: 80,
                color: _colorEstado(_estado!),
              ),
              const SizedBox(height: 16),
              Text(
                _textoEstado(_estado!),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: _colorEstado(_estado!),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hora de consulta: ${_formatearHora(_horaConsulta!)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ] else ...[
              const Icon(Icons.info_outline, size: 70, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Presiona "Consultar ahora" para tomar la foto del estado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _cargando ? null : _consultar,
              icon: const Icon(Icons.refresh),
              label: const Text('Consultar ahora'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
