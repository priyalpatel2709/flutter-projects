// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import '../uiti/uiti.dart';
import 'product__list.dart';

class Addproduct extends StatefulWidget {
  const Addproduct({Key? key}) : super(key: key);

  @override
  _AddproductState createState() => _AddproductState();
}

class _AddproductState extends State<Addproduct> {
  var _mybox = Hive.box('user');
  var _id = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      var user = _mybox.get('USER') as List<dynamic>?; 
          if (user != null && user.isNotEmpty) {
      _id = user[0][0] as String? ?? ''; 
     
    }

  }
  var productName = TextEditingController();
  var productPrice = TextEditingController();
  var productCompany = TextEditingController();
  var productCategory = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: productName,
              decoration:  myInput(labelText :'product Name'),
            ),
            SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              controller: productPrice,
              decoration:  myInput(labelText :'product Price'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: productCompany,
              decoration:  myInput(labelText :'product Company'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: productCategory,
              decoration:  myInput(labelText :'product Category'),
            ),
            SizedBox(height: 12),
            ElevatedButton(onPressed: (){
              addProduct(productName.text.toString(),productPrice.text.toString(),productCompany.text.toString(),productCategory.text.toString());
            }, child: Text('Add Product'))
          ],
        ),
      ),
    ));
  }
  
  void addProduct(String name, String price, String company, String category) async {
      try{
        final responce = await http.post(Uri.parse('https://srever-ecomm.vercel.app/add-product'),
         headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name' : name,
          'price': price,
          'category' : category,
          'company' : company,
          'userId' : _id
        })
        );

        if(responce.statusCode == 200){
          print(responce.body);
          productCategory.clear();
          productCompany.clear();
          productPrice.clear();
          productName.clear();
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ProductList()));
            setState(() {
              
            });
        }

      }catch (e){
          print(e);
      }
  }
}
