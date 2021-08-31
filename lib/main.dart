import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:flutter/src/painting/gradient.dart' as grad;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Montserrat",
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD6E2EA),
      resizeToAvoidBottomInset: false,
      body: BearAnimationloginpage(),
    );
  }
}

class BearAnimationloginpage extends StatefulWidget {
  const BearAnimationloginpage({Key? key}) : super(key: key);

  @override
  _BearAnimationloginpageState createState() => _BearAnimationloginpageState();
}

class _BearAnimationloginpageState extends State<BearAnimationloginpage> {
  bool status = false;
  String animation = "Unlike";
  SMIInput<bool>? _check;
  SMIInput<bool>? _handsUp;
  SMIInput<double>? _look;
  SMITrigger? _success;
  SMITrigger? _fail;
  String stateChangeMessage = '';
  Artboard? _riveArtboard;

  bool _formStatus = false;

  FocusNode _focusEmail = new FocusNode();
  FocusNode _focusPassword = new FocusNode();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _focusEmail.addListener(_onEmailFocusChange);
    _focusPassword.addListener(_onPasswordFocusChange);
    rootBundle.load('assets/rive/teddy_login_screen.riv').then((data) async {
      final file = RiveFile.import(data);

      final artboard = file.mainArtboard;

      final controller = StateMachineController.fromArtboard(
        artboard,
        'State Machine 1',
        onStateChange: _onStateChange,
      );

      if (controller != null) {
        artboard.addController(controller);
        _check = controller.findInput<bool>('Check');
        _look = controller.findInput<double>("Look");
        _handsUp = controller.findInput<bool>('hands_up');
        _success = controller.findInput<bool>("success") as SMITrigger;
        _fail = controller.findInput<bool>("fail") as SMITrigger;

        // _like = controller.findInput<bool>('Like') as SMIBool;
        // _like?.value = false;
      }
      setState(() {
        _riveArtboard = artboard;
      });
    });
  }

  @override
  void dispose() {
    _focusEmail.dispose();
    _focusPassword.dispose();
  }

  void _onPasswordFocusChange() {
    print("Focuspassword: " + _focusPassword.hasFocus.toString());
    _handsUp!.value = _focusPassword.hasFocus;
  }

  void _onEmailFocusChange() {
    print("Focus email: " + _focusEmail.hasFocus.toString());

    _check!.value = _focusEmail.hasFocus;
  }

  void _onStateChange(String stateMachineName, String stateName) => setState(
        () => stateChangeMessage =
            'State Changed in $stateMachineName to $stateName',
      );

  @override
  Widget build(BuildContext context) {
    var mQuery = MediaQuery.of(context);
    return SingleChildScrollView(
      reverse: true,
      child: Stack(
        children: [
          Container(
            height: mQuery.viewInsets.bottom == 0.0
                ? mQuery.size.height
                : mQuery.size.height + mQuery.viewInsets.bottom / 5,
          ),
          _riveArtboard == null
              ? const SizedBox(
                  height: 400,
                )
              : SizedBox(
                  height: 400,
                  child: Rive(
                    fit: BoxFit.contain,
                    artboard: _riveArtboard!,
                  ),
                ),
          Positioned(
            top: 350,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.all(10),
              padding:
                  EdgeInsets.only(top: 28, left: 12, right: 12, bottom: 28),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      focusNode: _focusEmail,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (String value) {
                        _look!.value = value.length.toDouble() * 2;
                      },
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty)
                          return "This field is required";
                        else if (value.length < 6) {
                          return 'a minimum of 3 characters is required';
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: "User Name",
                        hintText: "User Name",
                        contentPadding: EdgeInsets.only(
                            left: 24, top: 20, bottom: 20, right: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      scrollPadding: const EdgeInsets.only(bottom: 32.0),
                      focusNode: _focusPassword,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: "Password",
                        contentPadding: EdgeInsets.only(
                            left: 24, top: 20, bottom: 20, right: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                      validator: (val) {
                        if (val!.isEmpty)
                          return "this field is required";
                        else if (val.length < 6) return 'Password too short.';
                      },
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    InkWell(
                      onTap: () {
                        // reset the bear animation according to focus
                        if (_focusEmail.hasFocus) _focusEmail.unfocus();
                        if (_focusPassword.hasFocus) _focusPassword.unfocus();

                        // trigger bear sucess ot failure animation
                        if (_formKey.currentState!.validate()) {
                          _success!.fire();
                          setState(() {
                            _formStatus = true;
                          });
                        } else {
                          _fail!.fire();
                          _formStatus = false;
                        }
                      },
                      child: Container(
                        width: 150,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: grad.LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFAF32C5), Color(0xFFF45176)]),
                          boxShadow: [
                            // color: Colors.white, //background color of box
                            BoxShadow(
                              color: Color(0xFFF45176).withOpacity(0.6),
                              blurRadius: 15.0, // soften the shadow
                              spreadRadius: 0.0, //extend the shadow
                              offset: Offset(
                                0.0, // Move to right 10  horizontally
                                8.0, // Move to bottom 10 Vertically
                              ),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: _formStatus
                              ? CheckMark()
                              : Text(
                                  "Sign In",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CheckMark extends StatefulWidget {
  const CheckMark({Key? key}) : super(key: key);

  @override
  _CheckMarkState createState() => _CheckMarkState();
}

class _CheckMarkState extends State<CheckMark> {
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation("show");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("rebuild");
    return SizedBox(
      height: 40,
      child: RiveAnimation.asset(
        "assets/rive/check_icon.riv",
        controllers: [_controller],
      ),
    );
  }
}
