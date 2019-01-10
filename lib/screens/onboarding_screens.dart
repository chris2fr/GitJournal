import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journal/storage/git.dart';

class OnBoardingScreen extends StatelessWidget {
  final Function onBoardingCompletedFunction;

  OnBoardingScreen(this.onBoardingCompletedFunction);

  @override
  Widget build(BuildContext context) {
    var pageController = PageController();
    var pageView = PageView(
      controller: pageController,
      children: <Widget>[
        OnBoardingGitUrl(doneFunction: (String sshUrl) {
          pageController.nextPage(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );

          SharedPreferences.getInstance().then((SharedPreferences pref) {
            pref.setString("sshCloneUrl", sshUrl);
          });
        }),
        OnBoardingSshKey(doneFunction: () {
          pageController.nextPage(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        }),
        OnBoardingGitClone(
          doneFunction: this.onBoardingCompletedFunction,
        ),
      ],
    );

    return new Scaffold(
      body: new Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: pageView,
      ),
    );
  }
}

class OnBoardingGitUrl extends StatefulWidget {
  final Function doneFunction;

  OnBoardingGitUrl({@required this.doneFunction});

  @override
  OnBoardingGitUrlState createState() {
    return new OnBoardingGitUrlState(doneFunction: this.doneFunction);
  }
}

class OnBoardingGitUrlState extends State<OnBoardingGitUrl> {
  final Function doneFunction;

  final GlobalKey<FormFieldState<String>> sshUrlKey =
      GlobalKey<FormFieldState<String>>();

  OnBoardingGitUrlState({@required this.doneFunction});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    var inputForm = Form(
      key: _formKey,
      child: TextFormField(
        key: sshUrlKey,
        textAlign: TextAlign.center,
        autofocus: true,
        style: Theme.of(context).textTheme.title,
        decoration: const InputDecoration(
          hintText: 'Eg: git@github.com:GitJournal/GitJournal.git',
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter some text';
          }
          if (value.startsWith('https://') || value.startsWith('http://')) {
            return 'Only SSH urls are currently accepted';
          }

          RegExp regExp = new RegExp(r"[a-zA-Z0-9.]+@[a-zA-Z0-9.]+:.+");
          if (!regExp.hasMatch(value)) {
            return "Invalid Input";
          }
        },
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'Enter the Git SSH URL',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
        inputForm,
        RaisedButton(
          child: Text("Next"),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              var url = sshUrlKey.currentState.value;
              this.doneFunction(url);
            } else {}
          },
        )
      ],
    );
  }
}

class OnBoardingSshKey extends StatefulWidget {
  final Function doneFunction;

  OnBoardingSshKey({@required this.doneFunction});

  @override
  OnBoardingSshKeyState createState() {
    return new OnBoardingSshKeyState(doneFunction: this.doneFunction);
  }
}

class OnBoardingSshKeyState extends State<OnBoardingSshKey> {
  final Function doneFunction;

  String publicKey = "Generating ...";

  OnBoardingSshKeyState({@required this.doneFunction});

  void initState() {
    super.initState();
    generateSSHKeys(comment: "GitJournal").then((String _publicKey) {
      setState(() {
        print("Changing the state");
        publicKey = _publicKey;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'Deploy Public Key',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          publicKey,
          textAlign: TextAlign.left,
          maxLines: 20,
          style: Theme.of(context).textTheme.body1,
        ),
        RaisedButton(
          child: Text("Start Clone"),
          onPressed: this.doneFunction,
        )
      ],
    );
  }
}

class OnBoardingGitClone extends StatefulWidget {
  final Function doneFunction;

  OnBoardingGitClone({@required this.doneFunction});

  @override
  OnBoardingGitCloneState createState() {
    return new OnBoardingGitCloneState(doneFunction: this.doneFunction);
  }
}

class OnBoardingGitCloneState extends State<OnBoardingGitClone> {
  final Function doneFunction;
  String errorMessage = "";

  OnBoardingGitCloneState({@required this.doneFunction});

  @override
  void initState() {
    super.initState();
    _initStateAsync();
  }

  void _initStateAsync() async {
    var pref = await SharedPreferences.getInstance();
    String sshCloneUrl = pref.getString("sshCloneUrl");

    String error = await gitClone(sshCloneUrl, "journal");
    if (error != null && error.isNotEmpty) {
      setState(() {
        errorMessage = error;
      });
    } else {
      doneFunction();
    }
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    if (this.errorMessage.isEmpty) {
      children = <Widget>[
        Text(
          'Cloning ...',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
        CircularProgressIndicator(
          value: null,
        ),
      ];
    } else if (this.errorMessage.isNotEmpty) {
      children = <Widget>[
        Text(
          'Failed',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          this.errorMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
      ];
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}