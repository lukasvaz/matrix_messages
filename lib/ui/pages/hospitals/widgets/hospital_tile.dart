import 'package:flutter/material.dart';

class HospitalTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final VoidCallback? onTap; // Agregar un callback para la acción onTap

  const HospitalTile(
      {super.key, required this.icon, required this.name, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(6)),
        child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: Container(
                decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF4F4F69), width: 2),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.green, size: 40)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                size: 20, color: Color(0xFF999999)),
            horizontalTitleGap: 10,
            title: Text(name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                    color: Color(0xFF1A1A1A))),
            onTap: onTap));
  }
}