import 'package:flutter/material.dart';

void main() => runApp(const SmartAttendanceApp());

class SmartAttendanceApp extends StatelessWidget {
  const SmartAttendanceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Smart Attendance',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
      scaffoldBackgroundColor: const Color(0xFFF7FAF9),
      useMaterial3: true,
    ),
    home: const LoginScreen(),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final employeeId = TextEditingController(text: 'SW-102');
  bool loading = false;
  @override void dispose() { employeeId.dispose(); super.dispose(); }
  Future<void> signIn() async {
    setState(() => loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WorkerHome()));
  }
  @override Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.location_on_rounded, size: 72, color: Color(0xFF00695C)),
        const SizedBox(height: 16),
        Text('Smart Attendance', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const Text('Field Activity Monitoring', textAlign: TextAlign.center),
        const SizedBox(height: 36),
        TextField(controller: employeeId, decoration: const InputDecoration(labelText: 'Employee ID', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge_outlined))),
        const SizedBox(height: 16),
        const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password or OTP', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline))),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: loading ? null : signIn, icon: const Icon(Icons.login), label: Text(loading ? 'Signing in...' : 'Sign in'), style: FilledButton.styleFrom(padding: const EdgeInsets.all(16))),
        const SizedBox(height: 16), const Text('தமிழ்  |  English', textAlign: TextAlign.center),
      ]),
    ))),
  );
}

