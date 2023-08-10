import 'package:flutter/material.dart';

/// Flutter code sample for [PopupMenuButton].

enum SampleItem { itemOne, itemTwo, itemThree }

class PopupMenuExample extends StatefulWidget {
  const PopupMenuExample({super.key});

  @override
  State<PopupMenuExample> createState() => _PopupMenuExampleState();
}

class _PopupMenuExampleState extends State<PopupMenuExample> {
  SampleItem? selectedMenu;

    void handleItemSelected(SampleItem item) {
    setState(() {
      selectedMenu = item;
    });

    // Perform actions based on the selected item
    switch (item) {
      case SampleItem.itemOne:
        // Perform action for Item 1
        print('Item 1 clicked');
        break;
      case SampleItem.itemTwo:
        // Perform action for Item 2
        print('Item 2 clicked');
        break;
      case SampleItem.itemThree:
        // Perform action for Item 3
        print('Item 3 clicked');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PopupMenuButton')),
      body: Center(
        child: PopupMenuButton<SampleItem>(
          initialValue: selectedMenu,
          // Callback that sets the selected popup menu item.
          onSelected: handleItemSelected,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
            const PopupMenuItem<SampleItem>(
              value: SampleItem.itemOne,
              child: Text('Item 1'),
            ),
            const PopupMenuItem<SampleItem>(
              value: SampleItem.itemTwo,
              child: Text('Item 2'),
            ),
            const PopupMenuItem<SampleItem>(
              value: SampleItem.itemThree,
              child: Text('Item 3'),
            ),
          ],
        ),
      ),
    );
  }
}
