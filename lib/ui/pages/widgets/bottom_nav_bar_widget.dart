import 'package:frontend/ui/pages/channels/channels_page/channels_page.dart';
import 'package:frontend/ui/pages/tasks/task_page/task_page.dart';
import 'package:frontend/ui/pages/widgets/bottom_nav_item.dart';
import 'package:frontend/ui/pages/profile/profile.dart';
import 'package:flutter/material.dart';

class BottomNavBarWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final int section;

  const BottomNavBarWidget(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      required this.section});

  List<Widget> getTargetSections() {
    return [const ProfilePage(), const TaskPage(), const ChannelsPage()];
  }

  // Método para realizar la navegación según la sección seleccionada
  void onItemTapped(BuildContext context, targetSection) {
    if (section != targetSection) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => getTargetSections()[targetSection]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        color: const Color(0xFFF2F2F4),
        padding: EdgeInsets.zero,
        height: screenHeight / screenWidth * 36,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Divider(color: Color(0xffdcdcdc), height: 0, thickness: 1),
              Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight / screenWidth * 3),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        BottomNavItem(
                            icon: Icons.home,
                            label: "Inicio",
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            isSelected: section == 0,
                            onTap: () {
                              onItemTapped(context, 0); // Realiza la navegación
                            }),
                        BottomNavItem(
                            icon: Icons.task_outlined,
                            label: "Mis Tareas",
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            isSelected: section == 1,
                            onTap: () {
                              onItemTapped(context, 1); // Realiza la navegación
                            }),
                        BottomNavItem(
                            icon: Icons.chat_bubble,
                            label: "Canales",
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            isSelected: section == 2,
                            onTap: () {
                              onItemTapped(context, 2); // Realiza la navegación
                            })
                      ]))
            ]));
  }
}
