import 'package:equatable/equatable.dart';
import 'package:flutter_post_printer_example/screens/settings/settings.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitialState extends SettingsState {}

class SettingsPrinterLoadingState extends SettingsState {}

class SettingsPrinterReceivedState extends SettingsState {
  String name;
  String address;
  bool paired;
  int paper;

  SettingsPrinterReceivedState({
    required this.name,
    required this.address,
    required this.paired,
    required this.paper,
  });

  @override
  List<Object> get props => [name, address, paired, paper];

  @override
  String toString() =>
      "SettingsPrinterReceivedState{ name: $name,address:$address,paired:$paired,paper:$paper}";
}

class SettingsPrinterSuccessState extends SettingsState {}

class SettingsTicketReceivedState extends SettingsState {
  dynamic ticket;
  SettingsTicketReceivedState({required this.ticket});
  @override
  List<Object> get props => [ticket];
  @override
  String toString() => "SettingsTicketReceivedState{ ticket: $ticket}";
}

class SettingsFailureState extends SettingsState {
  final String error;

  const SettingsFailureState({required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => "SettingsFailureState{error:$error}";
}
