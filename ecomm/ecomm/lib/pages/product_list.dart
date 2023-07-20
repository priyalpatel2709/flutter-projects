// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Models/productlist.dart';

class ProductList extends StatelessWidget {
  ProductList({ Key? key }) : super(key: key);

  List<AllProductList> productlist = [];

  Future<List<AllProductList>> getProduct() async {
      final responce = await http.get(Uri.parse('https://srever-ecomm.vercel.app/products'));
      var data = jsonDecode(responce.body.toString());
      if(responce.statusCode == 200){
        for(var i in data){
          productlist.add(AllProductList.fromJson(i));
        }
        return productlist;
      }else{
        return productlist;
      }
      
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
      future: getProduct(),
      builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }else{
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var product = snapshot.data![index];
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ListTile(
                  title: Row(
                    children: [
                      Container(
                        width: 88.25,
                        child: Text(product.name.toString())
                      ),
                      Container(
                        width: 87.25,
                        child: Text(product.price.toString())
                      ),
                      Container(
                        width: 88.25,
                        child: Text(product.category.toString())
                      ),
                      Container(
                        width: 88.25,
                        child: Text(product.company.toString())
                      ),
                      ]
                  ),
                  )
              ); 
                },
                );
        }
    }
    );
  }
}