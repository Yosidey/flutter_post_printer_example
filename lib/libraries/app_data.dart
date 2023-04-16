library app_data;

import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform/printer.dart';

const KEY_NAME = "key.name.printer";
const KEY_ADDRESS = "key.address.printer";
const KEY_PAIRED = "key.is.paired";
const KEY_PAPER = "key.size.paper";

const Map statusColor = {
  BTStatus.none: Colors.red,
  BTStatus.connecting: Colors.blueGrey,
  BTStatus.connected: Colors.green
};

const Map paperSize = {null: PaperSize.mm58, 58: PaperSize.mm58, 72: PaperSize.mm72, 80: PaperSize.mm80};
const Map posAlign = {
  null: PosAlign.left,
  "left": PosAlign.left,
  "center": PosAlign.center,
  "right": PosAlign.right
};
const Map boolText = {null: false, "normal": false, "bool": true};
const Map posFontType = {null: PosFontType.fontA, "A": PosFontType.fontA, "B": PosFontType.fontB};

Map posTextSize = {
  1: PosTextSize.size1,
  2: PosTextSize.size2,
  3: PosTextSize.size3,
  4: PosTextSize.size4,
  5: PosTextSize.size5,
  6: PosTextSize.size6,
  7: PosTextSize.size7,
  8: PosTextSize.size8,
};
