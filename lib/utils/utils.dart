String taskDateFormat(DateTime date, {bool isCreation = false}) {
  DateTime now = DateTime.now();

  String dayFormatted;
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    dayFormatted = isCreation ? "hoy" : "Hoy";
  } else if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day - 1) {
    dayFormatted = isCreation ? "ayer" : "Ayer";
  } else {
    dayFormatted =
        "${isCreation ? "el" : ""} ${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2).padLeft(2, '0')}";
  }

  String hourFormatted =
      "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}${isCreation ? "hrs." : ""}";

  return "$dayFormatted, a las $hourFormatted";
}
