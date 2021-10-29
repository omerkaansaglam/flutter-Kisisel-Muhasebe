import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:getwidget/getwidget.dart';

class CarilerView extends StatefulWidget {
  const CarilerView({Key? key}) : super(key: key);

  @override
  _CarilerViewState createState() => _CarilerViewState();
}

class _CarilerViewState extends State<CarilerView> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController cariNameController = TextEditingController();
  final _formKeyCari = GlobalKey<FormState>();

  List<dynamic> carilerList = [];
  List<dynamic> carilerInList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCariler().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: GFColors.DARK,
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Cari Ekle'),
                  content: Form(
                    key: _formKeyCari,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          onSaved: (value) {
                            setState(() {
                              cariNameController.text = value.toString();
                            });
                          },
                          style: const TextStyle(color: GFColors.DARK),
                          controller: cariNameController,
                          cursorColor: GFColors.DARK,
                          validator: FormBuilderValidators.required(context,
                              errorText:
                                  "Bu alanın doldurulması gerekmektedir."),
                          decoration: const InputDecoration(
                            errorStyle: TextStyle(color: GFColors.DARK),
                            hintText: "Cari Adı",
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
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('İptal')),
                    TextButton(
                      onPressed: () async {
                        if (_formKeyCari.currentState != null &&
                            _formKeyCari.currentState!.validate()) {
                          _formKeyCari.currentState!.save();
                          await cariEkle(cariNameController.text).then((_){
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Text('Ekle'),
                    )
                  ],
                );
              });
        },
        child: Icon(
          Icons.add,
          color: GFColors.WHITE,
        ),
      ),
      appBar: GFAppBar(
        title: Text("Cari Kart Ekle / Çıkar"),
        backgroundColor: GFColors.DARK,
        centerTitle: true,
      ),
      body: Container(
          height: 500,
          child: ListView.builder(
              itemCount: carilerInList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text("${index + 1}"),
                  title: Text("${carilerInList[index]}"),
                  trailing: InkWell(
                      onTap: () async {
                        await deleteCari(carilerInList[index].toString());
                      },
                      child: Icon(Icons.delete)),
                );
              })),
    );
  }

  Future<List<dynamic>> getCariler() async {
    var docRef =
        _firebaseFirestore.collection('Users').doc(_auth.currentUser?.uid);

    var querySnap = await docRef.collection('Cariler').get();
    carilerList = querySnap.docs.map((snap) => snap.data()['cariler']).toList();
    carilerList.forEach((val) {
      carilerInList = val;
    });
    return carilerInList;
  }

  Future deleteCari(String cariName) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('Users')
        .doc(_auth.currentUser?.uid)
        .collection('Cariler');
    await collection.doc('cariler').update({
      'cariler': FieldValue.arrayRemove(['${cariName}'])
    });
    getCariler().then((_) {
      setState(() {});
    });
  }

  Future cariEkle(String cariName) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('Users')
        .doc(_auth.currentUser?.uid)
        .collection('Cariler');
    await collection.doc('cariler').update({
      'cariler': FieldValue.arrayUnion(['${cariName}'])
    });
    getCariler().then((_) {
      setState(() {});
    });
  }
}
