// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Models/productlist.dart';

class ProductList extends StatelessWidget {
  ProductList({Key? key}) : super(key: key);

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
              itemCount: snapshot.data!.length + 1, // +1 for header row
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Header Row
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text('Name')),
                          Expanded(child: Text('Price')),
                          Expanded(child: Text('Category')),
                          Expanded(child: Text('Company')),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Data Rows
                  var product = snapshot.data![index - 1];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded( child: Text(product.name.toString())),
                          Expanded(child: Text(product.price.toString())),
                          Expanded(child: Text(product.category.toString())),
                          Expanded(child: Text(product.company.toString())),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      )
    );
  }
}
