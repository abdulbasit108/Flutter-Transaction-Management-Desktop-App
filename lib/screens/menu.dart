import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transaction_account/screens/accounts.dart';
import 'package:transaction_account/screens/transaction.dart';
import 'package:transaction_account/screens/ledger.dart';
import 'package:transaction_account/screens/summary.dart';
import 'package:transaction_account/screens/transaction_view_edit.dart';
import 'package:transaction_account/provider/user_provider.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  
  

  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${user.username}!',style: const TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: 
        user.id == 2 ?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(
                context, MaterialPageRoute(builder: (context) =>const ExcelGrid()));
                }, 
                child: Text('Transactions'.toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold),),
                ),
              ),
            ),
            SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(
                context, MaterialPageRoute(builder: (context) =>const TransactionView()));
                }, 
                child: Text('Transaction View & Edit'.toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold),),
                ),
              ),
            ),
            SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) =>const LedgerGrid()));
                }, child: Text('Ledger'.toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold),)),
              ),
            ),
            SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) =>const Accounts()));
                }, child: Text('Accounts'.toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold),)),
              ),
            ),
            SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) =>const Summary()));
                }, child: Text('Summary'.toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold),)),
              ),
            )
          ],
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(
                context, MaterialPageRoute(builder: (context) =>const ExcelGrid()));
                }, 
                child:  Text('Transactions'.toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold),),
                ),
              ),
            ),
            
            SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) =>const LedgerGrid()));
                }, child:  Text('Ledger'.toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold),)),
              ),
            ),
            SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) =>const Accounts()));
                }, child: Text('Accounts'.toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold),)),
              ),
            )
          ],
        )
      ),
    bottomNavigationBar: Text('Powered By PlutoSol',style: TextStyle(color: Colors.grey[700]),textAlign: TextAlign.center,),
    );
  }
}