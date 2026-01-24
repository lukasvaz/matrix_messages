import 'package:flutter/material.dart';

class TaskSettingsPage extends StatelessWidget {
  const TaskSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Tareas'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4F4F69),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            subtitle: const Text('Activar o desactivar notificaciones'),
            trailing: Switch(
              value: true,
              onChanged: (bool value) {
                // Lógica para cambiar las notificaciones
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Tema de la Aplicación'),
            subtitle: const Text('Claro u oscuro'),
            trailing: DropdownButton<String>(
              value: 'Claro',
              items: const [
                DropdownMenuItem(value: 'Claro', child: Text('Claro')),
                DropdownMenuItem(value: 'Oscuro', child: Text('Oscuro')),
              ],
              onChanged: (String? newValue) {
                // Lógica para cambiar el tema
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacidad'),
            subtitle: const Text('Opciones de privacidad'),
            onTap: () {
              // Lógica para la configuración de privacidad
            },
          ),
        ],
      ),
    );
  }
}
