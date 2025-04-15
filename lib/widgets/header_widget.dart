// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../controllers/home_controller.dart';

// class HeaderWidget extends StatelessWidget {
//   final HomeScreenController controller = Get.find();

//   HeaderWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = MediaQuery.of(context).size.width < 600;

//     return Container(
//       color: Colors.blue[800],
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           if (isMobile)
//             IconButton(
//               icon: Icon(Icons.menu, color: Colors.white),
//               onPressed: () => Scaffold.of(context).openDrawer(),
//             ),
//           Text(
//             isMobile ? 'MultiFleet' : 'MultiFleet Vehicle Management System',
//             style: TextStyle(
//                 color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           Wrap(
//             spacing: 16,
//             children: [
//               _headerNavItem('Home', 0),
//               _headerNavItem('Dashboard', 1),
//               _headerNavItem('Reports', 2),
//               _headerNavItem('Settings', 3),
//               _headerNavItem('Profile', 4),
//               ElevatedButton.icon(
//                 onPressed: () {
//                   // Implement logout logic
//                 },
//                 icon: Icon(Icons.logout, color: Colors.white),
//                 label: Text('Logout'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue[700],
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _headerNavItem(String title, int index) {
//     return TextButton(
//       onPressed: () => controller.changePage(index),
//       child: Text(title, style: TextStyle(color: Colors.white)),
//     );
//   }
// }
