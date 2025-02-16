import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reward_coins/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'RedemptionStoreScreen.dart';

class Histroy extends StatefulWidget {
  const Histroy({super.key});

  @override
  State<Histroy> createState() => _HistroyState();
}

class _HistroyState extends State<Histroy> {
  List<String> _history = [];
  _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('History') ?? [];
    setState(() {
      _history = history;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scratch & Win',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black, // Set app bar color to black
      ),

      body:  _history.isEmpty
          ? Center(child: Text('No history available'))
          : ListView.builder(
        itemCount: _history.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_history[index]),
          );
        },
      ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              icon: Icon(
                Icons.home,
                size: 40.0,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RedeemScreen()),
                );
              },
              icon: Icon(
                Icons.store,
                size: 40.0,
              ),
            ),
            IconButton(
              onPressed: () {

              },
              icon: Icon(
                Icons.history,
                size: 40.0,
              ),
            ),
          ],
        )
    );
  }
}
