import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/events_provider.dart';
import '../../auth/providers/auth_provider.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
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

  Stream<QuerySnapshot> _getEventsByType(String uiLabel) {
    return FirebaseFirestore.instance
        .collection('events')
        .where('type', isEqualTo: typeMap[uiLabel])
        .orderBy('date')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authNotifierProvider).user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: uiLabels.map((e) => Tab(text: e)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateEventScreen(typeMap: typeMap),
          ),
        ),
        child: const Icon(Icons.add),
      ),
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
                return Center(child: Text("No ${label.toLowerCase()} events"));
              }

              return ListView(
                padding: const EdgeInsets.all(12),
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final date = DateTime.parse(data['date']);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(data['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📍 ${data['location']}"),
                          Text("🗓 ${date.toLocal()}"),
                          Text(data['description']),
                          const SizedBox(height: 8),

                          // RSVP BUTTON
                          Consumer(
                            builder: (_, ref, __) {
                              final attending =
                                  ref.watch(eventRsvpStatusProvider(doc.id));

                              return ElevatedButton(
                                onPressed: () {
                                  ref
                                      .read(eventsProvider.notifier)
                                      .toggleRsvp(doc.id);
                                },
                                child: Text(
                                  attending.value == true
                                      ? "Cancel RSVP"
                                      : "RSVP",
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // DELETE (ORGANIZER ONLY)
                      trailing: data['organizerId'] == userId
                          ? PopupMenuButton(
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text("Delete"),
                                ),
                              ],
                              onSelected: (_) {
                                ref
                                    .read(eventsProvider.notifier)
                                    .deleteEvent(doc.id);
                              },
                            )
                          : null,
                    ),
                  );
                }).toList(),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

// =====================================================================
// CREATE EVENT SCREEN (THIS WAS MISSING ❗)
// =====================================================================

class CreateEventScreen extends ConsumerStatefulWidget {
  final Map<String, String> typeMap;

  const CreateEventScreen({super.key, required this.typeMap});

  @override
  ConsumerState<CreateEventScreen> createState() =>
      _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _title;
  String? _description;
  String? _location;
  String? _type;

  DateTime? _date;
  TimeOfDay? _time;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Event")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v!.isEmpty ? "Required" : null,
                onSaved: (v) => _title = v,
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: "Location"),
                onSaved: (v) => _location = v,
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                onSaved: (v) => _description = v,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Event Type"),
                items: widget.typeMap.keys
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                validator: (v) => v == null ? "Required" : null,
                onChanged: (v) => _type = v,
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _pickDate,
                child: Text(_date == null
                    ? "Pick Date"
                    : _date!.toLocal().toString().split(' ')[0]),
              ),

              ElevatedButton(
                onPressed: _pickTime,
                child: Text(
                  _time == null
                      ? "Pick Time"
                      : _time!.format(context),
                ),
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

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (result != null) setState(() => _date = result);
  }

  Future<void> _pickTime() async {
    final result =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (result != null) setState(() => _time = result);
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _time == null) return;

    _formKey.currentState!.save();

    final user = ref.read(authNotifierProvider).user!;
    final combined = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );

    await FirebaseFirestore.instance.collection('events').add({
      'title': _title,
      'description': _description,
      'location': _location,
      'type': widget.typeMap[_type],
      'date': combined.toIso8601String(),
      'organizerId': user.uid,
      'createdAt': DateTime.now().toIso8601String(),
    });

    Navigator.pop(context);
  }
}
