// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transaction_account/provider/user_provider.dart';

class TransactionView extends StatefulWidget {
  const TransactionView({
    Key? key,
  }) : super(key: key);

  @override
  State<TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<TransactionView> {
  // final ApiClient apiClient = ApiClient();
  NumberFormat formatter = NumberFormat.decimalPatternDigits(
    locale: 'en_us',
    decimalDigits: 2,
  );
  final List<String> _curOptions = ['MZN', 'USD', 'ZAR', 'EUR', 'AED'];
  List<Map<String, dynamic>> dataList = [];
  final int numberOfRows = 300;

  final ScrollController _horizontal = ScrollController(),
      _vertical = ScrollController();
  TextEditingController searchController = TextEditingController();
  TextEditingController searchController2 = TextEditingController();
  TextEditingController searchController3 = TextEditingController();
  final int numColumns = 12;
  bool isChecked = false;

  bool isSearching = false;
  bool isSearching2 = false;
  bool entrySearching = false; // Flag to trigger data fetching
  String date = '';
  String todate = '';
  String entry = ''; // To store the typed value

  List<List<TextEditingController>> textControllers = [];
  int selectedRow = 0;
  int selectedCol = 0;

  void updateValid(int entryNum, bool valid) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final headers = {
      'Authorization': 'Token ${userProvider.user.token}',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final url = Uri.parse('http://127.0.0.1:8000/api/transactions/v1/update/');

    final res = await http.patch(
      url,
      headers: headers,
      body: jsonEncode({
        "entry_no": entryNum,
        "is_valid": valid,
      }),
    );

    final status = res.statusCode;
    print(res.body);
    status == 200
        ? ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Transaction Updated Sucessfully"),
            ),
          )
        : ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Transaction Not Updated"),
            ),
          );
  }

  void updateEntry(Object data) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final headers = {
      'Authorization': 'Token ${userProvider.user.token}',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final url = Uri.parse('http://127.0.0.1:8000/api/transactions/v1/update/');

    final res = await http.patch(url, headers: headers, body: data);

    final status = res.statusCode;

    print(res.body);
    status == 200
        ? setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Transaction Updated Sucessfully"),
              ),
            );
          })
        : ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Transaction Not Updated"),
            ),
          );
  }

  Future<Map<String, dynamic>> fetchedData(
      String date, String todate, String entry) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final headers = {
      'Authorization': 'Token ${userProvider.user.token}',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    print('run');
    String apiUrl;

    if (searchController3.text.isNotEmpty) {
      apiUrl =
          'http://127.0.0.1:8000/api/transactions/v1/${searchController3.text}/details/';
    } else if (searchController.text.isNotEmpty &&
        searchController2.text.isNotEmpty) {
      List<String> datePartsFrom = searchController2.text.split('-');
      List<String> datePartsTo = searchController.text.split('-');

      int dayFrom = int.parse(datePartsFrom[0]);
      int monthFrom = int.parse(datePartsFrom[1]);
      int yearFrom = int.parse(datePartsFrom[2]);

      int dayTo = int.parse(datePartsTo[0]);
      int monthTo = int.parse(datePartsTo[1]);
      int yearTo = int.parse(datePartsTo[2]);
      apiUrl =
          'http://127.0.0.1:8000/api/transactions/v1/all/details/?from_date=$yearFrom-$monthFrom-$dayFrom&to_date=$yearTo-$monthTo-$dayTo';
    } else {
      throw Exception('Invalid parameters');
    }

    var dio = Dio();
    var response = await dio.get(
      apiUrl,
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(response.statusMessage);
    }
  }

  void exportData(bool export, String number) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final headers = {
      'Authorization': 'Token ${userProvider.user.token}',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var data = json.encode({"export": false});
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
    } else {
      print(response.statusMessage);
    }
  }

  Future<void> _showAlertDialog(dynamic transaction) async {
    final formKey = GlobalKey<FormState>();
    // TextEditingController fromAccountIdcontroller = TextEditingController();
    // TextEditingController fromAccountTitlecontroller = TextEditingController();
    TextEditingController initialAmountcontroller = TextEditingController();
    TextEditingController fromCurrencycontroller = TextEditingController();
    TextEditingController multiplyBycontroller = TextEditingController();
    TextEditingController divideBycontroller = TextEditingController();
    // TextEditingController toAccountIdcontroller = TextEditingController();
    // TextEditingController toAccountTitlecontroller = TextEditingController();
    TextEditingController finalAmountcontroller = TextEditingController();
    TextEditingController toCurrencycontroller = TextEditingController();
    TextEditingController narrationController = TextEditingController();

    initialAmountcontroller.text = transaction['initial_amount'].toString();
    fromCurrencycontroller.text = transaction['from_currency'].toString();
    multiplyBycontroller.text = transaction['multiply_by'].toString();
    divideBycontroller.text = transaction['divide_by'].toString();
    finalAmountcontroller.text = transaction['converted_amount'].toString();
    toCurrencycontroller.text = transaction['to_currency'].toString();
    narrationController.text = transaction['narration'].toString();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Transaction'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
                child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Entry Number: ${transaction['entry_no']} "),
                  Text("Date: ${transaction['date']} "),
                  Text("Account 1 ID: ${transaction['from_account_id']} "),
                  Text(
                      "Account 1 Title: ${transaction['from_account_title']} "),
                  TextFormField(
                    controller: initialAmountcontroller,
                    decoration:
                        const InputDecoration(labelText: 'Initial Amount'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: fromCurrencycontroller,
                    decoration: const InputDecoration(labelText: 'From Cur'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      for (int i = 0; i < _curOptions.length; i++) {
                        if (value == _curOptions[i].substring(0, 1)) {
                          fromCurrencycontroller.text = _curOptions[i];
                          break;
                        }
                      }
                    },
                  ),
                  TextFormField(
                    controller: multiplyBycontroller,
                    decoration: const InputDecoration(labelText: 'Multiply'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: divideBycontroller,
                    decoration: const InputDecoration(labelText: 'Divide'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    readOnly: true,
                    controller: finalAmountcontroller,
                    decoration:
                        const InputDecoration(labelText: 'Final Amount'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: toCurrencycontroller,
                    decoration: const InputDecoration(labelText: 'To Cur'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      for (int i = 0; i < _curOptions.length; i++) {
                        if (value == _curOptions[i].substring(0, 1)) {
                          toCurrencycontroller.text = _curOptions[i];
                          break;
                        }
                      }
                    },
                  ),
                  Text("Account 2 ID: ${transaction['to_account_id']} "),
                  Text("Account 2 Title: ${transaction['to_account_title']} "),
                  TextFormField(
                    controller: narrationController,
                    decoration: const InputDecoration(labelText: 'Narration'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            )),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (double.parse(multiplyBycontroller.text) == 1.0 &&
                      double.parse(divideBycontroller.text) != 1.0) {
                    finalAmountcontroller.text =
                        (double.parse(initialAmountcontroller.text) /
                                double.parse(divideBycontroller.text))
                            .toString();
                  } else if (double.parse(multiplyBycontroller.text) != 1.0 &&
                      double.parse(divideBycontroller.text) == 1.0) {
                    finalAmountcontroller.text =
                        (double.parse(initialAmountcontroller.text) *
                                double.parse(multiplyBycontroller.text))
                            .toString();
                  } else if (double.parse(multiplyBycontroller.text) == 1.0 &&
                      double.parse(divideBycontroller.text) == 1.0) {
                    toCurrencycontroller.text = fromCurrencycontroller.text;
                    finalAmountcontroller.text = initialAmountcontroller.text;
                  }
                  var data = jsonEncode({
                    "transactions": [
                      {
                        "entry_no": transaction['entry_no'],
                        "multiply_by": double.parse(multiplyBycontroller.text),
                        "from_currency": fromCurrencycontroller.text,
                        "to_currency": toCurrencycontroller.text,
                        "initial_amount":
                            formatter.format(double.parse(initialAmountcontroller.text)).replaceAll(',', ''),
                        "converted_amount":
                            formatter.format(double.parse(finalAmountcontroller.text)).replaceAll(',', ''),
                        "divide_by": double.parse(divideBycontroller.text),
                        "narration": narrationController.text
                      }
                    ]
                  });
                  updateEntry(data);
                  Navigator.of(context).pop();
                }
              },
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
          title: const Text('TRANSACTION VIEW & EDIT'),
        ),
        body: SizedBox(
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
                            const Text(
                              'DATE FROM:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: searchController2,
                                decoration: const InputDecoration(
                                  hintText: 'DD-MM-YYYY',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                onFieldSubmitted: (value) {
                                  setState(() {
                                    isSearching =
                                        true; // Set the flag to true when the form is submitted.
                                    date =
                                        value; // Store the typed value for later use
                                  });
                                },

                                // Add any logic or controller here for the search box
                              ),
                            ),
                            const Text(
                              ' TO:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: searchController,
                                decoration: const InputDecoration(
                                  hintText: 'DD-MM-YYYY',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                onFieldSubmitted: (value) {
                                  setState(() {
                                    isSearching2 =
                                        true; // Set the flag to true when the form is submitted.
                                    todate =
                                        value; // Store the typed value for later use
                                  });
                                },

                                // Add any logic or controller here for the search box
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Text(
                              'ENTRY NO:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: searchController3,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                onFieldSubmitted: (value) {
                                  setState(() {
                                    entrySearching =
                                        true; // Set the flag to true when the form is submitted.
                                    entry =
                                        value; // Store the typed value for later use
                                  });
                                },

                                // Add any logic or controller here for the search box
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: (searchController2.text.isNotEmpty &&
                                    isSearching2 == true) ||
                                entrySearching == true
                            ? fetchedData(date, todate, entry)
                            : null,
                        builder: (context, accountSnapshot) {
                          if (accountSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (accountSnapshot.hasError) {
                            return Text('Error: ${accountSnapshot.error}');
                          } else if (accountSnapshot.data != null) {
                            // Check if data is not null
                            final transactionData =
                                accountSnapshot.data!['data']['results'];

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    HeaderWidget(
                                      index: 12,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 40,
                                      color: Colors.lightGreen[300],
                                    ),
                                    HeaderWidget(
                                      index: 13,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 60,
                                      color: Colors.lightGreen[300],
                                    ),
                                    HeaderWidget(
                                      index: 0,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 60,
                                      color: Colors.lightGreen[300],
                                    ),
                                    HeaderWidget(
                                      index: 14,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 80,
                                      color: Colors.lightGreen[300],
                                    ),
                                    HeaderWidget(
                                      index: 1,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 60,
                                      color: Colors.lightGreen[300],
                                    ),
                                    HeaderWidget(
                                      index: 2,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 100,
                                      color: Colors.lightGreen[300],
                                    ),
                                    HeaderWidget(
                                      index: 3,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 100,
                                      color: Colors.lightGreen[300],

                                    ),
                                    HeaderWidget(
                                      index: 4,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 60,
                                      color: Colors.lightGreen[300],

                                    ),
                                    HeaderWidget(
                                      index: 5,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 60,
                                      color: Colors.lightGreen[300],

                                    ),
                                    HeaderWidget(
                                      index: 6,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 60,
                                      color: Colors.lightGreen[300],

                                    ),
                                    HeaderWidget(
                                      index: 7,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 100,
                                      color: Colors.lightGreen[300],

                                    ),
                                    HeaderWidget(
                                      index: 8,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 60,
                                      color: Colors.lightGreen[300],

                                    ),
                                    HeaderWidget(
                                      index: 9,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 60,
                                      color: Colors.lightGreen[300],

                                    ),
                                    HeaderWidget(
                                      index: 10,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 100,
                                      color: Colors.lightGreen[300],

                                    ),
                                    HeaderWidget(
                                      index: 11,
                                      mainHeader: MainHeader,
                                      mainHeaderStyle: mainHeaderStyle,
                                      width: 180,
                                      color: Colors.lightGreen[300],

                                    ),
                                    
                                  ],
                                ),
                                SizedBox(
                                  height: 650,
                                  width: (60 * 8)+(80)+(180) + 40+(100*4),
                                  child: ListView.builder(
                                    scrollDirection:
                                        Axis.vertical, // Vertical scroll
                                    itemCount: transactionData.length,
                                    itemBuilder: (context, index) {
                                      final transaction = transactionData[index];
                                      var valid = transaction['is_valid'];
                                      return Row(
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            child: IconButton(
                                              onPressed: () {
                                                _showAlertDialog(transaction);
                                              },
                                              icon: const Icon(Icons.edit),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 60,
                                            child: Checkbox(
                                              value: valid,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  valid = value!;
                                                });
                                                updateValid(
                                                    transaction['entry_no'],
                                                    value!);
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                              width: 60,
                                              child: Text(
                                                '${transaction['entry_no']}',
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(
                                              width: 80,
                                              child: Text(
                                                '${transaction['date']}',
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(
                                              width: 60,
                                              child: Text(
                                                ' ${transaction['from_account_id']}',
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(
                                              width: 100,
                                              child: Text(
                                                ' ${transaction['from_account_title']}',
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              formatter.format(transaction['initial_amount']),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          SizedBox(
                                              width: 60,
                                              child: Text(
                                                ' ${transaction['from_currency']}',
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(
                                              width: 60,
                                              child: Text(
                                                ' ${transaction['multiply_by']}',
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(
                                              width: 60,
                                              child: Text(
                                                ' ${transaction['divide_by']}',
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(
                                              width: 100,
                                              child: Text(
                                                formatter.format(transaction['converted_amount']),
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(
                                              width: 60,
                                              child: Text(
                                                ' ${transaction['to_currency']}',
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(
                                              width: 60,
                                              child: Text(
                                                ' ${transaction['to_account_id']}',
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(
                                              width: 100,
                                              child: Text(
                                                ' ${transaction['to_account_title']}',
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(
                                              width: 180,
                                              child: Text(
                                                ' ${transaction['narration']}',
                                                textAlign: TextAlign.center,
                                              )),
                                          
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          } else {
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
        ));
  }

  List<String> MainHeader = [
    'V.R',
    'ACC 1',
    'Title',
    'Initial',
    'CUR 1',
    'Multiply',
    'Divide',
    'Converted',
    'CUR 2',
    'ACC 2',
    'Title',
    'Narration',
    'Edit',
    'Valid',
    'Date',
    ''
  ];

  TextStyle mainHeaderStyle =
      const TextStyle(fontSize: 13, fontWeight: FontWeight.bold);
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
