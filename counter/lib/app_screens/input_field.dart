import 'package:flutter/material.dart';
import '../ui_helper/utli.dart';

class InputField extends StatelessWidget {
  // const InputField({Key? key}) : super(key: key);

  var useremail = TextEditingController();
  var userpassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: useremail,
            decoration: InputDecoration(
              hintText: 'Enter yous Email...',
              labelText: 'Hello',
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Colors.green, width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Color.fromARGB(255, 243, 12, 12), width: 2)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Color.fromARGB(255, 87, 82, 82), width: 2)),
              suffixIcon: Icon(Icons.email),
              prefixIcon: Icon(Icons.person)

            ),
          ),
          Container(
            height: 11,
          ),
          TextField(
              // enabled: false,
              controller: userpassword,
              obscureText: true,
              
              decoration: InputDecoration(
                  hintText: 'Enter your Password...',
                  focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: Colors.green, width: 2)),
                  enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: Color.fromARGB(255, 243, 12, 12), width: 2)),
                  disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: Color.fromARGB(255, 87, 82, 82), width: 2)),
                  suffix: IconButton(
                    icon: Icon(Icons.remove_red_eye),
                    onPressed: () {
                    print('show password');
                
                  },)  ,      
                  prefixIcon: Icon(Icons.lock)
          )
          ),
          ElevatedButton(onPressed: (){
            var uemali = useremail.text.toString();
            var upass = userpassword.text;
            print('user email is $uemali and password is $upass');
          }, child: Text('Login'))
        ],
      ),
    ));
  }
}
