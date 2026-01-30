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

  Map<String, List<int>> fit = {};
  List<Map<String, dynamic>> modules = [];

  @override
  void initState() {
    super.initState();
    fit['high'] = List.filled(widget.ship['high'], -1);
    fit['med'] = List.filled(widget.ship['med'], -1);
    fit['low'] = List.filled(widget.ship['low'], -1);
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //Text(widget.ship.toString()),
              SizedBox(height: 50,),
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
                          picture(modules.indexOf(m))
                        ],
                      ))
                    ],
                  ),
                  Column(
                    spacing: 10,
                    children: [
                      Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('High slots:'),
                          ...showHigh(),
                        ],
                      ),
                      Row(
                        spacing: 7,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Medium slots:'),
                          ...showMed(),
                        ],
                      ),
                      Row(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Low slots:'),
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
    //var f = await sb.from('players_ships').select().eq('ship_id', widget.ship['id']);
    //printD('loaded $f');
    //if (f.isNotEmpty && f.first['fit'] != null) fit = jsonDecode(f.first['fit']);
    //printD(fit.toString());
    modules = await sb.from('modules').select();
    printD(modules.toString());
    setState(() {
      
    });
  }

  void save() {
    printD('updating player ship ${widget.ship['id']}');
    sb.from('players_ships').update({'fit': fit}).eq('id', widget.ship['id']).select().then(print);
  }

  List<Widget> showHigh() {
    printD('show high slots with ${fit['high']}');
    return List.generate(
      widget.ship['high'],
      (i) =>
      DragTarget<int>(
        builder: (context, candidateItems, rejectedItems) {
          int id = fit['high']![i];
          printD('show place $i with module id $id');
          return id >= 0 ? picture(id) : Container(width: 30, height: 30,
            decoration: BoxDecoration(border: Border.all(width: 1,)),
          );
        },
        onWillAcceptWithDetails: (details) {
          print(details.data);
          return modules[details.data]['slot'] == 'high';
        },
        onAcceptWithDetails: (details) {
          List<int> high = fit['high']!;
          high[i] = details.data;
          save();
          setState(() {
            fit['high'] = high;
          });
        },
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
  
  Widget picture(int id) {
    Widget pic = Container(
      decoration: BoxDecoration(
        border: Border.all()
      ),
      width: 30,
      height: 30,
      child: Center(child: Text(modules[id]['id'].toString())),
    );
    return Draggable<int>(
      feedback: Material(child: pic),
      data: id,
      childWhenDragging: pic,
      child: pic,
    );

  }
}