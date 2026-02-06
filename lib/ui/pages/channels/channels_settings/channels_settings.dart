import 'package:matrix_messages/ui/pages/channels/channels_page/widgets/channels_searched_none.dart';
import 'package:matrix_messages/ui/pages/channels/channels_page/widgets/channels_empty.dart';
import 'package:matrix_messages/ui/pages/channels/channels_page/widgets/search_by.dart';
import 'package:matrix_messages/ui/pages/channels/channels_settings/widgets/subscription_folder_tile.dart';
import 'package:matrix_messages/ui/pages/channels/channels_settings/widgets/subscription_room_tile.dart';
import 'package:matrix_messages/ui/pages/widgets/appbar_with_settings.dart';
import 'package:matrix_messages/services/matrix/matrix_service.dart';
import 'package:provider/provider.dart';
import 'package:matrix_messages/globals.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class ChannelsSettingsPage extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;

  const ChannelsSettingsPage(
      {super.key, required this.screenHeight, required this.screenWidth});

  @override
  ChannelsSettingsPageState createState() => ChannelsSettingsPageState();
}

class ChannelsSettingsPageState extends State<ChannelsSettingsPage> {
  final TextEditingController _searchController = TextEditingController();
  final MatrixService matrixService = MatrixService();
  List<Room>? _channelsRooms;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    loadChannelsRooms();
  }

  void loadChannelsRooms() {
    final client = Provider.of<Client>(context, listen: false);
    final rooms = matrixService.getClientRoomsInSpace(
        client, '#Canales:matrix1.lahuen.health');
    if (_channelsRooms.toString() != rooms.toString()) {
      // Si hay alguna sala o carpeta nueva o eliminada
      _channelsRooms = rooms;
    }
  }

  // Filtrar las salas por el texto de búsqueda
  List<Room> filterChannelsBySearch(List<Room>? channels) {
    return _channelsRooms!
        .where((room) => room
            .getLocalizedDisplayname()
            .toLowerCase()
            .contains(_searchText.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<Client>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (_channelsRooms == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBarWithSettings(
          screenHeight: screenHeight,
          screenWidth: screenWidth,
          title: 'Configuración de Canales',
          fontSize: screenWidth * 0.05,
          hasBackArrow: true,
        ),
        body: Column(children: [
          // Buscador en la parte superior
          SearchBy(
              searchController: _searchController,
              searchText: _searchText,
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              onTextChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchText = '';
                  _searchController.clear();
                });
              }),

          Expanded(
              child: _channelsRooms!.isEmpty
                  ? ChannelsEmpty(
                      screenHeight: screenHeight, screenWidth: screenWidth)
                  : StreamBuilder(
                      stream: client.onSync.stream,
                      builder: (context, _) {
                        // Actualizar las salas y luego filtrar por el texto de búsqueda, para luego ordenarlas alfabéticamente
                        loadChannelsRooms();
                        final filteredChannels =
                            filterChannelsBySearch(_channelsRooms);

                        if (filteredChannels.isEmpty) {
                          return ChannelsSearchedNone(
                              screenHeight: screenHeight,
                              screenWidth: screenWidth);
                        } else {
                          filteredChannels.sort((a, b) => a
                              .getLocalizedDisplayname()
                              .toLowerCase()
                              .compareTo(
                                  b.getLocalizedDisplayname().toLowerCase()));
                        }
                        final folders = filteredChannels
                            .where((room) => room.isSpace)
                            .toList();
                        final individualRooms = folders
                            .expand((folder) =>
                                matrixService.getClientRoomsInSpace(
                                    client, folder.canonicalAlias) ??
                                [])
                            .where((room) => !room.isSpace)
                            .toList();

                        final mergedList = [...folders, ...individualRooms];
                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: mergedList.length,
                                itemBuilder: (context, i) {
                                  final room = mergedList[i];
                                  if (room.isSpace) {
                                    final subSpaceRooms =
                                        matrixService.getClientRoomsInSpace(
                                                client, room.canonicalAlias) ??
                                            [];
                                    return SubscriptionFolderTile(
                                      title: room.getLocalizedDisplayname(),
                                      subRooms: subSpaceRooms,
                                      folder: room,
                                      onRoomTap: (subRoom) => {},
                                    );
                                  } else {
                                    return SubscriptionRoomTile(
                                      room: room,
                                    );
                                  }
                                },
                              ),
                            )
                          ],
                        );
                      }))
        ]));
  }
}
