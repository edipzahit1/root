import 'package:flutter/material.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/screens/addRoute/draggableSheet.dart';
import 'package:root/screens/addRoute/mapBuilder.dart';
import 'package:root/screens/myRoutes/myRoutes.dart';

class AddRoutePage extends StatefulWidget {
  final List<Map<String, double>>? locations;
  const AddRoutePage({Key? key, this.locations}) : super(key: key);

  @override
  State<AddRoutePage> createState() => _AddRoutePageState();
}

class _AddRoutePageState extends State<AddRoutePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.level_1,
        leading: Container(
          decoration: BoxDecoration(
            color: AppColors.level_5,
            borderRadius: BorderRadius.circular(8),
          ),
          child: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(AppColors.level_5),
              ),
              onPressed: () {
                //List<Map<String, double>> orderedRoute = callServer(widget.locations);
              },
              child: const MyTexts(text: "Start Optimization"))
        ],
      ),
      body: Stack(
        children: [
          BuildMap(locations: widget.locations /*orderedRoute: orderedRoute*/ ),
          DraggableSheet(locations: widget.locations),
        ],
      ),
    );
  }
}
