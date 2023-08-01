// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/productlist.dart';
import '../data/database.dart';
import '../uiti/uiti.dart';
import 'addproduct.dart';
import 'login.dart';
import 'singup.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  var productName = TextEditingController();
  var productPrice = TextEditingController();
  var productCompany = TextEditingController();
  var productCategory = TextEditingController();

  var _mybox = Hive.box('user');
  String name = '';
  String email = '';
  @override
  void initState() {
    super.initState();
    print(_mybox.get('USER'));
    var user = _mybox.get('USER') as List<dynamic>?;

    if (user != null && user.isNotEmpty) {
      name = user[0][1] as String? ?? '';
      email = user[0][2] as String? ?? '';
    }
  }

  User userinfo = User();

  Future<List<AllProductList>> getProduct() async {
    final response = await http
        .get(Uri.parse('https://srever-ecomm.vercel.app/products'));
    var data = jsonDecode(response.body.toString());
    if (response.statusCode == 200) {
      List<AllProductList> productlist = [];
      for (var i in data) {
        productlist.add(AllProductList.fromJson(i));
      }
      return productlist;
    } else {
      return [];
    }
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        elevation: 20,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
                accountName: Text(name), accountEmail: Text(email)),
            ListTile(
              leading: Icon(
                Icons.add,
              ),
              title: const Text('Add Product'),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Addproduct()));
              },
            ),
            ListTile(
                leading: Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  userinfo.clearUserData();
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Login()));
                })
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: FutureBuilder(
        future: getProduct(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var product = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text(product.name.toString()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: \$${product.price}'),
                        Text('Category: ${product.category}'),
                        Text('Company: ${product.company}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              deleteproduct(product.sId.toString()),
                          child: Text('Delete'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => updateproduct(product.name.toString(), product.price.toString(), product.category.toString(), product.company.toString(), product.sId.toString()),
                          child: Text('Update'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  deleteproduct(String id) async{
    print(id);
    try{
        final responce =await  http.delete(Uri.parse('https://srever-ecomm.vercel.app/products/$id'),);
        if(responce.statusCode == 200){
          print(responce.body);
          setState(() {
          });
        }else{
          print('error');
        }
    }catch (e){
      print(e);
    }
  }

  updateproduct(String Oname,String Oprice,String Ocategory,String ocompany,String id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update'),
          content: Container(
              // color: Colors.black,
              height: 265,
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: productName,
                    decoration:  myInput(labelText :'product Name',hintText :Oname),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: productPrice,
                    decoration:  myInput(labelText :'product Price',hintText :Oprice),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: productCompany,
                    decoration:  myInput(labelText :'product Company',hintText :ocompany),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: productCategory,
                    decoration:  myInput(labelText :'product Category',hintText :Ocategory),
                  ),
                ],
              ))),
          actions: [
            TextButton(onPressed: (){
              Navigator.of(context).pop(); 
            }, child: Text('cancle')),
            TextButton(
                onPressed: () {
                  var name = productName.text.toString();
                  var price = productPrice.text.toString();
                  var Company = productCompany.text.toString();
                  var Category = productCategory.text.toString();
                  print('object');
                  print(name ==  '');
                  print('object');

                  name == '' ? name = Oname : name = name;
                  price == '' ? price = Oprice : price = price;
                  Company == '' ? Company = ocompany : Company = Company;
                  Category == '' ? Category = Ocategory : Category = Category;
                  saveupdateproduct(
                      name,
                      price,
                      Company,
                      Category,
                      id);
                      Navigator.of(context).pop(); 
                },
                child: Text('Save'))
          ],
        );
      },
    );
  }

  void saveupdateproduct(String name, String price, String company,
      String category, String id) async {
    print('https://srever-ecomm.vercel.app/products/$id');
    try {
      final response = await http.put(
          Uri.parse('https://srever-ecomm.vercel.app/products/$id'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': name,
            'price': price,
            'category': category,
            'company': company
          }));

      if (response.statusCode == 200) {
        print(response.body);
        setState(() {});
        productName.clear();
        productPrice.clear();
        productCategory.clear();
        productCompany.clear();
      } else {
        print('wrong');
      }
    } catch (e) {
      print(e);
    }
  }
}
