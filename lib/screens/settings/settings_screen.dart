import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:flutter_post_printer_example/bloc/settings_bloc.dart';
import 'package:flutter_post_printer_example/screens/settings/settings.dart';
import 'package:flutter_post_printer_example/libraries/app_data.dart' as AppData;

class SettingsPage extends StatelessWidget {
  const SettingsPage();

  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return SettingsBloc()..add(GetPrinterEvent());
      },
      child: const SettingsFrom(),
    );
  }
}

class SettingsFrom extends StatefulWidget {
  const SettingsFrom({Key? key}) : super(key: key);

  @override
  State<SettingsFrom> createState() => _SettingsFromState();
}

class _SettingsFromState extends State<SettingsFrom> {
  final PrinterManager instanceManager = PrinterManager.instance;
  List<PrinterDevice> devices = [];
  PrinterDevice printerDefault = PrinterDevice(name: '', address: '');
  int paperDefault = 0;
  bool isPairedDefault = false;
  PrinterDevice printerSelect = PrinterDevice(name: '', address: '');
  StreamSubscription<PrinterDevice>? _subscriptionScan;
  StreamSubscription<BTStatus>? _subscriptionStatus;
  BTStatus _currentStatus = BTStatus.none;
  bool isPairedSelect = false;

  List<int>? pendingTask;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    scan();
    status();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _subscriptionScan!.cancel();
    _subscriptionStatus!.cancel();
    super.dispose();
  }

  scan() {
    devices.clear();
    _subscriptionScan =
        instanceManager.discovery(type: PrinterType.bluetooth, isBle: isPairedSelect).listen((device) {
      setState(() {
        devices.add(PrinterDevice(name: device.name, address: device.address));
      });
    });
  }

  status() {
    _subscriptionStatus = instanceManager.stateBluetooth.listen((status) {
      setState(() {
        _currentStatus = status;
      });
      if (status == BTStatus.connected && pendingTask != null) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        }
        if (Platform.isIOS) {
          PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      }
    });
  }

  Future connectDevice() async {
    await instanceManager.connect(
      type: PrinterType.bluetooth,
      model: BluetoothPrinterInput(
        name: printerDefault.name,
        address: printerDefault.address!,
        isBle: isPairedDefault,
        autoConnect: true,
      ),
    );
    setState(() {});
  }

  Future disconnectDevice() async {
    await instanceManager.disconnect(type: PrinterType.bluetooth);
    status();
    setState(() {
      _currentStatus = BTStatus.none;
    });
  }

  void _printerEscPos(List<int> bytes, Generator generator) async {
    if (printerDefault.address!.isEmpty) return;
    if (_currentStatus != BTStatus.connected) return;
    bytes += generator.cut();
    pendingTask = null;

    if (Platform.isAndroid) pendingTask = bytes;
    if (Platform.isAndroid) {
      await instanceManager.send(type: PrinterType.bluetooth, bytes: bytes);
      pendingTask = null;
    } else {
      await instanceManager.send(type: PrinterType.bluetooth, bytes: bytes);
    }
  }

  Future _printReceiveTest() async {
    List<int> bytes = [];
    final generator = Generator(AppData.paperSize[paperDefault], await CapabilityProfile.load());
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text("PRUEBA TICKET",
        styles: PosStyles(
            align: AppData.posAlign["center"],
            width: AppData.posTextSize[2],
            height: AppData.posTextSize[2]));
    bytes += generator.text("CENTER",
        styles: PosStyles(
            align: AppData.posAlign["center"],
            width: AppData.posTextSize[1],
            height: AppData.posTextSize[1]));
    bytes += generator.text("LEFT", styles: PosStyles(align: AppData.posAlign["left"]));
    bytes += generator.text("RIGHT", styles: PosStyles(align: AppData.posAlign["right"]));
    bytes += generator.text("normal", styles: PosStyles(bold: AppData.boolText["normal"]));
    bytes += generator.text("Bool", styles: PosStyles(bold: AppData.boolText["bool"]));
    _printerEscPos(bytes, generator);
  }

  Future _printTicketSimulacion(dynamic dataTicket) async {
    List<int> bytes = [];
    final generator = Generator(AppData.paperSize[paperDefault], await CapabilityProfile.load());
    bytes += generator.setGlobalCodeTable('CP1252');
    List<dynamic> listRow = json.decode(json.encode(dataTicket));
    for (var row in listRow) {
      bytes += generator.text(row["content"],
          styles: PosStyles(
              align: AppData.posAlign[row["align"]],
              bold: AppData.boolText[row["style"]],
              width: AppData.posTextSize[row["size"]],
              height: AppData.posTextSize[row["size"]],
              fontType: AppData.posTextSize[row["font"]]));
    }
    _printerEscPos(bytes, generator);
  }

  void setPrinter(int paper) {
    BlocProvider.of<SettingsBloc>(context).add(SetPrinterEvent(
        name: printerSelect.name,
        address: printerSelect.address!,
        paired: isPairedSelect,
        paper: paper));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsInitialState) {}
        if (state is SettingsPrinterLoadingState) {
          setState(() {
            isLoading = true;
          });
        }
        if (state is SettingsPrinterReceivedState) {
          printerDefault.name = state.name;
          printerDefault.address = state.address;
          paperDefault = state.paper;
          isPairedDefault = state.paired;
          if (_currentStatus == BTStatus.connected) {
            disconnectDevice();
          }
          if (printerDefault.address!.isNotEmpty) {
            connectDevice();
          }
        }
        if (state is SettingsPrinterSuccessState) {
          setState(() {
            isLoading = false;
          });
        }

        if (state is SettingsTicketReceivedState) {
          _printTicketSimulacion(state.ticket);
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(title: const Text("Settings")),
                body: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(printerDefault.name),
                      subtitle: Text("${printerDefault.address!} | Papel: $paperDefault"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              printerSelect = printerDefault;
                              isPairedSelect = isPairedDefault;
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) => SelectSizePaperFrom(
                                  function: setPrinter,
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              BlocProvider.of<SettingsBloc>(context).add(DelPrinterEvent());
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                      leading: Icon(Icons.bluetooth, color: AppData.statusColor[_currentStatus]),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: (_currentStatus == BTStatus.connected)
                                ? () {
                                    _printReceiveTest();
                                  }
                                : null,
                            child: const Text("Ticket de Prueba")),
                        const SizedBox(width: 50),
                        ElevatedButton(
                            onPressed: (_currentStatus == BTStatus.connected)
                                ? () {
                                    BlocProvider.of<SettingsBloc>(context).add(PrintTicketEvent());
                                  }
                                : null,
                            child: const Text("Ticket de API(Simulacion)")),
                      ],
                    ),
                    const Divider(),
                    Text("Dispositivos disponibles", style: Theme.of(context).textTheme.headline5!),
                    const Divider(),
                    SwitchListTile(
                      title: const Text("Lista de dispositivos encontrados"),
                      subtitle: Text(!isPairedSelect ? "Emparejados" : "Encontrados"),
                      value: isPairedSelect,
                      onChanged: (value) {
                        setState(() {
                          isPairedSelect = value;
                        });
                        scan();
                      },
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(devices[index].name),
                          subtitle: Text(devices[index].address!),
                          onTap: () {
                           setState(() {
                             printerSelect = devices[index];
                           });
                          },
                          selected: printerSelect == devices[index],
                          trailing: printerSelect == devices[index]
                              ? ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) => SelectSizePaperFrom(
                                        function: setPrinter,
                                      ),
                                    );
                                  },
                                  child: const Text("Agregar"))
                              : null,
                        );
                      },
                    )
                  ],
                ),
              ),
              if (isLoading) const Center(child: CircularProgressIndicator())
            ],
          );
        },
      ),
    );
  }
}

class SelectSizePaperFrom extends StatefulWidget {
  const SelectSizePaperFrom({required this.function});

  final Function function;

  @override
  State<SelectSizePaperFrom> createState() => _SelectSizePaperFromState();
}

class _SelectSizePaperFromState extends State<SelectSizePaperFrom> {
  int? paper;

  ///*************** initState ***************
  @override
  void initState() {
    super.initState();
  }

  ///*************** dispose ***************
  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text("Selecciona papel"),
      content: DropdownButtonFormField<int>(
        decoration: const InputDecoration(labelText: "Papel"),
        items: const [
          DropdownMenuItem(value: 58, child: Text("58mm")),
          DropdownMenuItem(value: 72, child: Text("72mm")),
          DropdownMenuItem(value: 80, child: Text("80mm")),
        ],
        onChanged: (value) {
          setState(() {
            paper = value!;
          });
        },
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: (paper != null)
              ? () {
                  widget.function(paper);
                  Navigator.pop(context);
                }
              : null,
          child: const Text("Conectar"),
        ),
      ],
    );
  }
}
