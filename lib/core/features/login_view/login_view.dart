import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:getwidget/getwidget.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:selfaccount/core/features/register_view/register_view.dart';
import 'package:selfaccount/core/init/helpers/service/firebase_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool isOverlay = false;
  Map loginModel = {
    'email': '',
    'password': '',
  };
  String? firebaseToken;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myService = Provider.of<FirebaseService>(context);
    return Scaffold(
        body: LoadingOverlay(
      isLoading: myService.isOverlay,
      child: Container(
        color: GFColors.DARK,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(left: 28.0, right: 28.0),
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "aKont",
                    style: TextStyle(
                        color: GFColors.WHITE,
                        fontWeight: FontWeight.bold,
                        fontSize: 70),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "Gelir / Gider Takip Uygulaması",
                    style: TextStyle(
                        color: GFColors.WHITE,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  TextFormField(
                    onTap: () {
                      myService.errorTextMessage = "";
                    },
                    onSaved: (value) {
                      setState(() {
                        loginModel['email'] = userNameController.text;
                      });
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s")),
                    ],
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    controller: userNameController,
                    cursorColor: Colors.white,
                    validator: FormBuilderValidators.required(context,
                        errorText: "Bu alanın doldurulması gerekmektedir."),
                    decoration: const InputDecoration(
                      errorStyle: TextStyle(color: Colors.white),
                      hintText: "E-posta",
                      hintStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  //password
                  TextFormField(
                    onTap: () {
                      myService.errorTextMessage = "";
                    },
                    obscureText: true,
                    onSaved: (value) {
                      setState(() {
                        loginModel['password'] = passwordController.text;
                      });
                    },
                    onFieldSubmitted: (value) async {
                      _postLogin();
                    },
                    style: const TextStyle(color: Colors.white),
                    controller: passwordController,
                    cursorColor: Colors.white,
                    validator: FormBuilderValidators.required(context,
                        errorText: "Bu alanın doldurulması gerekmektedir."),
                    decoration: const InputDecoration(
                      errorStyle: TextStyle(color: Colors.white),
                      hintText: "Şifre",
                      hintStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  Consumer<FirebaseService>(
                      builder: (context, errorProvider, child) {
                    return Text(
                      "${errorProvider.errorTextMessage}",
                      style: TextStyle(color: GFColors.DANGER),
                    );
                  }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            "Şifre mi Unuttum?",
                            style: TextStyle(color: GFColors.WHITE),
                          )),
                      TextButton(
                          onPressed: () {
                            myService.errorTextMessage = "";
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterView()),
                            );
                          },
                          child: Text(
                            "Kayıt Ol",
                            style: TextStyle(color: GFColors.WHITE),
                          ))
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: ElevatedButton(
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(
                            color: GFColors.DARK,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        myService.isOverlay = true;
                        _postLogin();
                      },
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(GFColors.LIGHT),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(GFColors.LIGHT),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: const BorderSide(
                                          color: GFColors.LIGHT)))),
                    ),
                  ),
                  const Text(
                    "Developed by omerkaansaglam",
                    style: TextStyle(
                        color: GFColors.WHITE,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
        ),
      ),
    ));
  }

  Future<void> _postLogin() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await context
          .read<FirebaseService>()
          .signInWithEmailAndPassword(
              loginModel['email'], loginModel['password'])
          .onError((error, stackTrace) {
      context.read<FirebaseService>().isOverlay = false;

        print('Giriş yaparken hata ile karşılaşıldı : $error');
      });
      context.read<FirebaseService>().isOverlay = false;

    }
      context.read<FirebaseService>().isOverlay = false;

  }
}
