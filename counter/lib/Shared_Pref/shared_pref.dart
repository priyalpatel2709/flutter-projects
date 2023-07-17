import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref extends StatefulWidget {
  const SharedPref({ Key? key }) : super(key: key);

  @override
  _SharedPrefState createState() => _SharedPrefState();
}

class _SharedPrefState extends State<SharedPref> {


  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getvalue();
  }
  var nameValue = 'no data';
  var passwordValue = 'no data';
  var emailValue = 'no data';
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
              ),

              TextField(
                controller: emailController,
              ),
              TextField(
                controller: passwordController,
              ),
              ElevatedButton(onPressed: () async{
                var pref =await SharedPreferences.getInstance();

                pref.setString('userName', nameController.text.toString());
                pref.setString('userPassword', passwordController.text.toString());
                pref.setString('userEmail', emailController.text.toString());
      
              },
              child: Text('Save'),),
              Text(nameValue),
              Text(emailValue),
              Text(passwordValue),
            ],
          ),
      )
    );
  }


void getvalue() async{

  var pref =await SharedPreferences.getInstance();

  var preName = pref.getString('userName');
  var userPassword = pref.getString('userPassword');
  var userEmail = pref.getString('userEmail');

  nameValue = preName ?? 'no name';
  passwordValue = userPassword ?? 'no Passwod';
  emailValue = userEmail ?? 'no Email';

  setState(() {
    
  });

}
}

