import 'package:flutter/material.dart';
import 'package:matrix_messages/domain/entities/task.dart';
import 'package:matrix_messages/ui/screens/widgets/secondary_button.dart';
import 'package:matrix_messages/ui/screens/widgets/primary_button.dart';
import 'package:matrix_messages/ui/screens/widgets/tertiary_button.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class ButtonLayout extends StatelessWidget {
  final Task task;
  final bool isBlocked;
  final double screenWidth;
  final double screenHeight;

  const ButtonLayout(
      {super.key,
      required this.task,
      required this.isBlocked,
      required this.screenWidth,
      required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<Client>(context, listen: false);
    Widget renderWidget() {
      // Group Tasks specific cases
      if (task.isGroupTask()) {
        if (task.getCurrentState() == 'Creada' &&
            task.getAssignedUser() == "") {
          return PrimaryButton(
            string: "Asignarme tarea",
            width: screenWidth * 0.9,
            height: 20,
            borderRadius: 16.0,
            onPressed: () {
              task.takeGroupTask(client);
            },
          );
        }
        if (task.getAssignedUser() != client.userID) {
          return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            TertiaryButton(
              string: "Asignarme tarea",
              width: screenWidth * 0.8,
              height: 20,
              fontSize: screenWidth * 0.036,
              isBlocked: true,
              onPressed: () {},
            ),
          ]);
        }
        if (task.getCurrentState() == 'Asignada' &&
            task.getAssignedUser() == client.userID) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SecondaryButton(
                  string: "Desasignarme tarea",
                  width: screenWidth * 0.42,
                  fontSize: screenWidth * 0.036,
                  height: 20,
                  onPressed: () {
                    task.dropGroupTask(client);
                  },
                ),
                PrimaryButton(
                  string: "Iniciar tarea",
                  width: screenWidth * 0.4,
                  fontSize: screenWidth * 0.036,
                  height: 20,
                  onPressed: () {
                    task.toNextState(client);
                  },
                )
              ]);
        }
      }
      // Individual Tasks specific casess
      if (!task.isGroupTask() &&
          task.getCurrentState() == 'Asignada' &&
          task.getAssignedUser() == client.userID) {
        return PrimaryButton(
            string: "Iniciar tarea",
            width: screenWidth * 0.9,
            height: 20,
            fontSize: screenWidth * 0.036,
            borderRadius: 16.0,
            onPressed: () {
              task.toNextState(client);
            });
      }
      // Common Cases
      if (task.getCurrentState() == 'En Curso' &&
          task.getAssignedUser() == client.userID) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SecondaryButton(
                string: "Deshacer",
                width: screenWidth * 0.41,
                height: 20,
                fontSize: screenWidth * 0.036,
                onPressed: () {
                  task.toPreviousState(client);
                },
              ),
              PrimaryButton(
                string: "Completar tarea",
                width: screenWidth * 0.41,
                fontSize: screenWidth * 0.036,
                height: 20,
                onPressed: () {
                  task.toNextState(client);
                },
              )
            ]);
      }
      if (task.getCurrentState() == 'Completada' &&
          task.getAssignedUser() == client.userID) {
        return isBlocked
            ? TertiaryButton(
                string: "Reabrir tarea",
                width: screenWidth * 0.9,
                fontSize: screenWidth * 0.036,
                height: 20,
                isBlocked: true,
                onPressed: () {},
              )
            : TertiaryButton(
                string: "Reabrir tarea",
                width: screenWidth * 0.9,
                fontSize: screenWidth * 0.036,
                onPressed: () {
                  task.toPreviousState(client);
                },
              );
      }
      return const SizedBox();
    }

    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.008),
            // conditional text
            child: task.isGroupTask() &&
                    task.getAssignedUser() != client.userID &&
                    task.getAssignedUser() != ""
                ? SizedBox(
                    width: screenWidth * 0.8,
                    child: Text("Otra persona ya se asignó la tarea.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color(0xff939393),
                            fontSize: screenWidth * 0.031,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'OpenSans')),
                  )
                : isBlocked
                    ? SizedBox(
                        width: screenWidth * 0.52,
                        child: Text(
                            "Ha pasado el tiempo permitido para reabrir la tarea.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: const Color(0xff939393),
                                fontSize: screenWidth * 0.031,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'OpenSans')),
                      )
                    : SizedBox(
                        height: screenHeight * 0.032,
                      )),
        renderWidget(),
      ],
    );
  }
}
