// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transaction_account/provider/user_provider.dart';

class ExcelGrid extends StatefulWidget {
  const ExcelGrid({
    Key? key,
  }) : super(key: key);

  @override
  State<ExcelGrid> createState() => _ExcelGridState();
}

class _ExcelGridState extends State<ExcelGrid> {
  NumberFormat formatter = NumberFormat.decimalPatternDigits(
    locale: 'en_us',
    decimalDigits: 2,
  );
  NumberFormat formatter2 = NumberFormat.decimalPatternDigits(
    locale: 'en_us',
    decimalDigits: 6,
  );
  int numberOfRows = 50;
  final List<String> _curOptions = ['MZN', 'USD', 'ZAR', 'EUR', 'AED'];
  final ScrollController _horizontal = ScrollController(),
      _vertical = ScrollController();
  final int numColumns = 14;
  bool isEditingTextField = false;
  Map<String, dynamic>? fetchedTitle1;
  Map<String, dynamic>? fetchedTitle2;
  Map<String, dynamic>? fetchedEntryNo;

  List<List<TextEditingController>> textControllers = [];

  List<List<FocusNode>> focusNodes = [];

  int selectedRow = 0;
  int selectedCol = 0;

  void _copyFromAbove() {
    if (selectedRow > 0) {
      int rowIndexAbove = selectedRow - 1;

      // first filled datacell
      while (rowIndexAbove >= 0) {
        if (textControllers[rowIndexAbove][selectedCol].text.isNotEmpty) {
          break;
        }
        rowIndexAbove--;
      }

      // copy its value
      if (rowIndexAbove >= 0) {
        final textToCopy = textControllers[rowIndexAbove][selectedCol].text;

        // Fill all null data cells above with the copied value
        for (int i = selectedRow; i >= 0; i--) {
          if (textControllers[i][selectedCol].text.isEmpty) {
            textControllers[i][selectedCol].text = textToCopy;
          } else {
            // non-empty cell encountered
            break;
          }
        }

        setState(() {});
      }
    }
  }

  void _deleteCellValue() {
    setState(() {
      textControllers[selectedRow][selectedCol].clear();
    });
  }

  void pasteColumnData() async {
    Clipboard.getData(Clipboard.kTextPlain).then((value) async {
      if (value != null && value.text != null) {
        List<String> rows = value.text!.split('\n');
        for (int i = selectedRow; i < selectedRow + rows.length; i++) {
          if (i >= numberOfRows) {
            break;
          }
          textControllers[i][selectedCol].text = rows[i - selectedRow].trim();
        }

        await Future.delayed(Duration.zero);
        textControllers[selectedRow][selectedCol].clear();
        textControllers[selectedRow][selectedCol].text = rows[0].trim();
      }
    });
    setState(() {});
  }

  void _moveFocusDown() {
    if (selectedRow < numberOfRows - 1) {
      setState(() {
        selectedRow++;
      });
      _setFocus(selectedRow, selectedCol);
    }
  }

  void _moveFocusUp() {
    if (selectedRow > 0) {
      setState(() {
        selectedRow--;
      });
      _setFocus(selectedRow, selectedCol);
    }
  }

  void _moveFocusRight() {
    if (selectedCol < numColumns - 1) {
      setState(() {
        selectedCol++;
      });
    } else if (selectedCol == 13) {
      setState(() {
        selectedCol = 0;
        selectedRow++;
      });
    }
    _setFocus(selectedRow, selectedCol);
  }

  void _moveFocusLeft() {
    if (selectedCol > 0) {
      setState(() {
        selectedCol--;
      });
      _setFocus(selectedRow, selectedCol);
    }
  }

  void _setFocus(int row, int col) {
    focusNodes[row][col].requestFocus();
  }

  Future<Map<String, dynamic>>? fetchData(String accountNumber) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final headers = {
      'Authorization': 'Token ${userProvider.user.token}',
    };

    final url = Uri.parse(
        'http://127.0.0.1:8000/api/transactions/v1/account/$accountNumber/');

    final res = await http.get(url, headers: headers);
    final responseBody = json.decode(res.body);

