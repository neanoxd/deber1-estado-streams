import 'package:flutter/material.dart';
import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';

class PantallaControl extends StatefulWidget {
  final int valorInicial;
  final Incrementar incrementar;
  final Decrementar decrementar;

  const PantallaControl({
    super.key,
    required this.valorInicial,
    required this.incrementar,
    required this.decrementar,
  });

  @override
  State<PantallaControl> createState() => _PantallaControlState();
}

class _PantallaControlState extends State<PantallaControl> {
  late int _contador;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _contador = widget.valorInicial;
  }

  Future<void> _ejecutarIncremento() async {
    setState(() => _procesando = true);
    final nuevo = await widget.incrementar();
    if (mounted) {
      setState(() {
        _contador = nuevo;
        _procesando = false;
      });
    }
  }

  Future<void> _ejecutarDecremento() async {
    setState(() => _procesando = true);
    final nuevo = await widget.decrementar();
    if (mounted) {
      setState(() {
        _contador = nuevo;
        _procesando = false;
      });
    }
  }

  void _volver() {
    Navigator.pop(context, _contador);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control (setState)'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pantalla 2 · Control',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              '$_contador',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _procesando ? null : _ejecutarDecremento,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('-1', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: _procesando ? null : _ejecutarIncremento,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('+1', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: _volver,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
