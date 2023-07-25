// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_app/provider/counter_provider.dart';

import '../provider/counter_provider.dart';
import '../provider/counter_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) {
    print('asd');
    final CountProvider = Provider.of<countProvider>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Provider'),
      ),
      body: Center(
        child: Consumer<countProvider>(builder: (context, value, child) {
          return Text(value.count.toString(),style: TextStyle(fontSize: 50,fontWeight: FontWeight.w900), );
        })
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
          CountProvider.setCount();
      },
      child: Icon(Icons.add),
      elevation: 20,
      ),
    );
  }
}