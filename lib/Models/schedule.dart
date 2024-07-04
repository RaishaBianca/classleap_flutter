import 'dart:convert';

class ScheduleItem {
    final String time;
    final String course;
    final String location;

    ScheduleItem({required this.time, required this.course, required this.location});

    factory ScheduleItem.fromJson(Map<String, dynamic> json) {
        return ScheduleItem(
            time: json['time'],
            course: json['course'],
            location: json['location'],
        );
    }
}

class DailySchedule {
    final List<ScheduleItem> items;

    DailySchedule({required this.items});

    factory DailySchedule.fromJson(Map<String, dynamic> json) {
        var list = json['schedule'] as List;
        List<ScheduleItem> scheduleItems = list.map((i) => ScheduleItem.fromJson(i)).toList();
        return DailySchedule(items: scheduleItems);
    }
}

class WeeklySchedule {
    final String id;
    final String major;
    final Map<String, List<ScheduleItem>> schedule;

    WeeklySchedule({required this.id, required this.major, required this.schedule});

    factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
        Map<String, List<ScheduleItem>> schedule = {};
        json['schedule'].forEach((day, items) {
            schedule[day] = (items as List).map((i) => ScheduleItem.fromJson(i)).toList();
        });
        return WeeklySchedule(
            id: json['id'],
            major: json['major'],
            schedule: schedule,
        );
    }
}

// Function to filter the schedule based on the user's NIM
List<WeeklySchedule> filterScheduleByNim(List<dynamic> jsonList, String nim) {
    String nimPrefix = nim.substring(0, 2);
    return jsonList.where((item) {
        return item['id'] == nimPrefix;
    }).map((item) => WeeklySchedule.fromJson(item)).toList();
}

class ScheduleUtils {
  static List<WeeklySchedule> filterSchedulesFromJsonString(String jsonString, String userNim) {
    List<dynamic> jsonList = json.decode(jsonString)['schedule'];
    return filterScheduleByNim(jsonList, userNim);
  }
}