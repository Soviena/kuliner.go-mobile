import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kuliner_go_mobile/components/cardReview.dart';
import 'package:kuliner_go_mobile/pages/home_bottomnav.dart';
import 'package:kuliner_go_mobile/pages/review_page.dart';
import 'package:kuliner_go_mobile/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import './booking.dart';

class restaurantPage extends StatelessWidget {
  final dynamic resto;
  String url = "https://kulinergo.belajarpro.online/";

  restaurantPage({super.key, required this.resto});
  DateTime currentTime = DateTime.now();
  late TimeOfDay jamBuka;
  late TimeOfDay jamTutup;

  bool isOpen() {
    if (resto['jamBuka'] == null || resto['jamTutup'] == null) {
      return true;
    }

    try {
      List<String> jamBukaParts = resto['jamBuka'].split(':');
      List<String> jamTutupParts = resto['jamTutup'].split(':');

      int jamBukaHour = int.parse(jamBukaParts[0]);
      int jamBukaMinute = int.parse(jamBukaParts[1]);
      int jamTutupHour = int.parse(jamTutupParts[0]);
      int jamTutupMinute = int.parse(jamTutupParts[1]);

      final currentTime = DateTime.now();
      final current = TimeOfDay.fromDateTime(currentTime);

      DateTime currentDateTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        current.hour,
        current.minute,
      );

      DateTime jamBukaDateTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        jamBukaHour,
        jamBukaMinute,
      );

