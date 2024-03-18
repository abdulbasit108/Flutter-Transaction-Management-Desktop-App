// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';


import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:transaction_account/provider/user_provider.dart';

class Accounts extends StatefulWidget {
  const Accounts({
    Key? key,
  }) : super(key: key);

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  List<Map<String, dynamic>> dataList = [];
  

  final ScrollController _horizontal = ScrollController(),
      _vertical = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchedData();
  }

  @override
  void dispose() {
    // Dispose of text controllers

    super.dispose();
  }

  Future<Map<String, dynamic>> fetchedData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final headers = {
      'Authorization': 'Token ${userProvider.user.token}',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    // Construct the dynamic URL with the provided date parameter
    var apiUrl = 'http://127.0.0.1:8000/api/transactions/v1/account/all/';

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

  void createAccount(Object data) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final headers = {
      'Authorization': 'Token ${userProvider.user.token}',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final url =
        Uri.parse('http://127.0.0.1:8000/api/transactions/v1/account/create/');

    final res = await http.post(url, headers: headers, body: data);

    final status = res.statusCode;

    status == 200
        ? setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Account Created Sucessfully"),
              ),
            );
          })
        : ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account Not Created"),
            ),
          );
  }

  Future<void> _showDialog() async {
    final formKey = GlobalKey<FormState>();
    bool isSecure = true;

    // TextEditingController idcontroller = TextEditingController();
    TextEditingController titlecontroller = TextEditingController();
    TextEditingController notecontroller = TextEditingController();
    TextEditingController mobile_1controller = TextEditingController();
    TextEditingController fullNamecontroller = TextEditingController();

    TextEditingController mobile_2controller = TextEditingController();
    TextEditingController addresscontroller = TextEditingController();
    TextEditingController companyNamecontroller = TextEditingController();
    

    // idcontroller.text = account['id'].toString();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Create'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                    child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: titlecontroller,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: notecontroller,
                        decoration: const InputDecoration(labelText: 'Reference'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: mobile_1controller,
                        decoration: const InputDecoration(labelText: 'Mobile #'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: fullNamecontroller,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: mobile_2controller,
                        decoration: const InputDecoration(labelText: 'Whatsapp #'),
                      ),
                      TextFormField(
                        controller: companyNamecontroller,
                        decoration:
                            const InputDecoration(labelText: 'Company Name'),
                      ),
                      TextFormField(
                        controller: addresscontroller,
                        decoration: const InputDecoration(labelText: 'Address'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSecure,
                              onChanged: (value) {
                                setState(() {
                                  isSecure = value!;
                                });
                              },
                            ),
                            const Text('Authorize For Ledger?',style: TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
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
                  child: const Text('Create'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      var data = jsonEncode({
                        "title": titlecontroller.text,
                        "note": notecontroller.text,
                        "full_name": fullNamecontroller.text,
                        "mobile_1": mobile_1controller.text,
                        "mobile_2": mobile_2controller.text.isEmpty
                            ? null
                            : mobile_2controller.text,
                        "address": addresscontroller.text.isEmpty
                            ? null
                            : addresscontroller.text,
                        "company_name": companyNamecontroller.text.isEmpty
                            ? null
                            : companyNamecontroller.text,
                        "authorize": isSecure,
                      });
                      createAccount(data);
                      Navigator.of(context).pop();
                    }
                    
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    return Scaffold(
        appBar: AppBar(
          title: const Text('ACCOUNTS'),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FutureBuilder<Map<String, dynamic>?>(
                        future: fetchedData(),
                        builder: (context, accountSnapshot) {
                          if (accountSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (accountSnapshot.hasError) {
                            return Text('Error: ${accountSnapshot.error}');
                          } else if (accountSnapshot.data != null) {
                            // Check if data is not null
                            final accountData = accountSnapshot.data!['data'];
                                        
                            return Column(
                              children: [
                                const SizedBox(
                                  height: 40,
                                ),
                                user.id == 2
                                    ? SizedBox(
                                      width: 150,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            _showDialog();
                                          },
                                          child: const Text(
                                            "CREATE",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    )
                                    : const Text(''),
                                const SizedBox(
                                  height: 40,
                                ),
                                user.id == 2 ?
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        HeaderWidget(
                                          index: 0,
                                          mainHeader: MainHeader,
                                          mainHeaderStyle: mainHeaderStyle,
                                          width: 40,
                                          color: Colors.lightGreen[300],
                                        ),
                                        HeaderWidget(
                                          index: 1,
                                          mainHeader: MainHeader,
                                          mainHeaderStyle: mainHeaderStyle,
                                          width: (145),
                                          color: Colors.lightGreen[300],
                                        ),
                                        HeaderWidget(
                                          index: 2,
                                          mainHeader: MainHeader,
                                          mainHeaderStyle: mainHeaderStyle,
                                          width: (145),
                                          color: Colors.lightGreen[300],
                                        ),
                                        HeaderWidget(
                                          index: 3,
                                          mainHeader: MainHeader,
                                          mainHeaderStyle: mainHeaderStyle,
                                          width: 110,
                                          color: Colors.lightGreen[300],
                                        ),
                                        HeaderWidget(
                                          index: 4,
                                          mainHeader: MainHeader,
                                          mainHeaderStyle: mainHeaderStyle,
                                          width: 110,
                                          color: Colors.lightGreen[300],
                                        ),
                                        HeaderWidget(
                                          index: 5,
                                          mainHeader: MainHeader,
                                          mainHeaderStyle: mainHeaderStyle,
                                          width: 100,
                                          color: Colors.lightGreen[300],
                                        ),
                                        HeaderWidget(
                                          index: 6,
                                          mainHeader: MainHeader,
                                          mainHeaderStyle: mainHeaderStyle,
                                          width: 100,
                                          color: Colors.lightGreen[300],
                                        ),
                                        HeaderWidget(
                                          index: 7,
                                          mainHeader: MainHeader,
                                          mainHeaderStyle: mainHeaderStyle,
                                          width: 100,
                                          color: Colors.lightGreen[300],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 600,
                                      width: (145 * 3)+(110*2)+40+(100*3),
                                      child: ListView.builder(
                                        scrollDirection:
                                            Axis.vertical, // Vertical scroll
                                        itemCount: accountData.length,
                                        itemBuilder: (context, index) {
                                          final account = accountData[index];
                                          return Row(
                                            children: [
                                              const SizedBox(
                                                width:70,
                                              ),
                                              SizedBox(
                                                  width: 40,
                                                  child:
                                                      Text('${account['id']}', textAlign: TextAlign.center)),
                                              SizedBox(
                                                  width: 145,
                                                  child: Text(
                                                      '${account['title']}', textAlign: TextAlign.center)),
                                              SizedBox(
                                                  width: 145,
                                                  child: Text(
                                                      ' ${account['note']}', textAlign: TextAlign.center)),
                                              SizedBox(
                                                  width: 110,
                                                  child: Text(
                                                      ' ${account['full_name']}', textAlign: TextAlign.center)),
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  '${account['mobile_1']}', textAlign: TextAlign.center,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                      ' ${account['mobile_2']}', textAlign: TextAlign.center)),
                                              SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                      ' ${account['address']}', textAlign: TextAlign.center)),
                                              SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                      ' ${account['"company_name']}', textAlign: TextAlign.center)),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ) :
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        HeaderWidget(
                                          index: 0,
                                          mainHeader: MainHeader,
                                          mainHeaderStyle: mainHeaderStyle,
                                          width: 40,
                                          color: Colors.lightGreen[300],
                                        ),
                                        HeaderWidget(
                                          index: 1,
                                          mainHeader: MainHeader,
                                          mainHeaderStyle: mainHeaderStyle,
                                          width: (145),
                                          color: Colors.lightGreen[300],
                                        ),
                                        HeaderWidget(
                                          index: 2,
                                          mainHeader: MainHeader,
                                          mainHeaderStyle: mainHeaderStyle,
                                          width: (145),
                                          color: Colors.lightGreen[300],
                                        ),
                                        HeaderWidget(
                                          index: 3,
                                          mainHeader: MainHeader,
                                          mainHeaderStyle: mainHeaderStyle,
                                          width: 110,
                                          color: Colors.lightGreen[300],
                                        ),
                                        
                                      ],
                                    ),
                                    SizedBox(
                                      height: 600,
                                      width: (145 * 3)+(110)+40,
                                      child: ListView.builder(
                                        scrollDirection:
                                            Axis.vertical, // Vertical scroll
                                        itemCount: accountData.length,
                                        itemBuilder: (context, index) {
                                          final account = accountData[index];
                                          return Row(
                                            children: [
                                              const SizedBox(
                                                width:70,
                                              ),
                                              SizedBox(
                                                  width: 40,
                                                  child:
                                                      Text('${account['id']}', textAlign: TextAlign.center)),
                                              SizedBox(
                                                  width: 145,
                                                  child: Text(
                                                      '${account['title']}', textAlign: TextAlign.center)),
                                              SizedBox(
                                                  width: 145,
                                                  child: Text(
                                                      ' ${account['note']}', textAlign: TextAlign.center)),
                                              SizedBox(
                                                  width: 110,
                                                  child: Text(
                                                      ' ${account['full_name']}', textAlign: TextAlign.center)),
                                              
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
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
    'ID',
    'Title',
    'Reference',
    'Name',
    'Mobile',
    'Whatsapp',
    'Address',
    'Company Name',
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
