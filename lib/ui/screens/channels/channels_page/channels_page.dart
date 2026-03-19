import 'package:matrix_messages/ui/screens/channels/channels_page/widgets/channels_searched_none.dart';
import 'package:matrix_messages/ui/screens/channels/channels_page/widgets/channels_empty.dart';
import 'package:matrix_messages/ui/screens/channels/channels_settings/channels_settings.dart';
import 'package:matrix_messages/ui/screens/channels/channels_page/widgets/folder_tile.dart';
import 'package:matrix_messages/ui/screens/channels/channels_page/widgets/search_by.dart';
import 'package:matrix_messages/ui/screens/channels/channels_page/widgets/room_tile.dart';
import 'package:matrix_messages/ui/screens/widgets/bottom_nav_bar_widget.dart';
import 'package:matrix_messages/ui/screens/widgets/appbar_with_settings.dart';
import 'package:matrix_messages/services/matrix/matrix_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:matrix_messages/globals.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key});

  @override
  ChannelsPageState createState() => ChannelsPageState();
}

class ChannelsPageState extends State<ChannelsPage> {
  final TextEditingController _searchController = TextEditingController();
  final MatrixService matrixService = MatrixService();
  List<Room>? _channelsRooms;
  List<Room>? _unreadRooms = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    loadChannelsRooms();
  }

  Future<void> loadChannelsRooms() async {
    
    final client = Provider.of<Client>(context, listen: false);
    var folders = matrixService.getClientRoomsInSpace(
        client, '#canales:development.host');
    print(folders?.first.tags);
    folders = folders
        ?.where((room) => room.tags.keys.contains("tlc.subscribed"))
        .toList();
    if (_channelsRooms.toString() != folders.toString()) {
      _channelsRooms = folders;
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

  List<Room> getUnreadRooms(Client client) {
    List<Room> unreadRooms = [];
    for (final room in _channelsRooms!) {
      if (room.isSpace) {
        final subRooms =
            matrixService.getClientRoomsInSpace(client, room.canonicalAlias) ??
                [];
        unreadRooms.addAll(
          subRooms.where((subRoom) =>
              subRoom.isUnread &&
              subRoom.hasNewMessages == true &&
              !subRoom.isSpace &&
              subRoom.tags.keys.contains("tlc.subscribed")),
        );
      }
    }
    return unreadRooms;
  }

  void anyRoomSubscribedInFolder(Room folder, List<dynamic> subRooms) {
    bool folderSubscribed = false;
    for (var room in subRooms) {
      if (room.tags.keys.contains('tlc.subscribed')) {
        folderSubscribed = true;
        break;
      }
    }
    if (folderSubscribed && !folder.tags.keys.contains('tlc.subscribed')) {
      folder.addTag('tlc.subscribed');
    }
    if (!folderSubscribed && folder.tags.keys.contains('tlc.subscribed')) {
      folder.removeTag('tlc.subscribed');
    }
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
        title: 'Canales',
        redirection: ChannelsSettingsPage(
            screenHeight: screenHeight, screenWidth: screenWidth),
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
            child: StreamBuilder(
                stream: client.onSync.stream,
                builder: (context, _) {
                  loadChannelsRooms();
                  final filteredChannels =
                      filterChannelsBySearch(_channelsRooms);
                  _unreadRooms = getUnreadRooms(client);

                  if (filteredChannels.isEmpty) {
                    if (_searchText.isNotEmpty) {
                      return ChannelsSearchedNone(
                          screenHeight: screenHeight, screenWidth: screenWidth);
                    }
                    return ChannelsEmpty(
                        screenHeight: screenHeight, screenWidth: screenWidth);
                  } else {
                    filteredChannels.sort((a, b) => a
                        .getLocalizedDisplayname()
                        .toLowerCase()
                        .compareTo(b.getLocalizedDisplayname().toLowerCase()));
                  }

                  return SlidableAutoCloseBehavior(
                      closeWhenOpened: true,
                      child: ListView.builder(
                          itemCount: _unreadRooms!.isNotEmpty
                              ? filteredChannels.length + 1
                              : filteredChannels.length,
                          itemBuilder: (context, i) {
                            if (_unreadRooms!.isNotEmpty && i == 0) {
                              // Carpeta de no leídos
                              return FolderTile(
                                title: "No leídos",
                                subRooms: _unreadRooms!,
                              );
                            }
                            final roomIndex =
                                _unreadRooms!.isNotEmpty ? i - 1 : i;
                            final room = filteredChannels[roomIndex];
                            if (room.isSpace) {
                              return Builder(builder: (context) {
                                final subSpaceRooms =
                                    matrixService.getClientRoomsInSpace(
                                            client, room.canonicalAlias) ??
                                        [];

                                anyRoomSubscribedInFolder(room, subSpaceRooms);

                                return FolderTile(
                                    key: Key(room.id),
                                    title: room.getLocalizedDisplayname(),
                                    subRooms: subSpaceRooms);
                              });
                            } else {
                              return RoomTile(room: room);
                            }
                          }));
                }))
      ]),
      bottomNavigationBar: BottomNavBarWidget(
          screenWidth: screenWidth, screenHeight: screenHeight, section: 2),
    );
  }
}