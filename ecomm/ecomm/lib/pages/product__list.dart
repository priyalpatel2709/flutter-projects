// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/productlist.dart';
import '../data/database.dart';
import 'addproduct.dart';
import 'login.dart';
import 'singup.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
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
    final response =
        await http.get(Uri.parse('https://srever-ecomm.vercel.app/products'));
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
            UserAccountsDrawerHeader(accountName: Text(name), accountEmail: Text(email)),
             ListTile(leading: Icon(Icons.add, ),title: const Text('Add Product'),
             onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Addproduct()));
              },
            ),
            ListTile(leading:  Icon(Icons.logout),title: const Text('Logout'),
              onTap: () {
                userinfo.clearUserData();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
              }
            )
                
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
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height - kToolbarHeight - 24,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Company')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows:
                        List<DataRow>.generate(snapshot.data!.length, (index) {
                      var product = snapshot.data![index];
                      return DataRow(
                        cells: [
                          DataCell(Text(product.name.toString())),
                          DataCell(Text(product.price.toString())),
                          DataCell(Text(product.category.toString())),
                          DataCell(Text(product.company.toString())),
                          DataCell(Row(
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    deleteproduct(product.sId.toString()),
                                child: Text('Delete'),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () =>
                                    updateproduct(product.sId.toString()),
                                child: Text('Update'),
                              ),
                            ],
                          )),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  deleteproduct(String id) {
    print(id);
  }

  updateproduct(String id) {
    print(id);
  }
}
