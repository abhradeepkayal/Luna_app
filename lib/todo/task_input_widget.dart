import 'dart:io';
import 'package:flutter/material.dart';
import 'task_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
//import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'task_firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class TaskInputWidget extends StatefulWidget {
  final Function(List<Task>) onTaskListChanged;
  final String selectedCategory;
  const TaskInputWidget({
    super.key,
    required this.onTaskListChanged,
    required this.selectedCategory,
  });

  @override
  State<TaskInputWidget> createState() => _TaskInputWidgetState();
}

class _TaskInputWidgetState extends State<TaskInputWidget> {
  bool isListening = false;
  final TextEditingController controller = TextEditingController();
  List<Task> tasks = [];
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final SpeechToText _speech = SpeechToText();
  String _filter = 'All';
  late TaskFirestoreService _firestoreService;
  double _temperature = 1.0;

  Map<String, bool> optionsVisible = {};
  Map<String, bool> subtasksVisible = {};

  @override
  void initState() {
    super.initState();
    _firestoreService = TaskFirestoreService();
    _speech.initialize();

    // 1) Initialize local notifications plugin.
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      // for iOS < 10 you can also handle onDidReceiveLocalNotification here
    );
    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: (response) {
        // tapped notification
      },
    );

    // 2) Request permissions on both platforms
    _requestNotificationPermissions();

    // 3) Initialize time zones and set local zone
    tz.initializeTimeZones();
    //FlutterNativeTimezone.getLocalTimezone().then((zone) {
    //  tz.setLocalLocation(tz.getLocation(zone));
    //});

    // Listen for task updates.
    _firestoreService.getTasksStream().listen((firebaseTasks) {
      setState(() => tasks = firebaseTasks);
      widget.onTaskListChanged(firebaseTasks);
    });
  }

  Future<void> _requestNotificationPermissions() async {
  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);
  } else if (Platform.isAndroid) {
    final bool? granted = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
    // you can check granted if you want
  }
}


  Future<String?> getUserUid() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  void _toggleMic() async {
    if (!isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => isListening = true);
        _speech.listen(onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords;
          });
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Speech recognition not available")),
        );
      }
    } else {
      setState(() => isListening = false);
      _speech.stop();
    }
  }

  int _findOriginalIndexById(String id) {
    return tasks.indexWhere((task) => task.id == id);
  }

  _toggleComplete(String id) async {
    final index = tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      bool newState = !tasks[index].isCompleted;
      setState(() {
        tasks[index].isCompleted = newState;
        for (var sub in tasks[index].subtasks) {
          sub['isCompleted'] = newState;
        }
      });
      await _firestoreService.updateTask(tasks[index]);
      await _firestoreService.updateTaskWithSubtasks(tasks[index].id, tasks[index].subtasks);
    }
  }

  _editTask(String id) {
    int index = tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;
    TextEditingController editController =
        TextEditingController(text: tasks[index].title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Task"),
        content: TextField(controller: editController),
        actions: [
          TextButton(
            onPressed: () async {
              tasks[index].title = editController.text;
              await _firestoreService.updateTask(tasks[index]);
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  _deleteTask(String id) async {
    final index = tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      try {
        await _firestoreService.deleteTask(id);
        setState(() {
          tasks.removeAt(index);
          optionsVisible.remove(id);
          subtasksVisible.remove(id);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Task deleted')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
      }
    }
  }



  /// Schedules a one‑time reminder at [dateTime].
Future<void> scheduleReminder(
    String taskId,
    String taskTitle,
    DateTime dateTime,
  ) async {
  if (dateTime.isBefore(DateTime.now())) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reminder time must be in the future.")),
    );
    return;
  }

  final int notifId = taskId.hashCode;

  await flutterLocalNotificationsPlugin.zonedSchedule(
    notifId,
    '🔔 Task Reminder',
    taskTitle,
    tz.TZDateTime.from(dateTime, tz.local),
    NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel',
        'Task Reminders',
        channelDescription: 'Reminders for your tasks',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}


  Future<void> _pickReminderTime(Task task) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    await scheduleReminder(task.id, task.title, scheduled);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder set for "${task.title}" at ${time.format(context)}',
        ),
      ),
    );
  }
  _addTask(String title) async {
    if (title.isEmpty) return;

    String? uid = await getUserUid();
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User is not authenticated")),
      );
      return;
    }

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: DateTime.now(),
      category: widget.selectedCategory == 'All'
          ? 'Uncategorized'
          : widget.selectedCategory,
      uid: uid,
      subtasks: [],
    );

    if (tasks.any((task) => task.id == newTask.id)) {
      return; // Prevent adding duplicate tasks
    }

    await _firestoreService.addTask(newTask);
    // setState(() {
    //   tasks.add(newTask);
    // });
    controller.clear();
  }

  Future<void> _getAIBreakdown(int index) async {
    final task = tasks[index];
    int wordCount = task.title.trim().split(RegExp(r'\s+')).length;
    bool isComplex = wordCount >= 3;
    int desiredSubtasks = isComplex
        ? _temperature.round() + 2
        : (2 + ((_temperature - 1) * (4 / 9))).round();
    if (desiredSubtasks < 2) desiredSubtasks = 2;
    if (desiredSubtasks > 8) desiredSubtasks = 8;

    final generativeModel = FirebaseVertexAI.instance.generativeModel(
      model: 'models/gemini-2.0-flash-001',
    );

    try {
      final content = [
        Content.text(
          "Break down this task into $desiredSubtasks comma-separated subtasks: ${task.title}",
        )
      ];
      final response = await generativeModel.generateContent(content);
      final breakdown = response.text;
      if (!mounted) return;

      List<Map<String, dynamic>> subtaskMaps = breakdown
              ?.split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .map((sub) => {'title': sub, 'isCompleted': false})
              .toList() ??
          [];
      setState(() {
        task.subtasks = subtaskMaps;
      });
      await _firestoreService.updateTaskWithSubtasks(task.id, task.subtasks);
    } catch (e) {
      // Handle error gracefully.
    }
  }

  void _generateSubtasks(int index) async {
    await _getAIBreakdown(index);
  }

  _toggleSubtaskCompletion(Task task, int subIndex) async {
    setState(() {
      task.subtasks[subIndex]['isCompleted'] =
          !(task.subtasks[subIndex]['isCompleted'] as bool);
      bool allSubtasksComplete =
          task.subtasks.every((sub) => sub['isCompleted'] as bool);
      task.isCompleted = allSubtasksComplete;
    });
    await _firestoreService.updateTaskWithSubtasks(task.id, task.subtasks);
    await _firestoreService.updateTask(task);
  }

  List<Task> _filteredTasks() {
    var filtered = tasks;
    if (_filter == 'Completed') {
      filtered = filtered.where((task) => task.isCompleted).toList();
    } else if (_filter == 'Pending') {
      filtered = filtered.where((task) => !task.isCompleted).toList();
    }
    if (widget.selectedCategory != 'All') {
      filtered = filtered
          .where((task) => task.category == widget.selectedCategory)
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth * 0.06;
    double iconSpacing = screenWidth * 0.02;

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () {
        setState(() {
          optionsVisible.clear();
          subtasksVisible.clear();
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white70),
                  controller: controller,
                  onSubmitted: (value) => _addTask(value.trim()),
                  decoration: const InputDecoration(
                    hintText: "Add a task",
                    hintStyle: TextStyle(color: Colors.white30),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: "Add Task",
                icon: Icon(Icons.add, color: Colors.white70, size: iconSize),
                onPressed: () => _addTask(controller.text.trim()),
              ),
              IconButton(
                tooltip: isListening ? "Stop Voice Input" : "Start Voice Input",
                icon: Icon(
                  Icons.mic,
                  color: isListening ? Colors.redAccent : Colors.white70,
                  size: iconSize,
                ),
                onPressed: _toggleMic,
              ),
            ],
          ),
          // Temperature slider for AI breakdown complexity
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Breakdown Complexity",
                  style: TextStyle(color: Colors.white60),
                ),
                Row(
                  children: [
                    const Text("Simpler", style: TextStyle(color: Colors.white38)),
                    Expanded(
                      child: Slider(
                        value: _temperature,
                        onChanged: (value) {
                          setState(() {
                            _temperature = value;
                          });
                        },
                        min: 1.0,
                        max: 10.0,
                        divisions: 9,
                        activeColor: Colors.orangeAccent,
                        inactiveColor: Colors.white24,
                        label: "${_temperature.round()}",
                      ),
                    ),
                    const Text("Complex", style: TextStyle(color: Colors.white38)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Tooltip(
                message: "Filter Tasks",
                child: Icon(Icons.filter_list, color: Colors.white60, size: iconSize),
              ),
              SizedBox(width: iconSpacing),
              DropdownButton<String>(
                value: _filter,
                dropdownColor: const Color(0xFF2E2E2E),
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                items: ['All', 'Completed', 'Pending'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: screenWidth * 0.04)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _filter = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredTasks().length,
            itemBuilder: (context, index) {
              Task task = _filteredTasks()[index];
              int originalIndex = _findOriginalIndexById(task.id);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    optionsVisible[task.id] = false;
                    subtasksVisible[task.id] = false;
                  });
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          key: ValueKey(task.id),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: iconSpacing,
                              vertical: screenWidth * 0.01,
                            ),
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (_) => _toggleComplete(task.id),
                              checkColor: Colors.white,
                              fillColor: WidgetStatePropertyAll(
                                  task.isCompleted ? Colors.green : Colors.white),
                            ),
                            title: Text(
                              task.title,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (task.subtasks.isNotEmpty)
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white70,
                                      size: iconSize,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        subtasksVisible[task.id] =
                                            !(subtasksVisible[task.id] ?? false);
                                      });
                                    },
                                  ),
                                IconButton(
                                  tooltip: "More Options",
                                  icon: Icon(Icons.more_vert,
                                      size: iconSize, color: Colors.white70),
                                  onPressed: () {
                                    setState(() {
                                      optionsVisible[task.id] =
                                          !(optionsVisible[task.id] ?? false);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (optionsVisible[task.id] ?? false)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xB3000000),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Tooltip(
                                    message: "Beautify",
                                    child: IconButton(
                                      icon: Icon(Icons.auto_fix_high,
                                          size: iconSize, color: Colors.orangeAccent),
                                      onPressed: () {
                                        setState(() {
                                          optionsVisible[task.id] = false;
                                        });
                                        _generateSubtasks(originalIndex);
                                      },
                                    ),
                                  ),
                                  Tooltip(
                                    message: "Delete Task",
                                    child: IconButton(
                                      icon: Icon(Icons.delete,
                                          size: iconSize, color: Colors.redAccent),
                                      onPressed: () {
                                        setState(() {
                                          optionsVisible[task.id] = false;
                                        });
                                        _deleteTask(task.id);
                                      },
                                    ),
                                  ),
                                  Tooltip(
                                    message: "Edit Task",
                                    child: IconButton(
                                      icon: Icon(Icons.edit,
                                          size: iconSize, color: Colors.lightBlueAccent),
                                      onPressed: () {
                                        setState(() {
                                          optionsVisible[task.id] = false;
                                        });
                                        _editTask(task.id);
                                      },
                                    ),
                                  ),
                                  Tooltip(
                                    message: "Set Reminder",
                                    child: IconButton(
                                      icon: Icon(Icons.alarm,
                                          size: iconSize, color: Colors.greenAccent),
                                      onPressed: () {
                                        setState(() {
                                          optionsVisible[task.id] = false;
                                        });
                                        _pickReminderTime(task);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (subtasksVisible[task.id] ?? false)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(task.subtasks.length, (subIndex) {
                          var subtask = task.subtasks[subIndex];
                          return Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 32, right: 8.0),
                                child: Text(
                                  "${subIndex + 1}.",
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    leading: Checkbox(
                                      value: subtask['isCompleted'] as bool,
                                      onChanged: (value) {
                                        _toggleSubtaskCompletion(task, subIndex);
                                      },
                                      checkColor: Colors.white,
                                      fillColor: MaterialStatePropertyAll(
                                          subtask['isCompleted'] ? Colors.green : Colors.white),
                                    ),
                                    title: Text(
                                      subtask['title'],
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}