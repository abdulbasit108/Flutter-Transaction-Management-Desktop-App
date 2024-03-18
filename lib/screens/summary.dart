import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transaction_account/provider/user_provider.dart';

class Summary extends StatefulWidget {
  const Summary({
    Key? key,
  }) : super(key: key);

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  NumberFormat formatter = NumberFormat.decimalPatternDigits(
    locale: 'en_us',
    decimalDigits: 2,
  );
  List<Map<String, dynamic>> dataList = [];
  final int numberOfRows = 300;

  final ScrollController _horizontal = ScrollController(),
      _vertical = ScrollController();
  TextEditingController searchController = TextEditingController();
  final int numColumns = 9;
  final int topColumns = 18;

  // Map<String, dynamic> fetchData = {};

  // List<List<TextEditingController>> textControllers = [];
  int selectedRow = 0;
  int selectedCol = 0;

  @override
  void initState() {
    super.initState();
    // Initialize textControllers for each cell
    // for (int i = 0; i < numberOfRows; i++) {
    //   textControllers.add(List.generate(
    //     topColumns,
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

  Future<Map<String, dynamic>> fetchedSummary() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final headers = {
      'Authorization': 'Token ${userProvider.user.token}',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var data = json.encode({"export": false});
    var dio = Dio();
    var response = await dio.request(
      'http://127.0.0.1:8000/api/transactions/v1/summary/',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(response.statusMessage);
    }
  }

  void exportData(bool export) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token 5390986194e7eeab7889386a57e061cd789528c2'
    };
    var data = json.encode({"export": true});
    var dio = Dio();
    var response = await dio.request(
      'http://127.0.0.1:8000/api/transactions/v1/summary/',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('SUMMARY'),
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
                      FutureBuilder<Map<String, dynamic>?>(
                        future: fetchedSummary(),
                        builder: (context, accountSnapshot) {
                          if (accountSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (accountSnapshot.hasError) {
                            return Text('Error: ${accountSnapshot.error}');
                          } else if (accountSnapshot.data != null) {
                            // Check if data is not null
                            // final accountData = accountSnapshot.data!['data']['account'];
                            // final transactionData = accountSnapshot.data!['data']['transactions'];
                            final debitData = accountSnapshot.data!['data'];

                            return Column(
                              children: [
                                Center(
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 250,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Handle button tap here, make API call
                                            exportData(
                                                true); // A function to make the API call
                                          },
                                          child: const Text(
                                            "EXPORT\n(Update Opening/Closing)",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      SizedBox(
                                        height: 10000,
                                        width: 1300,
                                        child: ListView.builder(
                                          itemCount: debitData != null
                                              ? debitData.length
                                              : 0,
                                          itemBuilder: (context, index) {
                                            final account = debitData[index];
                                            final debitCredit =
                                                account['debit_credit'];
                                            final title =
                                                account['account']['title'];
                                            final id = account['account']['id'];

                                            List<Widget> currencyWidgets = [];

                                            if (debitCredit != null &&
                                                debitCredit.isNotEmpty) {
                                              currencyWidgets.add(
                                                const SizedBox(
                                                    height:
                                                        10), // Add some vertical gap
                                              );

                                              currencyWidgets.add(
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.black,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                    color: Colors.lightGreen[
                                                        300], // Set a background color for the account border
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Account No: $id\nAccount Title: $title",
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );

                                              debitCredit
                                                  .forEach((currency, data) {
                                                currencyWidgets.add(
                                                  const SizedBox(
                                                      height:
                                                          10), // Add some vertical gap
                                                );

                                                currencyWidgets.add(
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.green,
                                                          // Set a different color for the border
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    8.0)),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '$currency',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color: Colors
                                                                  .green, // Set a different color for the currency text
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 145.0,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Text(
                                                                      "Opening: ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w900,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      formatter
                                                                          .format(
                                                                              data['opening']),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 145.0,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Text(
                                                                      "Closing: ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w900,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      formatter
                                                                          .format(
                                                                              data['closing']),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 145.0,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Text(
                                                                      "Debit: ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w900,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      formatter
                                                                          .format(
                                                                              data['debit']),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 145.0,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Text(
                                                                      "Credit: ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w900,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      '(${formatter.format(data['credit'])})',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                            }

                                            return Column(
                                              children: currencyWidgets,
                                            );
                                          },
                                        ),
                                      )
                                    ],
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
    'OPENING BALANCE',
    'TRANSACTION',
    'CLOSING BALANCE',
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
  'USD',
  'MZN',
  'ZAR',
  'EUR',
  'AED',
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
