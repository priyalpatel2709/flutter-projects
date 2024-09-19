// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../models/iItems_details_model.dart';
// import '../providers/items_details_provider.dart';
// import '../providers/order_item_state_provider.dart';
// import 'widgets/itemcart.dart';

// class StationScreen extends StatefulWidget {
//   const StationScreen({Key? key}) : super(key: key);

//   @override
//   _StationScreenState createState() => _StationScreenState();
// }

// class _StationScreenState extends State<StationScreen> {
//   int? selectedKdsId;
//   String _activeFilter = 'In Progress'; // Default filter

//   @override
//   void initState() {
//     super.initState();
//     final kdsProvider = Provider.of<KDSItemsProvider>(context, listen: false);
//     kdsProvider.startFetching(timerInterval: 10, storeId: 1);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<KDSItemsProvider>(
//       builder: (context, kdsProvider, child) {
//         return Scaffold(
//           appBar: AppBar(
//             backgroundColor: Colors.amber,
//             title: Text('Station $_activeFilter'),
//             centerTitle: true,
//             actions: [
//               PopupMenuButton<String>(
//                 onSelected: _setFilter,
//                 itemBuilder: (BuildContext context) {
//                   return <String>[
//                     'In Queue',
//                     'In Progress',
//                     'Done',
//                     'Cancel',
//                   ].map((String filter) {
//                     return PopupMenuItem<String>(
//                       value: filter,
//                       child: Text(filter),
//                     );
//                   }).toList();
//                 },
//               ),
//             ],
//           ),
//           body: LayoutBuilder(
//             builder: (BuildContext context, BoxConstraints constraints) {
//               if (constraints.maxWidth >= 1200) {
//                 return _buildLargeScreenLayout(kdsProvider);
//               } else if (constraints.maxWidth >= 600) {
//                 return _buildMediumScreenLayout(kdsProvider);
//               } else {
//                 return _buildSmallScreenLayout(kdsProvider);
//               }
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLargeScreenLayout(KDSItemsProvider kdsProvider) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 1,
//           child: _buildStationSelector(kdsProvider),
//         ),
//         Expanded(
//           flex: 3,
//           child: Column(
//             children: [
//               Expanded(
//                 child: _buildItemList(kdsProvider),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMediumScreenLayout(KDSItemsProvider kdsProvider) {
//     return Column(
//       children: [
//         _buildStationSelector(kdsProvider),
//         Expanded(
//           child: _buildItemList(kdsProvider),
//         ),
//       ],
//     );
//   }

//   Widget _buildSmallScreenLayout(KDSItemsProvider kdsProvider) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           _buildStationSelector(kdsProvider),
//           _buildItemList(kdsProvider),
//         ],
//       ),
//     );
//   }

//   Widget _buildStationSelector(KDSItemsProvider kdsProvider) {
//     if (kdsProvider.stationsError.isNotEmpty) {
//       return Center(child: Text(kdsProvider.stationsError));
//     }

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: DropdownButton<int>(
//         isExpanded: true,
//         hint: const Text('Select Station'),
//         value: selectedKdsId,
//         onChanged: (int? value) {
//           setState(() {
//             selectedKdsId = value;
//             if (value != null) {
//               kdsProvider.updateFilters(
//                 isInProgress: true,
//                 kdsId: value, // Apply kdsId filter
//               );
//             }
//           });
//         },
//         items: kdsProvider.stations.map<DropdownMenuItem<int>>((station) {
//           return DropdownMenuItem<int>(
//             value: station.kdsId,
//             child: Text(station.name.toString()),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildItemList(KDSItemsProvider kdsProvider) {
//     if (selectedKdsId == null) {
//       return const Center(
//           child: Text('Please select a station to filter items'));
//     }

//     return SizedBox(
//       height: MediaQuery.of(context).size.height * 0.75,
//       child: ItemCart(
//         items: kdsProvider.filteredItems,
//         orderItemStateProvider: Provider.of<OrderItemStateProvider>(context),
//       ),
//     );
//   }

//   void _setFilter(String filter) {
//     setState(() {
//       _activeFilter = filter;
//       // Apply corresponding filter based on selected option
//       switch (filter) {
//         case 'In Queue':
//           Provider.of<KDSItemsProvider>(context, listen: false).updateFilters(
//             isQueue: true,
//             // isInprogress: false,
//             isInProgress: false,
//             isDone: false,
//             isCancel: false,
//             kdsId: selectedKdsId,
//           );
//           break;
//         case 'In Progress':
//           Provider.of<KDSItemsProvider>(context, listen: false).updateFilters(
//             isQueue: false,
//             isInProgress: true,
//             isDone: false,
//             isCancel: false,
//             kdsId: selectedKdsId,
//           );
//           break;
//         case 'Done':
//           Provider.of<KDSItemsProvider>(context, listen: false).updateFilters(
//             isQueue: false,
//             isInProgress: false,
//             isDone: true,
//             isCancel: false,
//             kdsId: selectedKdsId,
//           );
//           break;
//         case 'Cancel':
//           Provider.of<KDSItemsProvider>(context, listen: false).updateFilters(
//             isQueue: false,
//             isInProgress: false,
//             isDone: false,
//             isCancel: true,
//             kdsId: selectedKdsId,
//           );
//           break;
//       }
//     });
//   }
// }