      DateTime jamTutupDateTime;
      if (jamTutupHour < jamBukaHour) {
        jamTutupDateTime = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day + 1,
          jamTutupHour,
          jamTutupMinute,
        );
      } else {
        jamTutupDateTime = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          jamTutupHour,
          jamTutupMinute,
        );
      }

      if (jamTutupHour < jamBukaHour) {
        if (currentDateTime.isBefore(jamBukaDateTime)) {
          currentDateTime = currentDateTime.subtract(const Duration(days: 1));
        }
      }

      return currentDateTime.isAfter(jamBukaDateTime) &&
          currentDateTime.isBefore(jamTutupDateTime);
    } catch (e) {
      print('Error parsing opening and closing times: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool open = isOpen();
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
                Column(
                  children: [
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
                          padding: const EdgeInsets.only(
                              left: 20, bottom: 20, top: 12),
                          child: Text(
                            '${resto['nama']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 12, bottom: 20, top: 12),
                          child: Icon(
                            Icons.verified,
                            color: Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 40, bottom: 8),
                              child: Text(
                                open ? 'Buka Sekarang' : 'Tutup',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: open ? Colors.blue : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: <Widget>[
                    //     Padding(
                    //       padding: const EdgeInsets.only(left: 20.0),
                    //       child: Align(
                    //         alignment: AlignmentDirectional.topStart,
                    //         child: Text(
                    //           '${resto['tipe']}',
                    //           style: const TextStyle(
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.w400,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(height: 20),
                    //   ],
                    // ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 230, bottom: 20),
                          child: Text(
                            'Detail Restoran',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: SizedBox(
                        height: 60,
                        child: Text(
                          '${resto['detail']}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        ExpansionTile(
                          title: const Text('Jam Buka'),
                          childrenPadding: const EdgeInsets.all(20),
                          leading: const Icon(Icons.access_time),
                          children: <Widget>[
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: resto['hariBuka'].split(',').length,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                String day =
                                    resto['hariBuka'].split(',')[index];
                                String openingTime = resto['jamBuka'];
                                String closingTime = resto['jamTutup'];
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        day,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '$openingTime - $closingTime',
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        ExpansionTile(
                          title: const Text('Kisaran Harga'),
                          childrenPadding: const EdgeInsets.only(left: 12),
                          leading: const Icon(Icons.attach_money_outlined),
                          children: <Widget>[
                            ListTile(
                              leading: const Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Image(
                                    image: AssetImage('assets/dollar.png')),
                              ),
                              title: Text(
                                '\t | ${resto['kisaranHarga']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Column(
                    //   children: <Widget>[
                    //     ExpansionTile(
                    //       title: const Text('Daftar Menu'),
                    //       leading: const Icon(Icons.restaurant_menu_sharp),
                    //       children: <Widget>[
                    //         StreamBuilder<QuerySnapshot>(
                    //           stream: FirebaseFirestore.instance
                    //               .collection('Menu')
                    //               .where('restaurantId', isEqualTo: resto.id)
                    //               .snapshots(),
                    //           builder: (context, snapshot) {
                    //             if (snapshot.hasError) {
                    //               return Center(
                    //                   child: Text('Error: ${snapshot.error}'));
                    //             }
                    //             if (snapshot.connectionState ==
                    //                 ConnectionState.waiting) {
                    //               return const Center(
                    //                   child: CircularProgressIndicator());
                    //             }
                    //             final querySnapshot = snapshot.data;
                    //             if (querySnapshot!.size == 0) {
                    //               return const Center(
                    //                   child: Text(
                    //                       'Tidak ada data menu yang ditemukan'));
                    //             }

                    //             final documents = querySnapshot.docs;
                    //             final menuImages = documents
                    //                 .take(5)
                    //                 .map((doc) => doc.get('imageUrl'))
                    //                 .toList();
                    //             final remainingImagesCount =
                    //                 documents.length - 5;
                    //             return Column(
                    //               children: [
                    //                 Center(
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.center,
                    //                     children:
                    //                         menuImages.map((menuImageUrl) {
                    //                       return Container(
                    //                         width: 70,
                    //                         height: 70,
                    //                         padding:
                    //                             const EdgeInsets.only(left: 12),
                    //                         child: Image.network(menuImageUrl),
                    //                       );
                    //                     }).toList(),
                    //                   ),
                    //                 ),
                    //                 if (remainingImagesCount > 0)
                    //                   Padding(
                    //                     padding:
                    //                         const EdgeInsets.only(top: 8.0),
                    //                     child: Text(
                    //                       '+$remainingImagesCount Menu lainnya',
                    //                       style: const TextStyle(
                    //                         color: Colors.grey,
                    //                         fontSize: 14,
                    //                       ),
                    //                     ),
                    //                   ),
                    //               ],
                    //             );
                    //           },
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    Column(
                      children: <Widget>[
                        ExpansionTile(
                          title: const Text('Alamat Restoran'),
                          childrenPadding: const EdgeInsets.only(left: 12),
                          leading: const Icon(Icons.location_on),
                          children: <Widget>[
                            const SizedBox(
                              height: 16,
                            ),
                            Column(
                              children: [
                                Container(
                                  width: 520,
                                  padding: const EdgeInsets.only(
                                      left: 40, right: 30),
                                  child: Text(
                                    '${resto['alamatRestoran']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Container(
                                    width: 300,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                    ),
                                    child: TextButton(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                      ),
                                      onPressed: () async {
                                        final url =
                                            Uri.parse(resto['urlRestoran']);
                                        await launchUrl(url);
                                      },
                                      child: const Text('Alamat Restaurant'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        ExpansionTile(
                          title: const Text('Fasilitas Restoran'),
                          leading: const Icon(Icons.more_horiz_sharp),
                          children: <Widget>[
                            Container(
                              width: 520,
                              padding:
                                  const EdgeInsets.only(left: 40, right: 30),
                              child: Text(
                                '${resto['fasilitasRestoran']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            )
                          ],
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 20.0, top: 12, right: 10.0, bottom: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text(
                                'Ulasan Restoran',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const Image(
                              image: AssetImage('assets/ulasanResto.png'))
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        ExpansionTile(
                          title: Row(
                            children: <Widget>[
                              Row(
                                children: const <Widget>[
                                  Icon(Icons.chat_outlined),
                                  SizedBox(width: 8),
                                  Text('Ulasan'),
                                ],
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => reviewPage(
                                        resto: resto,
                                      ),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          // children: <Widget>[
                          //   Column(
                          //     children: [
                          //       StreamBuilder<QuerySnapshot>(
                          //         stream: FirebaseFirestore.instance
                          //             .collection('Review')
                          //             .where('restoId', isEqualTo: resto.id)
                          //             .snapshots(),
                          //         builder: (context, snapshot) {
                          //           if (snapshot.hasError) {
                          //             return Text('Error: ${snapshot.error}');
                          //           }

                          //           if (snapshot.connectionState ==
                          //               ConnectionState.waiting) {
                          //             return const CircularProgressIndicator();
                          //           }

                          //           if (snapshot.data!.docs.isEmpty) {
                          //             return const Text(
                          //                 'Belum ada yang review restoran ini');
                          //           }
                          //           final sortedDocs = snapshot.data!.docs
                          //               .map((doc) =>
                          //                   doc.data() as Map<String, dynamic>)
                          //               .toList()
                          //             ..sort((a, b) {
                          //               final timestampA = a['timestamp'];
                          //               final timestampB = b['timestamp'];

                          //               if (timestampA == null ||
                          //                   timestampB == null) {
                          //                 return 0;
                          //               }

                          //               return timestampB.compareTo(timestampA);
                          //             });

                          //           return Column(
                          //             children: sortedDocs.map((reviewData) {
                          //               double rating =
                          //                   reviewData['rate'] ?? 0.0;
                          //               dynamic timestamp =
                          //                   reviewData['timestamp'];
                          //               return Padding(
                          //                 padding: const EdgeInsets.all(20),
                          //                 child: CardReview(
                          //                   imageUrl: 'assets/users_init.png',
                          //                   username: reviewData['username'],
                          //                   rating: rating,
                          //                   timeUpload: timestamp,
                          //                   comments:
                          //                       '"${reviewData['commentText']}"',
                          //                 ),
                          //               );
                          //             }).toList(),
                          //           );
                          //         },
                          //       ),
                          //     ],
                          //   ),
                          // ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 300,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            border: Border.all(
                              width: 0,
                            )),
                        child: TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => bookingPage(
                                  resto: resto,
                                  email: '',
                                  username: '',
                                ),
                              ),
                            );
                          },
                          child: const Text('Pesan Tempat'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16)
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Uri phone = Uri.parse('tel:+1234556789');
          if (await launchUrl(phone)) {
            print("Dialer Opened");
          } else {
            print("Dailer is not opened");
          }
        },
        child: const Icon(Icons.call),
      ),
    );
  }
}
