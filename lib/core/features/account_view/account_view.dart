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
  String dateNow = DateFormat.yMMMEd('tr_TR').format(DateTime.now());

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
    getGelirorGider();
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
            Text("Tarih : ${dateNow}"),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: Text("Gelir")),
                  Expanded(child: Text("Gider")),

                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: Text("Cari Adları")),
                  Expanded(child: Text("Fiyatlar")),
                  Expanded(child: Text("Cari Adları")),
                  Expanded(child: Text("Fiyatlar")),
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
                          Expanded(child: Text("${gelirNames[index]}")),
                          Expanded(child: Text("${gelirPrices[index]}")),
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
                          Expanded(child: Text("${giderNames[index]}")),
                          Expanded(child: Text("${giderPrices[index]}")),
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

  Future<void> getGelirorGider() async {
    String dateFormat = DateFormat('dd-MM-yyy').format(DateTime.now());
    CollectionReference collectionReferenceGelir = _firebaseFirestore
        .collection('Users')
        .doc(_auth.currentUser?.uid)
        .collection('Gelir');
         CollectionReference collectionReferenceGider = _firebaseFirestore
        .collection('Users')
        .doc(_auth.currentUser?.uid)
        .collection('Gider');
    await collectionReferenceGelir.doc(dateFormat).get().then((res) {
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

    await collectionReferenceGider.doc(dateFormat).get().then((res) {
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
