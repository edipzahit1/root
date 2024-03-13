import 'package:flutter/material.dart';
import 'package:root/preferences/buttons.dart';

//This will be the initial page where we can add route show routes and settings and other stuff maybe
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.level_2,
      body: Stack(
        children: [
          Image(image: AssetImage("assets/background.png")),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.1,
                    right: MediaQuery.of(context).size.width * 0.6),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.height * 0.2,
                      backgroundColor: AppColors.level_3,
                    ),
                    Container(
                      color: AppColors.level_3,
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                    color: AppColors.level_3,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(70),
                        topRight: Radius.circular(70))),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    AppColors.level_4),
                              ),
                              onPressed: () {},
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image(
                                      image: AssetImage("assets/settings.png"),
                                      height: 50,
                                      alignment: Alignment.bottomCenter,
                                    ),
                                  ),
                                  Text("asd"),
                                ],
                              )),
                          SizedBox(width: 100),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    AppColors.level_4),
                              ),
                              onPressed: () {},
                              child: Image(
                                image: AssetImage("assets/settings.png"),
                                height: 40,
                                alignment: Alignment.center,
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