    return responseBody;
  }

  void postTransaction(int rowIndex) async {
    List<String> dateParts = textControllers[rowIndex][1].text.split('-');

    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);

    textControllers[rowIndex][5].text = formatter
        .format(double.parse(textControllers[rowIndex][5].text))
        .replaceAll(',', '');

    textControllers[rowIndex][11].text = formatter
        .format(double.parse(textControllers[rowIndex][11].text))
        .replaceAll(',', '');

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final headers = {
      'Authorization': 'Token ${userProvider.user.token}',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final url = Uri.parse('http://127.0.0.1:8000/api/transactions/v1/create/');

    final res = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "entry_no": int.parse(textControllers[rowIndex][0].text),
        "date": '$year-$month-$day',
        "multiply_by": textControllers[rowIndex][6].text.isEmpty
            ? 1
            : double.parse(textControllers[rowIndex][6].text),
        "from_currency": textControllers[rowIndex][4].text,
        "to_currency": textControllers[rowIndex][10].text,
        "initial_amount": double.parse(textControllers[rowIndex][5].text),
        "converted_amount": double.parse(textControllers[rowIndex][11].text),
        "divide_by": textControllers[rowIndex][7].text.isEmpty
            ? 1
            : double.parse(textControllers[rowIndex][7].text),
        "from_account": int.parse(textControllers[rowIndex][2].text),
        "to_account": int.parse(textControllers[rowIndex][8].text),
        "narration": textControllers[rowIndex][12].text
      }),
    );

    final status = res.statusCode;
    if (status == 200) {
      jsonDecode(res.body)['data'] is String
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(jsonDecode(res.body)['data'].toString().toUpperCase()),
              ),
            )
          : ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Transaction Saved Sucessfully"),
              ),
            );
      textControllers[rowIndex][5].text =
          formatter.format(double.parse(textControllers[rowIndex][5].text));
      textControllers[rowIndex][11].text =
          '(${formatter.format(double.parse(textControllers[rowIndex][11].text))})';
      if (textControllers[rowIndex][6].text.isNotEmpty) {
        textControllers[rowIndex][6].text =
            formatter2.format(double.parse(textControllers[rowIndex][6].text));
      }
      if (textControllers[rowIndex][7].text.isNotEmpty) {
        textControllers[rowIndex][7].text =
            formatter2.format(double.parse(textControllers[rowIndex][7].text));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Transaction Invalid",
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.red[900]),
        ),
      ));
      textControllers[rowIndex][11].clear();
    }
  }

  fetchEntryNo() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final headers = {
      'Authorization': 'Token ${userProvider.user.token}',
    };

    final url =
        Uri.parse('http://127.0.0.1:8000/api/transactions/v1/entry-no/');

    final res = await http.get(url, headers: headers);
    final responseBody = json.decode(res.body);
    setState(() {
      fetchedEntryNo = responseBody;
    });
  }

  Future<void> _showAlertDialog() {
    TextEditingController searchController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search'),
          content: TextFormField(
            autofocus: true,
            controller: searchController,
            decoration: const InputDecoration(labelText: 'Search'),
            onFieldSubmitted: (value) {
              if (value == '') {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop();
                for (int i = 0; i < numberOfRows; i++) {
                  if (textControllers[i][5].text.contains(value)) {
                    setState(() {
                      selectedRow = i;
                      selectedCol = 5;
                    });
                    _setFocus(selectedRow, selectedCol);
                    break;
                  } else if (textControllers[i][11].text.contains(value)) {
                    setState(() {
                      selectedRow = i;
                      selectedCol = 11;
                    });
                    _setFocus(selectedRow, selectedCol);
                    break;
                  } else if (textControllers[i][12].text.contains(value)) {
                    setState(() {
                      selectedRow = i;
                      selectedCol = 12;
                    });
                    _setFocus(selectedRow, selectedCol);
                    break;
                  }
                }
              }
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < numberOfRows; i++) {
      focusNodes.add(List.generate(
        numColumns,
        (index) => FocusNode(),
      ));

      textControllers.add(List.generate(
        numColumns - 1,
        (index) => TextEditingController(),
      ));
    }

    fetchEntryNo();

    RawKeyboard.instance.addListener((event) async {
      if (event is RawKeyDownEvent) {
        if (event.isControlPressed &&
            event.logicalKey == LogicalKeyboardKey.keyD) {
          // Handle Ctrl+D
          _copyFromAbove();
        } else if (event.isControlPressed &&
            event.logicalKey == LogicalKeyboardKey.keyF) {
          // Handle Ctrl+F
          _showAlertDialog();
        } else if (event.isControlPressed &&
            event.logicalKey == LogicalKeyboardKey.keyV) {
          pasteColumnData();
        } else if (event.logicalKey == LogicalKeyboardKey.delete) {
          // Handle Delete key
          _deleteCellValue();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          // Handle arrow down key press
          _moveFocusDown();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          // Handle arrow up key press
          _moveFocusUp();
        } else if (isEditingTextField == false &&
            event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _moveFocusRight();
        } else if (isEditingTextField == false &&
            event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          // Handle arrow left key press
          _moveFocusLeft();
        } else if (event.logicalKey == LogicalKeyboardKey.tab) {
          await Future.delayed(Duration.zero);
          _moveFocusRight();

          if (textControllers[selectedRow][2].text.isNotEmpty &&
              textControllers[selectedRow][3].text.isEmpty) {
            fetchedTitle1 =
                await fetchData(textControllers[selectedRow][2].text);

            setState(() {
              isEditingTextField = false; // Indicate that editing is complete

              var dataEntry = fetchedTitle1?["data"];

              dataEntry == null
                  ? ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Account Does Not Exist"),
                      ),
                    )
                  : textControllers[selectedRow][3].text = dataEntry["title"];
            });
          }
          if (textControllers[selectedRow][8].text.isNotEmpty &&
              textControllers[selectedRow][9].text.isEmpty) {
            fetchedTitle2 =
                await fetchData(textControllers[selectedRow][8].text);

            setState(() {
              isEditingTextField = false; // Indicate that editing is complete

              var dataEntry = fetchedTitle2?["data"];

              dataEntry == null
                  ? ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Account Does Not Exist"),
                      ),
                    )
                  : textControllers[selectedRow][9].text = dataEntry["title"];
            });
          }
        } else if (event.logicalKey == LogicalKeyboardKey.f2) {
          // Handle Enter key press (indicate editing is complete)
          setState(() {
            isEditingTextField = true; // Indicate that editing is complete
          });
        } else if (event.logicalKey == LogicalKeyboardKey.escape) {
          setState(() {
            isEditingTextField = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose of text controllers
    for (var row in textControllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  List<String> MainHeader = [
    // 'Approval',
    'Document',
    'Document',
    'Account 1',
    'X Rate ',
    'Account 2',
    'NARRATION',
    'Narration',
    ''
  ];

  TextStyle mainHeaderStyle =
      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('TRANSACTIONS'),
      ),
      body: fetchedEntryNo == null
          ? const CircularProgressIndicator()
          : Scrollbar(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // HeaderWidget(
                            //   index: 0,
                            //   mainHeader: MainHeader,
                            //   mainHeaderStyle: mainHeaderStyle,
                            //   width: 79,
                            //   color: const Color.fromARGB(255, 93, 243, 33),
                            // ),
                            HeaderWidget(
                              index: 1,
                              mainHeader: MainHeader,
                              mainHeaderStyle: mainHeaderStyle,
                              width: (77 + 90),
                              color: Colors.lightGreen[100],
                            ),
                            HeaderWidget(
                              index: 2,
                              mainHeader: MainHeader,
                              mainHeaderStyle: mainHeaderStyle,
                              width: (35 + 70 + 196 + 145),
                              color: Colors.lightGreen[300],
                            ),
                            HeaderWidget(
                              index: 3,
                              mainHeader: MainHeader,
                              mainHeaderStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue),
                              width: (92 + 92),
                              color: Colors.lightGreen[100],
                            ),
                            HeaderWidget(
                              index: 4,
                              mainHeader: MainHeader,
                              mainHeaderStyle: mainHeaderStyle,
                              width: (35 + 70 + 196 + 145),
                              color: Colors.lightGreen[300],
                            ),
                            // HeaderWidget(
                            //   index: 5,
                            //   mainHeader: MainHeader,
                            //   mainHeaderStyle: mainHeaderStyle,
                            //   width: (86 + 79),
                            //   color: const Color.fromARGB(255, 240, 33, 195),
                            // ),
                            HeaderWidget(
                              index: 6,
                              mainHeader: MainHeader,
                              mainHeaderStyle: mainHeaderStyle,
                              width: 482,
                              color: Colors.lightGreen[100],
                            ),
                            HeaderWidget(
                              index: 7,
                              mainHeader: MainHeader,
                              mainHeaderStyle: mainHeaderStyle,
                              width: 77,
                              color: Colors.lightGreen[300],
                            ),
                          ],
                        ),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.white),
                          child: DataTable(
                            columnSpacing: 0,
                            horizontalMargin: 0,
                            dataRowMaxHeight: 20,
                            dataRowMinHeight: 20,
                            headingRowHeight: 20,
                            dividerThickness: 0.01,
                            columns: [
                              // DataColumn(label: Text(' No.')),

                              DataColumn(
                                  label: Container(
                                      width: 77,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[300]),
                                      child: const Text(
                                        ' No.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))),
                              DataColumn(
                                  label: Container(
                                      width: 90,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[100]),
                                      child: const Text(
                                        ' Date',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))),
                              DataColumn(
                                  label: Container(
                                      width: 70,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[300]),
                                      child: const Text(
                                        ' No.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))),
                              DataColumn(
                                  label: Container(
                                      width: 196,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[100]),
                                      child: const Text(
                                        ' Title',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))),
                              DataColumn(
                                  label: Container(
                                      width: 35,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[300]),
                                      child: const Text(
                                        ' Cur',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))),
                              DataColumn(
                                  label: Container(
                                      width: 145,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[100]),
                                      child: const Text(
                                        ' Amount',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))),
                              DataColumn(
                                  label: Container(
                                      width: 92,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[300]),
                                      child: const Text(
                                        ' Multiply',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.lightBlue),
                                      ))),
                              DataColumn(
                                  label: Container(
                                      width: 92,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[100]),
                                      child: const Text(
                                        ' Divide',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.lightBlue),
                                      ))),
                              DataColumn(
                                  label: Container(
                                      width: 70,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[300]),
                                      child: const Text(
                                        ' No.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))),
                              DataColumn(
                                  label: Container(
                                      width: 196,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[100]),
                                      child: const Text(
                                        ' Title',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))),
                              DataColumn(
                                  label: Container(
                                      width: 35,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[300]),
                                      child: const Text(
                                        ' Cur',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))),
                              DataColumn(
                                  label: Container(
                                      width: 145,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[100]),
                                      child: const Text(
                                        ' Amount',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))),
                              // DataColumn(label: Text(' No.')),
                              // DataColumn(label: Text(' Dated')),
                              DataColumn(
                                  label: Container(
                                      width: 482,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[300]),
                                      child: const Text(''))),
                              DataColumn(
                                  label: Container(
                                      width: 77,
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen[100]),
                                      child: const Text(''))),
                            ],
                            rows: List.generate(numberOfRows, (rowIndex) {
                              //bool isSelected = rowIndex == selectedRow;

                              textControllers[rowIndex][0].text =
                                  (fetchedEntryNo?['data']['entry_no'] +
                                          rowIndex +
                                          1)
                                      .toString();

                              return DataRow(cells: [
                                // DataCell(Container(
                                //   width: 79,
                                //   child: TextFormField(
                                //     decoration: const InputDecoration(
                                //       isDense: true,
                                //     ),
                                //     controller: textControllers[rowIndex][0],
                                //     focusNode: focusNodes[rowIndex][0],
                                //     // enabled: false,
                                //     autofocus: true,
                                //     onTap: () {
                                //       setState(() {
                                //         selectedRow = rowIndex;
                                //         selectedCol = 0;
                                //         // isEditingTextField = true; // Indicates active editing
                                //       });
                                //     },
                                //     onFieldSubmitted: (value) {
                                //       setState(() {
                                //         isEditingTextField =
                                //         false; // Indicate that editing is complete
                                //         print(isEditingTextField);
                                //         print(value);
                                //         fetchData();
                                //       });
                                //       _moveFocusDown();
                                //     },
                                //     style: const TextStyle(fontSize: 12),
                                //   ),
                                // )),
                                DataCell(SizedBox(
                                  width: 77,
                                  child: TextFormField(
                                    autofocus: true,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(),
                                        isDense: true,
                                        border: InputBorder.none),
                                    controller: textControllers[rowIndex][0],
                                    focusNode: focusNodes[rowIndex][0],

                                    onTap: () {
                                      setState(() {
                                        selectedRow = rowIndex;
                                        selectedCol = 0;
                                      });
                                    },

                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                    // initialValue: rowIndex == 0 ? (fetchedData != null ? '${fetchedData['data'][0]['title']}' : '') : '',
                                  ),
                                )),
                                DataCell(Container(
                                  width: 90,
                                  decoration: BoxDecoration(
                                      color: Colors.lightGreen[200]),
                                  child: TextFormField(
                                      controller: textControllers[rowIndex][1],
                                      focusNode: focusNodes[rowIndex][1],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        focusedBorder: OutlineInputBorder(),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          selectedRow = rowIndex;
                                          selectedCol = 1;
                                        });
                                      },
                                      onFieldSubmitted: (value) async {
                                        List<String> dateParts =
                                            value.split('-');
                                        if (dateParts.length != 3 ||
                                            double.tryParse(value.replaceAll(
                                                    '-', '')) ==
                                                null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Invalid date format. Use day-month-year.'),
                                            ),
                                          );
                                          textControllers[rowIndex][1].clear();
                                        } else {
                                          int day = int.parse(dateParts[0]);
                                          int month = int.parse(dateParts[1]);
                                          int year = int.parse(dateParts[2]);

                                          DateTime inputDateTime =
                                              DateTime(year, month, day);

                                          // Get the current date
                                          DateTime currentDate = DateTime.now();

                                          // Calculate the difference in days between the input date and the current date
                                          int differenceInDays = inputDateTime
                                              .difference(currentDate)
                                              .inDays;

                                          if ((differenceInDays >= -5) &&
                                              (differenceInDays <= 5)) {
                                            setState(() {
                                              isEditingTextField =
                                                  false; // Indicate that editing is complete
                                            });
                                            _moveFocusDown();
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Invalid date. Date Difference more than 5 days'),
                                              ),
                                            );
                                            textControllers[rowIndex][1]
                                                .clear();
                                          }
                                        }
                                      }),
                                )),
                                DataCell(
                                  SizedBox(
                                    width: 70,
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(),
                                        isDense: true,
                                        border: InputBorder.none,
                                      ),
                                      textAlign: TextAlign.right,
                                      controller: textControllers[rowIndex][2],
                                      focusNode: focusNodes[rowIndex][2],
                                      style: const TextStyle(fontSize: 12),
                                      onTap: () {
                                        setState(() {
                                          selectedRow = rowIndex;
                                          selectedCol = 2;
                                        });
                                      },
                                      onFieldSubmitted: (value) async {
                                        fetchedTitle1 = await fetchData(value);

                                        setState(() {
                                          isEditingTextField =
                                              false; // Indicate that editing is complete

                                          var dataEntry =
                                              fetchedTitle1?["data"];

                                          dataEntry == null
                                              ? ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Account Does Not Exist"),
                                                  ),
                                                )
                                              : textControllers[selectedRow][3]
                                                  .text = dataEntry["title"];
                                        });
                                        _moveFocusDown();
                                      },
                                    ),
                                  ),
                                ),
                                DataCell(Center(
                                  child: SizedBox(
                                    width: 196,
                                    child: TextFormField(
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        focusedBorder: OutlineInputBorder(),
                                        border: InputBorder.none,
                                      ),
                                      controller: textControllers[rowIndex][3],
                                      focusNode: focusNodes[rowIndex][3],
                                      style: const TextStyle(fontSize: 12),
                                      onTap: () {
                                        setState(() {
                                          selectedRow = rowIndex;
                                          selectedCol = 3;
                                        });
                                      },
                                      onFieldSubmitted: (value) {
                                        setState(() {
                                          isEditingTextField =
                                              false; // Indicate that editing is complete
                                        });
                                        _moveFocusDown();
                                      },
                                    ),
                                  ),
                                )),
                                DataCell(
                                  Container(
                                    width: 35,
                                    decoration: BoxDecoration(
                                        color: textControllers[rowIndex][4]
                                                    .text ==
                                                'MZN'
                                            ? Colors.yellow
                                            : textControllers[rowIndex][4]
                                                        .text ==
                                                    'AED'
                                                ? Colors.orange[900]
                                                : textControllers[rowIndex][4]
                                                            .text ==
                                                        'USD'
                                                    ? Colors.red[200]
                                                    : textControllers[rowIndex]
                                                                    [4]
                                                                .text ==
                                                            'ZAR'
                                                        ? Colors.green[700]
                                                        : textControllers[rowIndex]
                                                                        [4]
                                                                    .text ==
                                                                'EUR'
                                                            ? Colors.lightBlue
                                                            : Colors
                                                                .transparent),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        focusedBorder: OutlineInputBorder(),
                                        border: InputBorder.none,
                                      ),
                                      textAlign: TextAlign.center,
                                      controller: textControllers[rowIndex][4],
                                      focusNode: focusNodes[rowIndex][4],
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          selectedRow = rowIndex;
                                          selectedCol = 4;
                                        });
                                      },
                                      onChanged: (value) {
                                        var match = false;
                                        if (value != '') {
                                          for (int i = 0;
                                              i < _curOptions.length;
                                              i++) {
                                            if (value ==
                                                _curOptions[i]
                                                    .substring(0, 1)) {
                                              match = true;
                                              setState(() {
                                                textControllers[rowIndex][4]
                                                        .text =
                                                    _curOptions[i].toString();
                                              });
                                              break;
                                            }
                                          }
                                          if (match == false) {
                                            textControllers[rowIndex][4]
                                                .clear();
                                          }
                                        }
                                      },
                                      onFieldSubmitted: (value) {
                                        setState(() {
                                          isEditingTextField =
                                              false; // Indicate that editing is complete
                                        });
                                        _moveFocusDown();
                                      },
                                    ),
                                  ),
                                ),
                                DataCell(SizedBox(
                                  width: 145,
                                  child: TextFormField(
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      focusedBorder: OutlineInputBorder(),
                                      isDense: true,
                                      border: InputBorder.none,
                                    ),
                                    controller: textControllers[rowIndex][5],
                                    focusNode: focusNodes[rowIndex][5],
                                    onTap: () {
                                      setState(() {
                                        selectedRow = rowIndex;
                                        selectedCol = 5;
                                      });
                                    },
                                    onFieldSubmitted: (value) {
                                      setState(() {
                                        isEditingTextField =
                                            false; // Indicate that editing is complete
                                      });
                                      _moveFocusDown();
                                    },
                                    onChanged: (value) {
                                      if (double.tryParse(value) == null) {
                                        textControllers[rowIndex][5].clear();
                                      }
                                    },
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                )),
                                DataCell(SizedBox(
                                  width: 92,
                                  child: TextFormField(
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(),
                                        isDense: true,
                                        border: InputBorder.none),
                                    controller: textControllers[rowIndex][6],
                                    focusNode: focusNodes[rowIndex][6],
                                    onTap: () {
                                      setState(() {
                                        selectedRow = rowIndex;
                                        selectedCol = 6;
                                      });
                                    },
                                    onFieldSubmitted: (value) {
                                      setState(() {
                                        isEditingTextField =
                                            false; // Indicate that editing is complete
                                      });
                                      _moveFocusDown();
                                    },
                                    onChanged: (value) {
                                      if (double.tryParse(value) == null) {
                                        textControllers[rowIndex][6].clear();
                                      }
                                    },
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.lightBlue),
                                  ),
                                )),
                                DataCell(SizedBox(
                                  width: 92,
                                  child: TextFormField(
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(),
                                        isDense: true,
                                        border: InputBorder.none),
                                    controller: textControllers[rowIndex][7],
                                    focusNode: focusNodes[rowIndex][7],
                                    onTap: () {
                                      setState(() {
                                        selectedRow = rowIndex;
                                        selectedCol = 7;
                                      });
                                    },
                                    onChanged: (value) {
                                      if (double.tryParse(value) == null) {
                                        textControllers[rowIndex][7].clear();
                                      }
                                    },
                                    onFieldSubmitted: (value) {
                                      setState(() {
                                        isEditingTextField =
                                            false; // Indicate that editing is complete
                                      });
                                      _moveFocusDown();
                                    },
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.lightBlue),
                                  ),
                                )),
                                DataCell(
                                  SizedBox(
                                    width: 70,
                                    child: TextFormField(
                                      textAlign: TextAlign.right,
                                      decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                      controller: textControllers[rowIndex][8],
                                      focusNode: focusNodes[rowIndex][8],
                                      style: const TextStyle(fontSize: 12),
                                      onTap: () {
                                        setState(() {
                                          selectedRow = rowIndex;
                                          selectedCol = 8;
                                        });
                                      },
                                      onFieldSubmitted: (value) async {
                                        fetchedTitle2 = await fetchData(value);

                                        setState(() {
                                          isEditingTextField =
                                              false; // Indicate that editing is complete

                                          var dataEntry =
                                              fetchedTitle2?["data"];

                                          dataEntry == null
                                              ? ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Account Does Not Exist"),
                                                  ),
                                                )
                                              : textControllers[selectedRow][9]
                                                  .text = dataEntry["title"];
                                        });
                                        _moveFocusDown();
                                      },
                                    ),
                                  ),
                                ),
                                DataCell(SizedBox(
                                  width: 196,
                                  child: TextFormField(
                                    //enabled: false,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(),
                                        isDense: true,
                                        border: InputBorder.none),
                                    controller: textControllers[rowIndex][9],
                                    focusNode: focusNodes[rowIndex][9],
                                    onTap: () {
                                      setState(() {
                                        selectedRow = rowIndex;
                                        selectedCol = 9;
                                      });
                                    },
                                    onFieldSubmitted: (value) {
                                      setState(() {
                                        isEditingTextField =
                                            false; // Indicate that editing is complete
                                      });
                                      _moveFocusDown();
                                    },
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                )),
                                DataCell(
                                  Container(
                                    width: 35,
                                    decoration: BoxDecoration(
                                        color: textControllers[rowIndex][10]
                                                    .text ==
                                                'MZN'
                                            ? Colors.yellow
                                            : textControllers[rowIndex][10]
                                                        .text ==
                                                    'AED'
                                                ? Colors.orange[900]
                                                : textControllers[rowIndex][10]
                                                            .text ==
                                                        'USD'
                                                    ? Colors.red[200]
                                                    : textControllers[rowIndex]
                                                                    [10]
                                                                .text ==
                                                            'ZAR'
                                                        ? Colors.green[700]
                                                        : textControllers[rowIndex]
                                                                        [10]
                                                                    .text ==
                                                                'EUR'
                                                            ? Colors.lightBlue
                                                            : Colors
                                                                .transparent),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                          focusedBorder: OutlineInputBorder(),
                                          isDense: true,
                                          border: InputBorder.none),
                                      textAlign: TextAlign.center,
                                      controller: textControllers[rowIndex][10],
                                      focusNode: focusNodes[rowIndex][10],
                                      style: const TextStyle(fontSize: 12),
                                      onTap: () {
                                        setState(() {
                                          selectedRow = rowIndex;
                                          selectedCol = 10;
                                        });
                                      },
                                      onChanged: (value) {
                                        var match = false;
                                        if (value != '') {
                                          for (int i = 0;
                                              i < _curOptions.length;
                                              i++) {
                                            if (value ==
                                                _curOptions[i]
                                                    .substring(0, 1)) {
                                              match = true;
                                              setState(() {
                                                textControllers[rowIndex][10]
                                                        .text =
                                                    _curOptions[i].toString();
                                              });
                                              break;
                                            }
                                          }
                                          if (match == false) {
                                            textControllers[rowIndex][10]
                                                .clear();
                                          }
                                        }
                                      },
                                      onFieldSubmitted: (value) {
                                        setState(() {
                                          isEditingTextField =
                                              false; // Indicate that editing is complete
                                        });
                                        _moveFocusDown();
                                      },
                                    ),
                                  ),
                                ),
                                DataCell(SizedBox(
                                  width: 145,
                                  child: TextFormField(
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(),
                                        isDense: true,
                                        border: InputBorder.none),
                                    controller: textControllers[rowIndex][11],
                                    focusNode: focusNodes[rowIndex][11],
                                    onTap: () {
                                      setState(() {
                                        selectedRow = rowIndex;
                                        selectedCol = 11;
                                      });
                                    },
                                    onFieldSubmitted: (value) {
                                      setState(() {
                                        isEditingTextField =
                                            false; // Indicate that editing is complete
                                      });
                                      _moveFocusDown();
                                    },
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                )),
                                // DataCell(Container(
                                //   width: 86,
                                //   child: TextFormField(
                                //     decoration: const InputDecoration(
                                //       isDense: true,
                                //     ),
                                //     controller: textControllers[rowIndex][13],
                                //     focusNode: focusNodes[rowIndex][13],
                                //     onTap: () {
                                //       setState(() {
                                //         selectedRow = rowIndex;
                                //         selectedCol = 13;
                                //       });
                                //     },
                                //     onFieldSubmitted: (value) {
                                //       setState(() {
                                //         isEditingTextField =
                                //         false; // Indicate that editing is complete
                                //         print(isEditingTextField);
                                //       });
                                //       _moveFocusDown();
                                //     },
                                //     style: const TextStyle(fontSize: 12),
                                //   ),
                                // )),
                                // DataCell(Container(
                                //   width: 79,
                                //   child: TextFormField(
                                //     controller: textControllers[rowIndex][14],
                                //     focusNode: focusNodes[rowIndex][14],
                                //     style: const TextStyle(fontSize: 12),
                                //     decoration: const InputDecoration(
                                //         suffixIcon: Icon(
                                //           Icons.calendar_today,
                                //           size: 10,
                                //         ),
                                //         isDense: true
                                //       // labelText: "Date",
                                //     ),
                                //     readOnly: true,
                                //     onTap: () async {
                                //       DateTime? pickedDate = await showDatePicker(
                                //           context: context,
                                //           initialDate: DateTime.now(),
                                //           //get today's date
                                //           firstDate: DateTime(2023),
                                //           //DateTime.now() - not to allow to choose before today.
                                //           lastDate: DateTime(2101));
                                //       if (pickedDate != null) {
                                //         String formattedDate =
                                //         DateFormat.yMd().format(pickedDate);
                                //         setState(() {
                                //           textControllers[rowIndex][14].text =
                                //               formattedDate.toString();
                                //         });
                                //       } else {
                                //         print("not selected");
                                //       }
                                //     },
                                //     onFieldSubmitted: (value) {
                                //       setState(() {
                                //         isEditingTextField =
                                //         false; // Indicate that editing is complete
                                //         print(isEditingTextField);
                                //       });
                                //       _moveFocusDown();
                                //     },
                                //   ),
                                // )),
                                DataCell(SizedBox(
                                  width: 482,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(),
                                        isDense: true,
                                        border: InputBorder.none),
                                    controller: textControllers[rowIndex][12],
                                    focusNode: focusNodes[rowIndex][12],
                                    onTap: () {
                                      setState(() {
                                        selectedRow = rowIndex;
                                        selectedCol = 12;
                                      });
                                    },
                                    onFieldSubmitted: (value) {
                                      setState(() {
                                        isEditingTextField =
                                            false; // Indicate that editing is complete
                                      });
                                      var empty = false;
                                      var pass = false;

                                      for (int col = 0; col <= 5; col++) {
                                        if (textControllers[rowIndex][col]
                                            .text
                                            .isEmpty) {
                                          empty = true;
                                          break;
                                        }
                                      }
                                      for (int col = 8; col <= 10; col++) {
                                        if (textControllers[rowIndex][col]
                                            .text
                                            .isEmpty) {
                                          empty = true;
                                          break;
                                        }
                                      }
                                      if (textControllers[rowIndex][12]
                                          .text
                                          .isEmpty) {
                                        empty = true;
                                      }
                                      if (textControllers[rowIndex][6]
                                              .text
                                              .isEmpty &&
                                          textControllers[rowIndex][7]
                                              .text
                                              .isEmpty) {
                                        empty = true;
                                      }
                                      if (empty == true) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text("Please fill all fields"),
                                          ),
                                        );
                                      } else {
                                        // textControllers[rowIndex][5].text = formatter.format(double.parse(textControllers[rowIndex][5].text));
                                        textControllers[rowIndex][5].text =
                                            textControllers[rowIndex][5]
                                                .text
                                                .replaceAll(',', '');

                                        // formatter.format()

                                        if (textControllers[rowIndex][6]
                                                .text
                                                .isNotEmpty &&
                                            textControllers[rowIndex][7]
                                                .text
                                                .isNotEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Please fill either Multiply or Divide"),
                                            ),
                                          );
                                        } else if (textControllers[rowIndex][6]
                                                .text
                                                .isEmpty &&
                                            textControllers[rowIndex][7]
                                                .text
                                                .isNotEmpty) {
                                          textControllers[rowIndex][7].text =
                                              textControllers[rowIndex][7]
                                                  .text
                                                  .replaceAll(',', '');
                                          textControllers[rowIndex][11]
                                              .text = (double.parse(
                                                      textControllers[rowIndex]
                                                              [5]
                                                          .text) /
                                                  double.parse(
                                                      textControllers[rowIndex]
                                                              [7]
                                                          .text))
                                              .toString();
                                          if (double.parse(
                                                  textControllers[rowIndex][7]
                                                      .text) ==
                                              1) {
                                            textControllers[rowIndex][10].text =
                                                textControllers[rowIndex][4]
                                                    .text;
                                          }
                                          pass = true;
                                        } else if (textControllers[rowIndex][7]
                                                .text
                                                .isEmpty &&
                                            textControllers[rowIndex][6]
                                                .text
                                                .isNotEmpty) {
                                          textControllers[rowIndex][6].text =
                                              textControllers[rowIndex][6]
                                                  .text
                                                  .replaceAll(',', '');
                                          textControllers[rowIndex][11]
                                              .text = (double.parse(
                                                      textControllers[rowIndex]
                                                              [5]
                                                          .text) *
                                                  double.parse(
                                                      textControllers[rowIndex]
                                                              [6]
                                                          .text))
                                              .toString();
                                          if (double.parse(
                                                  textControllers[rowIndex][6]
                                                      .text) ==
                                              1) {
                                            textControllers[rowIndex][10].text =
                                                textControllers[rowIndex][4]
                                                    .text;
                                          }
                                          pass = true;
                                        }

                                        if (pass == true) {
                                          postTransaction(rowIndex);
                                        }
                                      }
                                      _moveFocusDown();
                                    },
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                )),
                                DataCell(SizedBox(
                                  width: 77,
                                  child: TextFormField(
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(),
                                        isDense: true,
                                        border: InputBorder.none),
                                    focusNode: focusNodes[rowIndex][13],
                                    onTap: () {
                                      setState(() {
                                        selectedRow = rowIndex;
                                        selectedCol = 13;
                                      });
                                    },
                                    onFieldSubmitted: (value) {
                                      setState(() {
                                        isEditingTextField =
                                            false; // Indicate that editing is complete
                                      });
                                      _moveFocusDown();
                                    },
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                )),
                              ]);
                            }),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
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
