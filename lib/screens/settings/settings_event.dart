import 'package:equatable/equatable.dart';
import 'package:flutter_post_printer_example/screens/settings/settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class GetPrinterEvent extends SettingsEvent {}

class SetPrinterEvent extends SettingsEvent {
  String name;
  String address;
  bool paired;
  int paper;

  SetPrinterEvent({
    required this.name,
    required this.address,
    required this.paired,
    required this.paper,
  });
}

class DelPrinterEvent extends SettingsEvent {}

class PrintTicketEvent extends SettingsEvent {}
