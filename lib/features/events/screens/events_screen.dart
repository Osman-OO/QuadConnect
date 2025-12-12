import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> uiLabels = [
    "Academic",
    "Social",
    "Sports",
    "Arts",
    "Career",
    "Clubs",
  ];

  /// Maps UI labels → DB enum keys
  final Map<String, String> typeMap = {
    "Academic": "academic",
    "Social": "social",
    "Sports": "sports",
    "Arts": "arts",
    "Career": "career",
    "Clubs": "club",
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: uiLabels.length, vsync: this);
  }

  /// Fetches events by the internal enum name
  Stream<QuerySnapshot> _getEventsByType(String uiLabel) {
    final dbValue = typeMap[uiLabel] ?? "academic";

    return FirebaseFirestore.instance
        .collection('events')
        .where('type', isEqualTo: dbValue)
        .orderBy('date', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Events"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.black54,
          tabs: uiLabels.map((l) => Tab(text: l)).toList(),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateEvent(context),
        child: const Icon(Icons.add),
      ),

      // Tab Views (Each one filters events)
      body: TabBarView(
        controller: _tabController,
        children: uiLabels.map((label) {
          return StreamBuilder<QuerySnapshot>(
            stream: _getEventsByType(label),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No ${label.toLowerCase()} events yet.",
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(12),
                children: snapshot.data!.docs.map((doc) {
                  return _buildEventCard(doc);
                }).toList(),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  // -------------------------
  // EVENT CARD
  // -------------------------
  Widget _buildEventCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        title: Text(data['title'] ?? "Untitled Event"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['location'] != null)
              Text("Location: ${data['location']}"),

            if (data['date'] != null)
              Text("Date: ${data['date']}"),

            if (data['description'] != null)
              Text("Description: ${data['description']}"),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // CREATE EVENT PAGE
  // -------------------------
  void _openCreateEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateEventScreen(typeMap: typeMap)),
    );
  }
}

// =====================================================================
// CREATE EVENT SCREEN
// =====================================================================

class CreateEventScreen extends StatefulWidget {
  final Map<String, String> typeMap;

  const CreateEventScreen({super.key, required this.typeMap});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _title;
  String? _description;
  String? _location;
  String? _selectedUILabel;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(label: Text("Title")),
                onSaved: (v) => _title = v,
                validator: (v) =>
                    v!.isEmpty ? "Please enter a title" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(label: Text("Location")),
                onSaved: (v) => _location = v,
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(label: Text("Description")),
                maxLines: 3,
                onSaved: (v) => _description = v,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(label: Text("Event Type")),
                items: widget.typeMap.keys.map((uiLabel) {
                  return DropdownMenuItem(
                    value: uiLabel,
                    child: Text(uiLabel),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedUILabel = v),
                validator: (v) => v == null ? "Select a type" : null,
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _pickDate,
                child: Text(_selectedDate == null
                    ? "Pick Event Date"
                    : "Selected: ${_selectedDate!.toLocal()}".split(' ')[0]),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveEvent,
                child: const Text("Create Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // DATE PICKER
  // -------------------------
  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (result != null) {
      setState(() => _selectedDate = result);
    }
  }

  // -------------------------
  // SAVE TO FIRESTORE
  // -------------------------
  void _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final dbValue = widget.typeMap[_selectedUILabel] ?? "academic";

    await FirebaseFirestore.instance.collection("events").add({
      "title": _title,
      "description": _description,
      "location": _location,
      "type": dbValue,            // STORED ENUM VALUE
      "date": _selectedDate != null
          ? _selectedDate!.toIso8601String()
          : null,
      "createdAt": DateTime.now().toIso8601String(),
    });

    Navigator.pop(context);
  }
}
