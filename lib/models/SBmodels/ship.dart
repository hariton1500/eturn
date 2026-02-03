// ignore_for_file: non_constant_identifier_names

class ShipSB {
  late int id;
  late DateTime created_at;
  int? fraction_id, class_id, max_speed, shield, armor, hull, high, med, low, power, cpu, cargo;
  String? name;

  ShipSB fromMap(Map<String, dynamic> map) {
    return ShipSB()
      ..id = map['id']
      ..created_at = DateTime.parse(map['created_at'])
      ..fraction_id = map['fraction_id']
      





      ;
  }
}