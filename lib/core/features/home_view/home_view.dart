import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/appbar/gf_appbar.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:selfaccount/core/features/account_view/account_view.dart';
import 'package:selfaccount/core/features/cariler_view/cariler_view.dart';
import 'package:selfaccount/core/init/helpers/provider/home_viev_extension_provider.dart';
import 'package:provider/provider.dart';
import 'package:selfaccount/core/init/helpers/service/firebase_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String dateFormat = DateFormat.yMMMEd('tr_TR').format(DateTime.now());
  final _formkey = GlobalKey<FormState>();
  final TextEditingController priceController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController dateController = TextEditingController();
  List<dynamic> carilerList = [];
  List<dynamic> carilerInList = [];
  String _selectedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String? _cariName;
  Map gelirEkle = {'date': '', 'kalem': '', 'fiyat': ''};
  Map giderEkle = {'date': '', 'kalem': '', 'fiyat': ''};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCariler().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGelirProvider = Provider.of<HomeViewManagerProvider>(context);

    return Scaffold(
      backgroundColor: GFColors.LIGHT,
      endDrawer: Drawer(
        elevation: 0,
        backgroundColor: GFColors.DARK,
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CarilerView()),
                    );
                  },
                  child: Text(
                    "Cari Kart",
                    style: TextStyle(color: GFColors.WHITE),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AccountView()),
                    );
                  },
                  child: Text(
                    "Muhasebe",
                    style: TextStyle(color: GFColors.WHITE),
                  )),
              TextButton(
                  onPressed: () async {
                    await _firebaseService.signOut();
                    context.read<FirebaseService>().isOverlay = false;
                  },
                  child: Text(
                    "Çıkış",
                    style: TextStyle(color: GFColors.WHITE),
                  )),
            ],
          ),
        ),
      ),
      appBar: GFAppBar(
        backgroundColor: GFColors.DARK,
        title: const Text(
          "aKont",
          style: TextStyle(
              color: GFColors.WHITE, fontWeight: FontWeight.bold, fontSize: 30),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 5,
            decoration: const BoxDecoration(
                color: GFColors.DARK,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.0),
                  bottomRight: Radius.circular(50.0),
                )),
            child: Column(
              children: [
                const ListTile(
                  title: Text(
                    "Gelir / Gider Takip Uygulamasına",
                    style: TextStyle(color: GFColors.WHITE),
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    "Hoş geldiniz...",
                    style: TextStyle(color: GFColors.WHITE),
                    textAlign: TextAlign.center,
                  ),
                ),
                ListTile(
                  title: Text(
                    "${dateFormat}",
                    style: const TextStyle(color: GFColors.WHITE),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                gelirButtonBuilder(context),
                giderButtonBuilder(context),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Form(
                  key: _formkey,
                  child: ListView(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: ElevatedButton(
                          child: Text(
                            _selectedDate != null
                                ? 'Seçilen Tarih : ${_selectedDate}'
                                : 'Tarih Seç',
                            style: TextStyle(
                                color: GFColors.WHITE,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              selectableDayPredicate: (date) {
                                // Disable weekend days to select from the calendar
                                if (date.weekday == 0 || date.weekday == 0) {
                                  return false;
                                }

                                return true;
                              },
                            ).then((selectDate) {
                              if (selectDate != null) {
                                setState(() {
                                  _selectedDate = DateFormat('dd-MM-yyyy')
                                      .format(selectDate);
                                  dateController.text = _selectedDate;
                                  print(dateController.text);
                                });
                              }
                            });
                          },
                          style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  GFColors.DARK),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  GFColors.DARK),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side: const BorderSide(
                                          color: GFColors.DARK)))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: ElevatedButton(
                            child: Text(
                              _cariName != null
                                  ? 'Cari Adı : ${_cariName}'
                                  : 'Cari Seç',
                              style: TextStyle(
                                  color: GFColors.WHITE,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              await getCariler().then((_) {
                                if (carilerInList.isNotEmpty) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Cari Seç'),
                                          content: SingleChildScrollView(
                                            child: GroupButton(
                                              spacing: 5,
                                              isRadio: true,
                                              direction: Axis.horizontal,
                                              onSelected: (index, isSelected) {
                                                print(
                                                    '$index button is ${isSelected ? 'selected' : 'unselected'}');
                                                setState(() {
                                                  _cariName =
                                                      carilerInList[index]
                                                          .toString();
                                                  print(_cariName);
                                                });
                                                Navigator.pop(context);
                                              },
                                              buttons: List.from(carilerInList),
                                              selectedTextStyle: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: Colors.red,
                                              ),
                                              unselectedTextStyle: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                              selectedColor: Colors.white,
                                              unselectedColor: Colors.grey[300],
                                              selectedBorderColor: Colors.red,
                                              unselectedBorderColor:
                                                  Colors.grey[500],
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              selectedShadow: <BoxShadow>[
                                                BoxShadow(
                                                    color: Colors.transparent)
                                              ],
                                              unselectedShadow: <BoxShadow>[
                                                BoxShadow(
                                                    color: Colors.transparent)
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              'Lütfen Cari Kart Ekleyiniz'),
                                          content: TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CarilerView()),
                                              );
                                            },
                                            child: Text("Cari Kart Ekle"),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Kapat')),
                                          ],
                                        );
                                      });
                                }
                              });
                            },
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        GFColors.DARK),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        GFColors.DARK),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        side: const BorderSide(
                                            color: GFColors.DARK)))),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        child: TextFormField(
                          obscureText: true,
                          onSaved: (value) {
                            setState(() {
                              priceController.text = value.toString();
                            });
                          },
                          style: const TextStyle(color: GFColors.DARK),
                          controller: priceController,
                          cursorColor: GFColors.DARK,
                          validator: FormBuilderValidators.required(context,
                              errorText:
                                  "Bu alanın doldurulması gerekmektedir."),
                          decoration: const InputDecoration(
                            errorStyle: TextStyle(color: GFColors.DARK),
                            hintText: "Tutar (₺)",
                            hintStyle: TextStyle(
                                color: GFColors.DARK,
                                fontWeight: FontWeight.bold),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: GFColors.DARK),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: GFColors.DARK),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: GFColors.DARK),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: GFColors.DARK),
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: GFColors.DARK),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: ElevatedButton(
                            child: Text(
                              'Kaydet',
                              style: TextStyle(
                                  color: GFColors.WHITE,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              if (_cariName != null) {
                                if (_formkey.currentState != null &&
                                    _formkey.currentState!.validate()) {
                                  _formkey.currentState!.save();
                                  await addGelirOrGider(
                                      _cariName!,
                                      double.parse(priceController.text),
                                      _selectedDate,
                                      isGelirProvider.gelirOrGider);
                                }
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title:
                                            Text('Lütfen Cari Kart Seçiniz!'),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Kapat')),
                                        ],
                                      );
                                    });
                              }
                            },
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        GFColors.DARK),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        GFColors.DARK),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        side: const BorderSide(
                                            color: GFColors.DARK)))),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }

  InkWell gelirButtonBuilder(BuildContext context) {
    final provider = Provider.of<HomeViewManagerProvider>(context);
    return InkWell(
      onTap: () {
        provider.gelirOrGider = false;
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2.2,
        height: MediaQuery.of(context).size.height * 0.05,
        decoration: BoxDecoration(
          color: provider.gelirOrGider != true
              ? GFColors.SUCCESS
              : GFColors.DANGER,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: provider.gelirOrGider != true
                  ? GFColors.SUCCESS
                  : GFColors.DANGER,
              blurRadius: 4,
              offset: const Offset(2, 2), // Shadow position
            ),
          ],
        ),
        child: const Align(
            alignment: Alignment.center,
            child: Text(
              "GELİR",
              style:
                  TextStyle(color: GFColors.LIGHT, fontWeight: FontWeight.bold),
            )),
      ),
    );
  }

  InkWell giderButtonBuilder(BuildContext context) {
    final provider = Provider.of<HomeViewManagerProvider>(context);

    return InkWell(
      onTap: () {
        provider.gelirOrGider = true;
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2.2,
        height: MediaQuery.of(context).size.height * 0.05,
        decoration: BoxDecoration(
          color: provider.gelirOrGider != false
              ? GFColors.SUCCESS
              : GFColors.DANGER,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: provider.gelirOrGider != false
                  ? GFColors.SUCCESS
                  : GFColors.DANGER,
              blurRadius: 4,
              offset: const Offset(2, 2), // Shadow position
            ),
          ],
        ),
        child: const Align(
            alignment: Alignment.center,
            child: Text(
              "GİDER",
              style:
                  TextStyle(color: GFColors.LIGHT, fontWeight: FontWeight.bold),
            )),
      ),
    );
  }

  Future addGelirOrGider(
      String cariName, double price, String date, bool isGelir) async {
    CollectionReference collection;

    if (isGelir != false) {
      collection = FirebaseFirestore.instance
          .collection('Users')
          .doc(_firebaseAuth.currentUser?.uid)
          .collection('Gider');
    } else {
      collection = FirebaseFirestore.instance
          .collection('Users')
          .doc(_firebaseAuth.currentUser?.uid)
          .collection('Gelir');
    }

    var datas = collection.doc(date).get();
    datas.then((res) {
      if (res.data() != null) {
        collection.doc(date).get().then((res) {
          var oldData = jsonDecode(jsonEncode(res.data()));
          Map<String, dynamic> dataInValue = oldData;
          print(dataInValue[cariName]);

          if (dataInValue[cariName] != null) {
            double oldPrice = dataInValue[cariName];
            Map<String, dynamic> gelirMap = {'${cariName}': oldPrice + price};
            collection.doc(date).update(gelirMap);
          } else {
            Map<String, dynamic> gelirMap = {'${cariName}': price};
            collection.doc(date).update(gelirMap);
          }
        });
      } else {
        Map<String, dynamic> gelirMap = {'${cariName}': price};
        collection.doc(date).set(gelirMap);
      }
    });
  }

  Future<List<dynamic>> getCariler() async {
    var docRef = _firebaseFirestore
        .collection('Users')
        .doc(_firebaseAuth.currentUser?.uid);

    var querySnap = await docRef.collection('Cariler').get();
    carilerList = querySnap.docs.map((snap) => snap.data()['cariler']).toList();
    carilerList.forEach((val) {
      carilerInList = val;
    });
    if (carilerInList.isNotEmpty) {
      _cariName = carilerInList[0].toString();
    } else {
      _cariName = null;
    }
    setState(() {});
    return carilerInList;
  }
}
