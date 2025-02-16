import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'package:reward_coins/RedemptionStoreScreen.dart';
import 'package:reward_coins/histry.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Bloc Events
abstract class CoinEvent {}
class ScratchCardUsed extends CoinEvent {}


// Bloc State
class CoinState {
  final int balance;
  final DateTime? lastScratchTime;
  final bool canScratch;

  CoinState({required this.balance, this.lastScratchTime})
      : canScratch = lastScratchTime == null ||
      DateTime.now().difference(lastScratchTime).inHours >= 1;
}

// Bloc Implementation
class CoinBloc extends Bloc<CoinEvent, CoinState> {
  CoinBloc(CoinState initialState) : super(initialState) {
    on<ScratchCardUsed>((event, emit) async {
      if (state.canScratch) {
        int reward = Random().nextInt(451) + 50; // Random 50-500 coins
        int newBalance = state.balance + reward;

        // Save to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('balance', newBalance);
        await prefs.setString('lastScratchTime', DateTime.now().toIso8601String());

        // Emit new state with updated balance and time
        emit(CoinState(balance: newBalance, lastScratchTime: DateTime.now()));
        _saveRedemptionHistory(newBalance,"Reward_coins");
      }
    });
  }

  // Load balance and last scratch time from SharedPreferences
  static Future<CoinState> loadInitialState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedBalance = prefs.getInt('balance') ?? 1000;
    String? savedLastScratchTime = prefs.getString('lastScratchTime');
    DateTime? lastScratchTime = savedLastScratchTime != null ? DateTime.parse(savedLastScratchTime) : null;

    return CoinState(balance: savedBalance, lastScratchTime: lastScratchTime);
  }
}

Future<void> _saveRedemptionHistory(int coinBalance,String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> redemptionHistory = prefs.getStringList('History') ?? [];


  String redemptionDetail =
      '$name | ${DateTime.now().toString()} | Balance: $coinBalance';

  redemptionHistory.add(redemptionDetail);

  // Save the updated list back to SharedPreferences
  await prefs.setStringList('History', redemptionHistory);
}
// Home Screen UI
class HomeScreen extends StatelessWidget {
  String username = 'piyush';
  var balance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CoinState>(
      future: CoinBloc.loadInitialState(), // Load initial state asynchronously
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while loading the state
          return Scaffold(
            appBar: AppBar(
              title: Text('Scratch & Win', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.black,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Scratch & Win', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.black,
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          final initialState = snapshot.data!;
          return BlocProvider(
            create: (context) => CoinBloc(initialState),
            child: Scaffold(
              appBar: AppBar(
                title: Text('Scratch & Win', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.black,
              ),
              body: BlocBuilder<CoinBloc, CoinState>(
                builder: (context, state) {
                  balance = state.balance;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text('Coin Balance: ${state.balance}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 40),
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: state.canScratch
                                ? () => context.read<CoinBloc>().add(ScratchCardUsed())
                                : null,
                            child: Container(
                              width: 250,
                              height: 150,
                              decoration: BoxDecoration(
                                color: state.canScratch ? Colors.orange : Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: state.canScratch
                                  ? Text('Scratch Now!',
                                  style: TextStyle(fontSize: 20, color: Colors.white))
                                  : Text('Next Scratch: ${state.lastScratchTime!.add(Duration(hours: 1)).hour}:00',
                                  style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {},
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Histroy()),
                      );
                    },
                    icon: Icon(
                      Icons.history,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Container(); // Should never reach here
      },
    );
  }
}