class WorkerHome extends StatefulWidget {
  const WorkerHome({super.key});
  @override State<WorkerHome> createState() => _WorkerHomeState();
}
class _WorkerHomeState extends State<WorkerHome> {
  int index = 0;
  bool checkedIn = false;
  @override Widget build(BuildContext context) {
    final pages = [
      Dashboard(checkedIn: checkedIn, onCheckIn: () => setState(() => checkedIn = true)),
      const TasksPage(), const HistoryPage(), const ProfilePage(),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(['Today', 'Tasks', 'History', 'Profile'][index])),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.checkedIn, required this.onCheckIn});
  final bool checkedIn; final VoidCallback onCheckIn;
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Good morning, Ravi', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
    const Text('Sanitary Worker  •  Kattankulathur Panchayat'), const SizedBox(height: 18),
    Card(color: checkedIn ? const Color(0xFFDDF4E9) : const Color(0xFFFFF3D8), child: ListTile(
      leading: Icon(checkedIn ? Icons.check_circle : Icons.schedule, color: checkedIn ? Colors.green : Colors.orange, size: 34),
      title: Text(checkedIn ? 'Checked in at 09:04 AM' : 'Attendance pending'),
      subtitle: Text(checkedIn ? 'Location verified for today' : 'Duty begins at 09:00 AM'),
    )),
    const SizedBox(height: 14),
    FilledButton.icon(
      onPressed: checkedIn ? null : () async {
        final done = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AttendancePage()));
        if (done == true) onCheckIn();
      },
      icon: const Icon(Icons.fingerprint), label: Text(checkedIn ? 'Attendance marked' : 'Mark attendance'),
      style: FilledButton.styleFrom(padding: const EdgeInsets.all(18)),
    ),
    const SizedBox(height: 20), const Heading('Today\'s schedule'),
    const TaskTile('Street sanitation round', 'Ward 4, Main Road', '09:30 AM - 11:30 AM'),
    const TaskTile('Public toilet inspection', 'Bus Stand Facility', '12:00 PM - 12:30 PM'),
    OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityPage())), icon: const Icon(Icons.add_a_photo_outlined), label: const Text('Report field activity')),
  ]);
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});
  @override State<AttendancePage> createState() => _AttendancePageState();
}
class _AttendancePageState extends State<AttendancePage> {
  int step = 0;
  final labels = const ['Getting GPS location', 'Capturing attendance photo', 'Verifying location and face'];
  void next() {
    if (step < 2) { setState(() => step++); return; }
    showDialog<void>(context: context, builder: (_) => AlertDialog(
      icon: const Icon(Icons.verified, color: Colors.green, size: 48),
      title: const Text('Attendance marked'),
      content: const Text('GPS, time and attendance photo were recorded. You are inside the assigned geofence.'),
      actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context, true); }, child: const Text('Done'))],
    ));
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Mark attendance')), body: Padding(
    padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Icon(Icons.camera_alt_outlined, size: 100, color: Color(0xFF00695C)), const SizedBox(height: 20),
      Text(labels[step], textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 20),
      const ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('GPS coordinates and accuracy'), subtitle: Text('12.9258, 80.0552  •  accuracy 8 m')),
      ListTile(leading: Icon(step >= 1 ? Icons.check_circle : Icons.radio_button_unchecked, color: step >= 1 ? Colors.green : Colors.grey), title: const Text('Selfie / QR verification')),
      ListTile(leading: Icon(step >= 2 ? Icons.check_circle : Icons.radio_button_unchecked, color: step >= 2 ? Colors.green : Colors.grey), title: const Text('Geofence and face verification')),
      const Spacer(), FilledButton(onPressed: next, style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)), child: Text(step == 2 ? 'Submit attendance' : 'Continue')),
    ]),
  ));
}

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: const [
    Heading('Assigned for today'), TaskTile('Street sanitation round', 'Ward 4, Main Road', '09:30 AM - 11:30 AM'),
    TaskTile('Public toilet inspection', 'Bus Stand Facility', '12:00 PM - 12:30 PM'),
    TaskTile('Drainage inspection', 'Anna Nagar, Ward 3', '03:00 PM - 04:00 PM'),
  ]);
}

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});
  @override State<ActivityPage> createState() => _ActivityPageState();
}
class _ActivityPageState extends State<ActivityPage> {
  String activity = 'Street sanitation';
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Report field activity')), body: ListView(padding: const EdgeInsets.all(16), children: [
    DropdownButtonFormField<String>(initialValue: activity, decoration: const InputDecoration(labelText: 'Activity type', border: OutlineInputBorder()), items: const ['Street sanitation', 'Public toilet inspection', 'Drainage inspection'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => activity = v!)),
    const SizedBox(height: 16), const TextField(maxLines: 4, decoration: InputDecoration(labelText: 'Remarks', hintText: 'Describe work completed or issues found', border: OutlineInputBorder())),
    const SizedBox(height: 16), OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add_a_photo), label: const Text('Capture evidence photo')),
    const ListTile(leading: Icon(Icons.location_on, color: Color(0xFF00695C)), title: Text('GPS location ready'), subtitle: Text('12.9258, 80.0552  •  accuracy 8 m')),
    FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity saved locally and queued for sync.'))), child: const Text('Save activity')),
  ]));
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: const [
    Heading('Attendance history'), ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('26 September 2026'), subtitle: Text('Checked in 09:02 AM • Ward 4'), trailing: Text('Verified')),
    ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('25 September 2026'), subtitle: Text('Checked in 09:04 AM • Ward 4'), trailing: Text('Verified')),
    ListTile(leading: Icon(Icons.warning_amber, color: Colors.orange), title: Text('24 September 2026'), subtitle: Text('Checked in 09:17 AM • Ward 3'), trailing: Text('Late')),
  ]);
}
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: const [
    CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)), SizedBox(height: 12),
    Text('Ravi Kumar', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text('SW-102 • Sanitary Worker', textAlign: TextAlign.center), SizedBox(height: 24),
    ListTile(leading: Icon(Icons.location_city), title: Text('Assigned area'), subtitle: Text('Kattankulathur Panchayat, Ward 4')),
    ListTile(leading: Icon(Icons.phone_outlined), title: Text('Mobile number'), subtitle: Text('+91 98765 43210')),
  ]);
}
class Heading extends StatelessWidget {
  const Heading(this.text, {super.key}); final String text;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)));
}
class TaskTile extends StatelessWidget {
  const TaskTile(this.title, this.location, this.time, {super.key});
  final String title, location, time;
  @override Widget build(BuildContext context) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.assignment_outlined)), title: Text(title), subtitle: Text('$location\n$time'), isThreeLine: true, trailing: const Text('Upcoming', style: TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.w600))));
}
