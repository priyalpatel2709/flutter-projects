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
                maxHeight: MediaQuery.of(context).size.height - kToolbarHeight - 24,
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
                    rows: List<DataRow>.generate(snapshot.data!.length, (index) {
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
                                onPressed: () => deleteproduct(product.sId.toString()),
                                child: Text('Delete'),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => updateproduct(product.sId.toString()),
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
