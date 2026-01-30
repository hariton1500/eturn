import 'package:eturn/funcs.dart';
import 'package:eturn/globals.dart';
import 'package:flutter/material.dart';

class ShipScreen extends StatefulWidget {
  const ShipScreen({super.key, required this.ship});
  final Map<String, dynamic> ship;
  @override
  State<ShipScreen> createState() => _ShipScreenState();
}

class _ShipScreenState extends State<ShipScreen> {

  Map<String, dynamic> fit = {};
  List<Map<String, dynamic>> modules = [];

  @override
  void initState() {
    super.initState();
    loadFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ship['name']),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(widget.ship.toString()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      ...modules.map((m) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        spacing: 10,
                        children: [
                          Text(m['name']),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all()
                            ),
                            width: 30,
                            height: 30,
                            child: Text(m['id'].toString()),
                          )
                        ],
                      ))
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ...showHigh(),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ...showMed(),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ...showLow(),
                        ],
                      ),
                    ],
                  )
                ],
              )
            ]
          ),
        )
      ),
    );
  }
  
  void loadFromDB() async {
    printD('Loading frm DB');
    var f = await sb.from('players_ships').select().eq('ship_id', widget.ship['id']);
    if (f.isNotEmpty) fit = f.first;
    printD(fit.toString());
    modules = await sb.from('modules').select();
    printD(modules.toString());
    setState(() {
      
    });
  }
  
  List<Widget> showHigh() {
    return List.filled(
      widget.ship['high'],
      Container(width: 30, height: 30,
        decoration: BoxDecoration(border: Border.all(width: 1,)),
      )
    );
  }

  List<Widget> showMed() {
    return List.filled(widget.ship['med'], Container(width: 30, height: 30,
        decoration: BoxDecoration(border: Border.all(width: 1,)),
      )
    );
  }

  List<Widget> showLow() {
    return List.filled(widget.ship['low'], Container(width: 30, height: 30,
        decoration: BoxDecoration(border: Border.all(width: 1,)),
      )
    );
  }


}