import 'dart:convert';

import 'package:flutter/material.dart';


import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transaction_account/provider/user_provider.dart';




class LedgerGrid extends StatefulWidget {
  const LedgerGrid({
    Key? key,
  }) : super(key: key);

  @override
  State<LedgerGrid> createState() => _LedgerGridState();
}

class _LedgerGridState extends State<LedgerGrid> {
  // final ApiClient apiClient = ApiClient();
  NumberFormat formatter = NumberFormat.decimalPatternDigits(
    locale: 'en_us',
    decimalDigits: 2,
);
  List<Map<String, dynamic>> dataList = [];
  final int numberOfRows = 300;
  final int TopRows = 10;

  final ScrollController _horizontal = ScrollController(),
      _vertical = ScrollController();
  TextEditingController searchController = TextEditingController();
  final int numColumns = 9;
  final int TopColumns = 18;

  bool isSearching = false; // Flag to trigger data fetching
  String typedNumber = ''; // To store the typed value

  // Map<String, dynamic> fetchData = {};



  List<List<TextEditingController>> textControllers = [];
  int selectedRow = 0;
  int selectedCol = 0;

  @override
  void initState() {
    super.initState();
    // Initialize textControllers for each cell
    // for (int i = 0; i < numberOfRows; i++) {
    //   textControllers.add(List.generate(
    //     TopColumns,
    //         (index) => TextEditingController(),
    //   ));


    // }


  }

  @override
  void dispose() {
    // Dispose of text controllers
    // for (var row in textControllers) {
    //   for (var controller in row) {
    //     controller.dispose();
    //   }
    // }
    super.dispose();
  }


