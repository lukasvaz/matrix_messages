import 'package:frontend/ui/pages/tasks/task_detail/widgets/upper_card.dart';
import 'package:frontend/ui/pages/tasks/task_detail/widgets/lower_card.dart';
import 'package:frontend/services/matrix/matrix_service.dart';
import 'package:frontend/domain/entities/task.dart';
import 'package:frontend/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:frontend/ui/pages/widgets/bottom_nav_bar_widget.dart';  

class TaskDetail extends StatelessWidget {
  final Task task;
  const TaskDetail({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<Client>(context, listen: false);
    final MatrixService matrixService = MatrixService();
    final Room? room = client.getRoomById(task.matrixroomid);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<Object>(
        stream: client.onSync.stream,
        builder: (context, _) {
          return FutureBuilder<Task>(
              future: matrixService.getTaskState(room!.id, client.accessToken!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Task? task = snapshot.data;
                  DateTime? creationDate = DateTime.parse(task!.getCreationString());
                  return Scaffold(
                      appBar: PreferredSize(
                          preferredSize: Size.fromHeight(screenHeight * 0.08),
                          child: Container(
                            color: const Color(0xFFF2F2F2),
                            padding: EdgeInsets.only(
                                left: screenWidth * 0.01,
                                top: screenHeight * 0.056,
                                right: screenWidth * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.13,
                                  height: screenHeight * 0.08,
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_back_ios_rounded,
                                        color: const Color(0xFF4F4F69),
                                        size: screenWidth * 0.058),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.72,
                                  height: screenHeight * 0.08,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Detalle de la tarea',
                                        style: TextStyle(
                                          color: const Color(0xFF4F4F69),
                                          fontSize: screenWidth * 0.07,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'Lato',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.13)
                              ],
                            ),
                          )),
                      backgroundColor: const Color(0xfff2f2f2),
                      body: Column(children: [
                        const Divider(color: Color(0xFFE5E5EB), thickness: 2),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  UpperCard(
                                      task: task,
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight),
                                  const SizedBox(height: 2),
                                  LowerCard(
                                      task: task,
                                      client: client,
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight),
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.006,
                                          vertical: 4),
                                      child: Text(
                                      'Creada ${taskDateFormat(creationDate, isCreation: true)}',
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.031,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'OpenSans',
                                              letterSpacing: 0,
                                              color: const Color(0xFF1A1A1A)))),
                                ]))
                      ]), 
                      bottomNavigationBar: BottomNavBarWidget(screenWidth: screenWidth, screenHeight: screenHeight, section: 1),  
                      );
                } else {
                  return const Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF4F4F69))));
                }
              });
        });
  }
}