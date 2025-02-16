import 'package:flutter/material.dart';
import 'package:reward_coins/histry.dart';
import 'package:reward_coins/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RedeemableItem {
  final String name;
  final int coinCost;

  RedeemableItem({required this.name, required this.coinCost});
}

class RedeemScreen extends StatefulWidget {

  const RedeemScreen({super.key});

  @override
  _RedeemScreenState createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  int coinBalance = 0;  // Initial coin balance
  String notificationMessage = ''; // For displaying messages (success or failure)

  @override
  void initState() {
    super.initState();
    _loadCoinBalance();
  }
  void _loadCoinBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int balance = prefs.getInt('balance') ?? 1000;  // Default value is 1000
    setState(() {
      coinBalance = balance;
    });
  }
  // List of redeemable items
  final List<RedeemableItem> items = [
    RedeemableItem(name: 'Discount Coupon', coinCost: 500),
    RedeemableItem(name: 'Gift Card', coinCost: 300),
    RedeemableItem(name: 'Free Trial', coinCost: 1000),
  ];

  // Redeem item logic
  Future<void> redeemItem(RedeemableItem item) async {
    if (coinBalance >= item.coinCost) {
      setState(() {
        coinBalance -= item.coinCost;
        notificationMessage = 'Successfully redeemed ${item.name}!';

      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('balance', coinBalance);
      _saveRedemptionHistory(item);
    } else {
      setState(() {
        notificationMessage = 'Insufficient Coins';
      });
      // Show Alert Dialog when insufficient funds
      _showInsufficientFundsDialog();
    }
  }
  Future<void> _saveRedemptionHistory(RedeemableItem item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> redemptionHistory = prefs.getStringList('History') ?? [];

    // Prepare the redemption details (name, time, updated balance)
    String redemptionDetail =
        '${item.name} | ${DateTime.now().toString()} | Balance: $coinBalance';

    redemptionHistory.add(redemptionDetail);

    // Save the updated list back to SharedPreferences
    await prefs.setStringList('History', redemptionHistory);
  }


  // Show Alert Dialog for insufficient funds
  void _showInsufficientFundsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Insufficient Funds'),
          content: Text('You do not have enough coins to redeem this item.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scratch & Win',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black, // Set app bar color to black
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Coin Balance Display
            Text(
              'Coin Balance: \$${coinBalance}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),

            // Notification Message
            Text(
              notificationMessage,
              style: TextStyle(
                  fontSize: 18,
                  color: notificationMessage == 'Insufficient Coins'
                      ? Colors.red
                      : Colors.green),
            ),
            SizedBox(height: 16),

            // Redeemable Items List
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index].name),
                    subtitle: Text('Cost: ${items[index].coinCost} coins'),
                    trailing: ElevatedButton(
                      onPressed: () => redeemItem(items[index]),
                      child: Text('Redeem'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
              size: 40.0, // Set your desired size here
            ),
          ),

          IconButton(
            onPressed: () {

            },
            icon: Icon(
              Icons.store,
              size: 40.0, // Set your desired size here
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
              size: 40.0, // Set your desired size here
            ),
          ),
        ],
      ),
    );
  }
}
