import 'package:bloc/bloc.dart';
import 'package:flutter_post_printer_example/screens/settings/settings.dart';
import 'package:flutter_post_printer_example/services/requests/request_ticket.dart';
import 'package:flutter_post_printer_example/services/storages/storage_printer.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  @override
  SettingsBloc() : super(SettingsInitialState());

  SettingsState get initialState => SettingsInitialState();

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    final sp = StoragePrinter();
    final rt=RequestTicket();
    try {
      if (event is GetPrinterEvent) {
        yield SettingsPrinterLoadingState();
        yield SettingsPrinterReceivedState(
            name: await sp.getName(),
            address: await sp.getAddress(),
            paired: await sp.getPaired(),
            paper: await sp.getPaper());
        yield SettingsPrinterSuccessState();
      }
      if (event is DelPrinterEvent) {
        yield SettingsPrinterLoadingState();
        sp.delPrinter();
        yield SettingsPrinterReceivedState(
            name: await sp.getName(),
            address: await sp.getAddress(),
            paired: await sp.getPaired(),
            paper: await sp.getPaper());
        yield SettingsPrinterSuccessState();
      }
      if (event is SetPrinterEvent) {
        yield SettingsPrinterLoadingState();
        sp.setPrinter(
            name: event.name, address: event.address, paired: event.paired, paper: event.paper);
        yield SettingsPrinterReceivedState(
            name: await sp.getName(),
            address: await sp.getAddress(),
            paired: await sp.getPaired(),
            paper: await sp.getPaper());
        yield SettingsPrinterSuccessState();
      }

      if(event is PrintTicketEvent){
        yield SettingsPrinterLoadingState();
        yield SettingsTicketReceivedState(ticket: await rt.getDataTicket());
        yield SettingsPrinterSuccessState();
      }
    } catch (error) {
      yield SettingsFailureState(error: error.toString());
    }
  }
}