  Future<Map<String, dynamic>> fetchedData(bool export, String number) async {

   final userProvider = Provider.of<UserProvider>(context, listen: false);
    final headers = {
      'Authorization': 'Token ${userProvider.user.token}',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var data = json.encode({
      "export": false
    });
    var dio = Dio();
    var response = await dio.request(
      'http://127.0.0.1:8000/api/transactions/v1/$number/ledger/',

      options: Options(
        method: 'GET',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      return response.data;
    }
    else {

      throw Exception(response.statusMessage);
    }
  }

  void exportData(bool export, String number) async {
   final userProvider = Provider.of<UserProvider>(context, listen: false);
    final headers = {
      'Authorization': 'Token ${userProvider.user.token}',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var data = json.encode({
      "export": false
    });
    var dio = Dio();
    var response = await dio.request(
      'http://127.0.0.1:8000/api/transactions/v1/export/$number/ledger/',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print(json.encode(response.data));
    }
    else {
      print(response.statusMessage);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEDGER'),
      ),


      body:
      SizedBox(
        width: double.infinity,
        child: Scrollbar(
          controller: _vertical,
          thumbVisibility: true,
          trackVisibility: true,
          child: Scrollbar(
            controller: _horizontal,
            thumbVisibility: true,
            trackVisibility: true,
            notificationPredicate: (notif) => notif.depth == 1,
            child: SingleChildScrollView(
              controller: _vertical,
              child: SingleChildScrollView(
                controller: _horizontal,
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 70,
                            child: Text(
                              'ACCOUNT:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 150,
                            child: TextFormField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onFieldSubmitted: (value) {
                                setState(() {
                                  isSearching = true; // Set the flag to true when the form is submitted.
                                  typedNumber = value; // Store the typed value for later use
                                });
                              },

                              // Add any logic or controller here for the search box
                            ),
                          ),
                        ],
                      ),
                    ),

                  FutureBuilder<Map<String, dynamic>?>(
                    future: isSearching ? fetchedData(false, typedNumber) : null,
                    builder: (context, accountSnapshot) {
                      if (accountSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (accountSnapshot.hasError) {
                        return Text('Error: ${accountSnapshot.error}');
                      } else if (accountSnapshot.data != null) { // Check if data is not null
                        final accountData = accountSnapshot.data!['data']['account'];
                        final transactionData = accountSnapshot.data!['data']['transactions'];
                        final debitData = accountSnapshot.data!['data']['debit_credit'];


                        return Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 70,
                                    child: Text(
                                      'TITLE:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 150,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 1.0, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          accountData?['title'] ?? '',
                                          // 'data',
                                          style: const TextStyle(fontSize: 16.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: 250,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle button tap here, make API call
                                  exportData(false, typedNumber); // A function to make the API call
                                },
                                child: const Text("EXPORT",style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                              const SizedBox(
                                height: 40,
                              ),

                              Center(
                              child: Column(
                                children:[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    HeaderWidgetTop(
                                      index: 0,
                                      mainHeadertop: MainHeaderTop,
                                      mainHeaderStyleTop: mainHeaderStyleTop,
                                      width: 42,
                                      color: Colors.lightGreen[300],                                  ),
                                    HeaderWidgetTop(
                                      index: 1,
                                      mainHeadertop: MainHeaderTop,
                                      mainHeaderStyleTop: mainHeaderStyleTop,
                                      width: 100,
                                      color: Colors.lightGreen[300],                                  ),
                                    HeaderWidgetTop(
                                      index: 2,
                                      mainHeadertop: MainHeaderTop,
                                      mainHeaderStyleTop: mainHeaderStyleTop,
                                      width: (100),
                                      color: Colors.lightGreen[300],                                  ),
                                    HeaderWidgetTop(
                                      index: 3,
                                      mainHeadertop: MainHeaderTop,
                                      mainHeaderStyleTop: mainHeaderStyleTop,
                                      width: (100),
                                      color: Colors.lightGreen[300],                                  ),
                                    HeaderWidgetTop(
                                      index: 4,
                                      mainHeadertop: MainHeaderTop,
                                      mainHeaderStyleTop: mainHeaderStyleTop,
                                      width: (100),
                                      color: Colors.lightGreen[300],                                  ),
                                    //
                                    // Add more HeaderWidget elements as needed

                                  ],
                                ),
                                  SizedBox(
                                    height: 110,
                                    width: 10+42+(100*4),
                                    child: ListView.builder(
                                      scrollDirection: Axis.vertical, // Vertical scroll
                                      itemCount: debitData != null && debitData != null
                                          ? debitData.length
                                          : 0,
                                      itemBuilder: (context, index) {
                                        if (debitData != null && debitData!= null) {
                                          final currency = debitData.keys.toList()[index];
                                          final debit = debitData[currency];
                                          return Row(
                                            children: [
                                              SizedBox(
                                                width: 42+10,
                                                child: Text(' $currency', textAlign: TextAlign.center),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Text(formatter.format(debit['opening']), textAlign: TextAlign.center),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  '(${formatter.format(debit['credit'])})',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(
                                                width: 100,
                                                child: Text(formatter.format(debit['debit']), textAlign: TextAlign.center),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Text(' ${formatter.format(debit['closing'])}',textAlign: TextAlign.center),
                                              ),
                                            ],
                                          );
                                        } else {
                                          // Handle the case where debitData or its sub-property is null
                                          return const SizedBox(
                                            width: 100 * 5, // Adjust the width as needed
                                            height: 50, // Set a placeholder height
                                            child: Center(
                                              child: Text("No data available"), // Customize the message
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  )

                                ],
                              ),



                            ),



                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    HeaderWidget(
                                      index: 0,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 65*2 ,
                                      color: Colors.lightGreen[300],
                                    ),
                                    // HeaderWidget(
                                    //   index: 1,
                                    //   mainHeader: MainHeader,
                                    //   mainHeaderStyle: mainHeaderStyle,
                                    //   width: (145),
                                    //   color: Colors.yellow[600],
                                    // ),
                                    HeaderWidget(
                                      index: 3,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: (170),
                                      color: Colors.lightGreen[300],
                                    ),
                                    HeaderWidget(
                                      index: 1,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: (100*3)+50,
                                      color: Colors.lightGreen[300],
                                    ),

                                  ],
                                ),

                                const SizedBox(

                                  width: (65*2)+(170)+(100*3)+50, // Set the width of the row
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 50.0,

                                        child: Text('V.R',textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                          ),), // Replace with your data
                                      ),

                                      SizedBox(
                                        width: 80.0,

                                        child: Text('Date',textAlign: TextAlign.center,
                                          style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                        ),), // Replace with your data
                                      ),
                                      SizedBox(
                                        width: 170,

                                        child: Text('REFERENCE',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                          ),), // Replace with your data
                                      ),

                                      // Container(
                                      //   width: 145.0,
                                      //
                                      //   child: Text('Title',
                                      //     textAlign: TextAlign.center,
                                      //     style: TextStyle(
                                      //     fontWeight: FontWeight.w900,
                                      //     color: Colors.black,
                                      //   ),), // Replace with your data
                                      // ),
                                      SizedBox(
                                        width: 50,

                                        child: Text('Cur', textAlign: TextAlign.center,style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                        ),), // Replace with your data
                                      ),
                                      SizedBox(
                                        width: 100.0,

                                        child: Text('Debit',textAlign: TextAlign.center, style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                        ),), // Replace with your data
                                      ),
                                      SizedBox(
                                        width: 100.0,
                                        child: Text(
                                          'Credit',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,

                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        width: 100.0,

                                        child: Text('Balance',textAlign: TextAlign.center, style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                        ),), // Replace with your data
                                      ),


                                      // Additional Containers and Text widgets for your data here
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 680,
                                  width: (65*2)+(170)+(100*3)+50,
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical, // Vertical scroll
                                    itemCount: transactionData.length,
                                    itemBuilder: (context, index) {
                                      final transaction = transactionData[index];
                                      return Row(
                                        children: [
                                          SizedBox(
                                              width: 50,
                                              child: Text('${transaction['entry_no']}', textAlign: TextAlign.center,)
                                          ),
                                          SizedBox(
                                            width: 80,
                                              child: Text('${transaction['date']}', textAlign: TextAlign.center,)
                                          ),
                                          SizedBox(
                                              width: 170,
                                              child: Text(' ${transaction['narration']}',textAlign: TextAlign.center,)),


                                          // Container(
                                          //     width: 145,
                                          //     child: Text(' ${transaction['title']}',textAlign: TextAlign.center,)),

                                          SizedBox(
                                              width: 50,
                                              child: Text(' ${transaction['currency']}',textAlign: TextAlign.center,)),

                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              formatter.format(transaction['debit_amount']),textAlign: TextAlign.center,

                                            ),
                                          ),
                                          SizedBox(
                                            width: 100.0,
                                            child: Text(
                                              '(${formatter.format(transaction['credit_amount'])})',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              formatter.format(transaction['balance']),textAlign: TextAlign.center,

                                            ),
                                          ),

                                          ],
                                      );
                                    },
                                  ),
                                ),



                              ],
                            ),
                          ],
                        );

                    }
                      else {
                        // Handle the case where data is null
                        return const Text('No data available');
                      }
                    },

                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  List<String> MainHeader = [
    'Document',

    'Transaction',
    'PRE DOCUMENT',
    'NARRATION',
  ];

  TextStyle mainHeaderStyle =
  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    super.key,
    required this.mainHeader,
    required this.mainHeaderStyle,
    required this.width,
    required this.color,
    this.index,
  });

  final List<String> mainHeader;
  final TextStyle mainHeaderStyle;
  final double width;
  final dynamic color;
  final dynamic index;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: width,
      height: 30,
      decoration: BoxDecoration(
        color: color,
      ),
      child: Text(mainHeader[index], style: mainHeaderStyle),
    );
  }
}

List<String> MainHeaderTop = [
  'CUR',
  'Opening',
  'CR',
  'DR',
  'Closing',
];


TextStyle mainHeaderStyleTop =
const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);


class HeaderWidgetTop extends StatelessWidget {
  const HeaderWidgetTop({
    super.key,
    required this.mainHeadertop,
    required this.mainHeaderStyleTop,
    required this.width,
    required this.color,
    this.index,
  });

  final List<String> mainHeadertop;
  final TextStyle mainHeaderStyleTop;
  final double width;
  final dynamic color;
  final dynamic index;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: width,
      height: 30,
      decoration: BoxDecoration(
        color: color,
      ),
      child: Text(mainHeadertop[index], style: mainHeaderStyleTop),
    );
  }
}