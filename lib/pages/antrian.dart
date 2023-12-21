import 'dart:convert';
import 'package:kuliner_go_mobile/components/payment_succes.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kuliner_go_mobile/components/payment_succes.dart';
import 'package:kuliner_go_mobile/pages/home_bottomnav.dart';
import 'package:kuliner_go_mobile/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AntrianPage extends StatefulWidget {
  final int restoId;
  final int myAntrianId;

  const AntrianPage(
      {super.key, required this.restoId, required this.myAntrianId});

  @override
  State<AntrianPage> createState() => _AntrianPageState();
}

class _AntrianPageState extends State<AntrianPage> {
  final String url = "https://kulinergo.belajarpro.online/";
  dynamic resto = {};
  int antrianLength = 0;
  int estimasi = 0;
  List<Widget> list = [];
  List<Widget> listAntrian = [];
  void getRestoran() async {
    try {
      await http.get(Uri.parse("${url}api/restoran/${widget.restoId}")).then(
        (response) async {
          if (response.statusCode == 200) {
            if (kDebugMode) {
              print(response.body);
            }
            setState(() {
              resto = jsonDecode(response.body);
            });
          } else if (response.statusCode == 404) {
            if (kDebugMode) {
              print("No data");
            }
          } else {
            throw Exception("Error connectiong to server");
          }
        },
      ).then((value) => makeList());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void makeList() {
    list = [
      Container(
        color: whiteColor,
        margin: const EdgeInsets.only(
            left: 12.0, top: 15.0, right: 12.0, bottom: 10),
        child: Column(
          children: <Widget>[
            if (resto['gambar'].isNotEmpty)
              Image.network(
                "${url}storage/restoran/" + resto['gambar'],
                width: 700,
                fit: BoxFit.cover,
              )
            else
              Image.asset(
                'assets/emptyresto.png',
                width: 700,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20, top: 12),
            child: Text(
              '${resto['nama']}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 20, top: 12),
            child: Icon(
              Icons.verified,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    ];
    setState(() {
      list;
    });
  }

  void updateAntrian() async {
    listAntrian = [];
    try {
      await http.get(Uri.parse("${url}api/getAntrian/${widget.restoId}")).then(
        (response) async {
          if (response.statusCode == 200) {
            if (kDebugMode) {
              print(response.body);
            }
            dynamic antr = jsonDecode(response.body);
            antrianLength = antr.length;
            if (antr[0]['id'] == widget.myAntrianId) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentSucces(),
                ),
              );
            }
            setState(() {
              antrianLength;
              estimasi = antr[0]['restoran']['waitTimeAVG'] * antrianLength;
              int i = 1;
              for (var antrian in antr) {
                DateTime dateTime = DateTime.parse(antrian['created_at']);
                Color c = Colors.black;
                if (antrian['id'] == widget.myAntrianId) {
                  c = Colors.lightBlue.shade50;
                } else {
                  c = Colors.black26;
                }
                listAntrian.add(
                  Container(
                    padding: EdgeInsets.all(10),
                    color: c,
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$i'),
                        Text(antrian['nama']),
                        Text(DateFormat.yMMMMd().add_jm().format(dateTime)),
                      ],
                    ),
                  ),
                );
                i++;
              }
            });
          } else if (response.statusCode == 404) {
            if (kDebugMode) {
              print("No data");
            }
          } else {
            throw Exception("Error connectiong to server");
          }
        },
      ).then((value) => makeList());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    getRestoran();
    updateAntrian();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 24, left: 8),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const homeBottomNav(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 24, left: 84),
                      child: Text(
                        '${resto['nama']}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
                Column(children: list),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 21),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Row(
                            children: [Text('Banyak Antrian')],
                          ),
                          Row(
                            children: [Text("$antrianLength")],
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            children: [Text('Estimasi')],
                          ),
                          Row(
                            children: [Text("${estimasi} Menit")],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                    children: listAntrian,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          updateAntrian();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
