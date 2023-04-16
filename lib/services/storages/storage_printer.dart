import 'package:flutter_post_printer_example/libraries/app_data.dart' as AppData;
import 'package:shared_preferences/shared_preferences.dart';

class StoragePrinter {
  static final StoragePrinter _instance = StoragePrinter.internal();

  factory StoragePrinter() => _instance;

  StoragePrinter.internal();

  Future setPrinter(
      {required String name, required String address, required bool paired, required int paper}) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString(AppData.KEY_NAME, name);
    pref.setString(AppData.KEY_ADDRESS, address);
    pref.setBool(AppData.KEY_PAIRED, paired);
    pref.setInt(AppData.KEY_PAPER, paper);
    return;
  }

  Future delPrinter() async {
    final pref = await SharedPreferences.getInstance();
    pref.remove(AppData.KEY_NAME);
    pref.remove(AppData.KEY_ADDRESS);
    pref.remove(AppData.KEY_PAIRED);
    pref.remove(AppData.KEY_PAPER);
    return;
  }

  Future<String> getName() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(AppData.KEY_NAME) ?? "No hay impresora";
  }

  Future<String> getAddress() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(AppData.KEY_ADDRESS) ?? "";
  }

  Future<bool> getPaired() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(AppData.KEY_PAIRED) ?? false;
  }

  Future<int> getPaper() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getInt(AppData.KEY_PAPER) ?? 0;
  }
}
