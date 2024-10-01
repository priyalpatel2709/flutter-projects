import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'allobjectmodel.dart';
import 'utilites.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<AllObject> _objects = [];
  bool _isLoading = false;
  String? _error;

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the TextEditingController
    super.dispose();
  }

  void copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Center(
              child: Text(
            'Bucket Items',
            style: TextStyle(color: Colors.white),
          )),
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    labelText: 'Folder Name',
                    labelStyle: TextStyle(color: Colors.white),
                    hintText: 'test_folder',
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(
                      Icons.folder_open_outlined,
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                          _objects
                              .clear(); // Clear the list before fetching new objects
                        });

                        try {
                          List<AllObject> response =
                              await Miscellaneousfunction.fetchS3Objects(
                                  folderName: _controller.text);

                          setState(() {
                            _objects = response;
                            _isLoading = false;
                          });
                        } catch (e) {
                          setState(() {
                            _error = 'Failed to load objects. Status code';
                            _isLoading = false;
                          });
                        }
                      },

                      //  Miscellaneousfunction.fetchS3Objects(),
                      child: const Text(
                        'Get Items',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        List<String> response =
                            await Miscellaneousfunction.pickFile(
                                _controller.text);

                        if (response.isNotEmpty) {
                          setState(() {
                            _isLoading = false;
                            _error = null;
                          });
                        } else {
                          setState(() {
                            _isLoading = false;
                            _error = 'Failed to Upload objects';
                          });
                        }
                      },
                      child: const Text(
                        'Upload',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoading) const CircularProgressIndicator(),
                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _objects.length,
                      itemBuilder: (context, index) {
                        return (_objects[index].type != '.png' &&
                                _objects[index].type != '.jpg' &&
                                _objects[index].type != '.jpeg' &&
                                _objects[index].type != '.gif' &&
                                _objects[index].type != '.bmp' &&
                                _objects[index].type != '.webp')
                            ? ListTile(
                                title: Text(_objects[index].name ?? 'No name',
                                    style:
                                        const TextStyle(color: Colors.white)),
                                subtitle: InkWell(
                                  onTap: () {
                                    Miscellaneousfunction.dowonloadFile(
                                        url: _objects[index].url ?? '',
                                        name: _objects[index].name ?? '');
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            _objects[index].url ?? 'No URL',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white70)),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            copyText(_objects[index].url ??
                                                'No URL');
                                          },
                                          icon: const Icon(Icons.copy_outlined))
                                    ],
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        height: 200,
                                        width: 200,
                                        _objects[index].url ?? '',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Miscellaneousfunction.dowonloadFile(
                                              url: _objects[index].url ?? '',
                                              name: _objects[index].name ?? '');
                                        },
                                        icon: const Icon(
                                          Icons.download,
                                          color: Colors.white,
                                        ))
                                  ],
                                ),
                              ); // Display the image
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
