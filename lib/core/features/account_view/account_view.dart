import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/appbar/gf_appbar.dart';
import 'package:intl/intl.dart';

class AccountView extends StatefulWidget {
  const AccountView({Key? key}) : super(key: key);

  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String dateNow = DateFormat('dd-MM-yyy').format(DateTime.now());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> gelirNames = [];
  List<String> giderNames = [];
  List<double> gelirPrices = [];
  List<double> giderPrices = [];
  double totalGelir = 0;
  double totalGider = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGelirorGider(dateNow);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GFAppBar(
        centerTitle: true,
        title: Text("Muhasebe"),
        backgroundColor: GFColors.DARK,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
             SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: ElevatedButton(
                          child: Text(
                            'Tarih Seç : ${dateNow}',
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
                                  dateNow = DateFormat('dd-MM-yyyy')
                                      .format(selectDate);

                                      getGelirorGider(dateNow);
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
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: Container(
                    color: GFColors.INFO,
                    child: Text("Gelir",style: TextStyle(color: GFColors.WHITE),textAlign: TextAlign.center,))),
                  Expanded(child: Container(
                    color: GFColors.DANGER,
                    child: Text("Gider",style: TextStyle(color: GFColors.WHITE),textAlign: TextAlign.center))),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: Text("Cari Adları",style: TextStyle(color: GFColors.DARK),textAlign: TextAlign.center)),
                  Expanded(child: Text("Fiyatlar",style: TextStyle(color: GFColors.DARK),textAlign: TextAlign.center)),
                  Expanded(child: Text("Cari Adları",style: TextStyle(color: GFColors.DARK),textAlign: TextAlign.center)),
                  Expanded(child: Text("Fiyatlar",style: TextStyle(color: GFColors.DARK),textAlign: TextAlign.center)),
                ],
              ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: gelirNames.length,
                      itemBuilder: (BuildContext context,index){
                      return Row(
                        children: [
                          Expanded(child: Text("${gelirNames[index]}",style: TextStyle(color: GFColors.DARK),textAlign: TextAlign.center)),
                          Expanded(child: Text("${gelirPrices[index]}",style: TextStyle(color: GFColors.DARK),textAlign: TextAlign.center)),
                        ],
                      );
                    }),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: giderNames.length,
                      itemBuilder: (BuildContext context,index){
                      return Row(
                        children: [
                          Expanded(child: Text("${giderNames[index]}",style: TextStyle(color: GFColors.DARK),textAlign: TextAlign.center)),
                          Expanded(child: Text("${giderPrices[index]}",style: TextStyle(color: GFColors.DARK),textAlign: TextAlign.center)),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,

                  children: [
                    Text("Gelir : ${totalGelir}"),
                                       Text("Gider : ${totalGider}"),

                                       Text("Kar / Zarar : ${totalGelir-totalGider}")

                  ],
                ))
          ],
        )
      ),
    );
  }

  Future<void> getGelirorGider(String dateTimeSelect) async {
    gelirNames = [];
    gelirPrices = [];
    giderNames = [];
    giderPrices = [];
    totalGelir = 0;
    totalGider = 0;
    CollectionReference collectionReferenceGelir = _firebaseFirestore
        .collection('Users')
        .doc(_auth.currentUser?.uid)
        .collection('Gelir');
         CollectionReference collectionReferenceGider = _firebaseFirestore
        .collection('Users')
        .doc(_auth.currentUser?.uid)
        .collection('Gider');
    await collectionReferenceGelir.doc(dateTimeSelect).get().then((res) {
      res.data();
      if (res.data()!=null) {
        var datas = jsonDecode(jsonEncode(res.data()));
      Map<String, dynamic> dataInValue = datas;
      dataInValue.forEach((key, value) { 
        print(value);
        gelirNames.add(key);
        gelirPrices.add(value);
       
      });

       gelirPrices.forEach((price) { 
          totalGelir+=price;
        });
        
      }
    });

    await collectionReferenceGider.doc(dateTimeSelect).get().then((res) {
      if (res.data()!=null) {
        var datas = jsonDecode(jsonEncode(res.data()));
      Map<String, dynamic> dataInValue = datas;
      dataInValue.forEach((key, value) { 
        print(value);
        giderNames.add(key);
        giderPrices.add(value);
       
      });

       giderPrices.forEach((price) { 
          totalGider+=price;
        });
      }
    });
    setState(() {
      
    });
 
  }
}
