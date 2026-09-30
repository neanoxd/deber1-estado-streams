import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/contador_repository.dart';

class ContadorPrefsRepository implements ContadorRepository {
  static const String _key = 'contador';

  @override
  Future<int> leer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  @override
  Future<void> guardar(int valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, valor);
  }
}
