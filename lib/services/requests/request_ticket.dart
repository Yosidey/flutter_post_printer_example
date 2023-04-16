

class RequestTicket {
  Future<dynamic> getDataTicket() async {
    var jsom = [
      {"content": "Title Ticket", "align": "center", "style": "bool", "size": 1, "font": "A"},
      {"content": "-Item 1: Product", "align": "left", "style": "normal", "size": 1, "font": "B"},
      {"content": "-Item 2: Product", "align": "left", "style": "normal", "size": 1, "font": "B"},
      {"content": "-Item 3: Product", "align": "left", "style": "normal", "size": 1, "font": "B"},
      {"content": "-Item 4: Product", "align": "left", "style": "normal", "size": 1, "font": "B"},
      {"content": "-Item 5: Product", "align": "left", "style": "normal", "size": 1, "font": "B"},
      {"content": "-Item 6: Product", "align": "left", "style": "normal", "size": 1, "font": "B"},
      {"content": "Total: 19233.55", "align": "right", "style": "bool", "size": 1, "font": "B"},
      {"content": "Gracias por tu compra", "align": "center", "style": "normal", "size": 1, "font": "A"}
    ];
    print("Inicio API");
    /*await Future.delayed(const Duration(seconds: 3));
    print("Tiempo de espera de respuesta de tu api termino");
    return jsom;*/
    return Future.delayed(const Duration(seconds: 3), () {
      print("Tiempo de espera de respuesta de tu api termino");
      return jsom;
    });
  }
}
