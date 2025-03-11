import 'package:flutter/material.dart';
import 'package:project_ke_2_bareng_masade/services/gemini_service.dart';
import 'schedule_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> tasks = [];
  final TextEditingController taskController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? deadline;
  String? priority;
  String? category;
  bool isLoading = false;
  bool isDarkMode = false;

  void _addTask() {
    if (taskController.text.isNotEmpty &&
        durationController.text.isNotEmpty &&
        priority != null &&
        category != null) {
      setState(() {
        tasks.add({
          "name": taskController.text,
          "description": descriptionController.text,
          "priority": priority!,
          "category": category!,
          "duration": int.tryParse(durationController.text) ?? 30,
          "deadline": deadline != null
              ? "${deadline!.day}/${deadline!.month}/${deadline!.year}"
              : "Tidak Ada",
          "completed": false,
        });
      });
      taskController.clear();
      durationController.clear();
      descriptionController.clear();
      deadline = null;
    }
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      tasks[index]["completed"] = !tasks[index]["completed"];
    });
  }

  Future<void> _selectDeadline() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        deadline = pickedDate;
      });
    }
  }

  Future<void> _generateSchedule() async {
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠ Harap tambahkan tugas terlebih dahulu!")),
      );
      return;
    }

    setState(() => isLoading = true);

    String response = await GeminiService.generateSchedule(tasks);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleResultScreen(scheduleResult: response),
      ),
    ).then((_) {
      setState(() => isLoading = false);
    });
  }

  void _toggleDarkMode() {
    setState(() => isDarkMode = !isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Schedule Generator"),
          backgroundColor: Colors.blueAccent,
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: _toggleDarkMode,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: "Nama Tugas",
                  prefixIcon: Icon(Icons.task),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Deskripsi Tugas",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: durationController,
                decoration: InputDecoration(
                  labelText: "Durasi (menit)",
                  prefixIcon: Icon(Icons.timer),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
                hint: Text("Pilih Prioritas"),
                onChanged: (value) => setState(() => priority = value),
                items: ["Tinggi", "Sedang", "Rendah"]
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                hint: Text("Pilih Kategori"),
                onChanged: (value) => setState(() => category = value),
                items: ["Pekerjaan", "Studi", "Pribadi"]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _selectDeadline,
                icon: Icon(Icons.date_range),
                label: Text(deadline == null ? "Pilih Deadline" : "Deadline: ${deadline!.day}/${deadline!.month}/${deadline!.year}"),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _addTask,
                icon: Icon(Icons.add_task),
                label: Text("Tambahkan Tugas"),
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _generateSchedule,
                      icon: Icon(Icons.schedule),
                      label: Text("Buat Jadwal"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
