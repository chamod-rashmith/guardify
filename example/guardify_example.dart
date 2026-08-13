import 'package:material_ui/material_ui.dart';
import 'package:guardify/guardify.dart';

part 'guardify_example.secured.g.dart';

// --- SECURED WIDGET DEFINITIONS ---

// 1. Delete Button (Hides automatically for unauthorized users)
@Secured(['admin', 'superadmin'], fallback: FallbackType.hide)
class DeleteUserButton extends StatelessWidget {
  final String userId;
  final VoidCallback onDelete;

  const DeleteUserButton({
    super.key,
    required this.userId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      onPressed: onDelete,
      icon: const Icon(Icons.delete, color: Colors.white),
      label: Text('Delete User $userId', style: const TextStyle(color: Colors.white)),
    );
  }
}

// 2. Financial Card (Shows inline Access Denied text)
@Secured(['manager', 'finance'], requireAll: true, fallback: FallbackType.text)
class FinancialReportCard extends StatelessWidget {
  final double totalRevenue;

  const FinancialReportCard({
    super.key,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.monetization_on, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              'Total Revenue: \$${totalRevenue.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Admin Dashboard Screen (Shows full Scaffold Access Denied page)
@Secured(['admin'], fallback: FallbackType.scaffold)
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          '👑 Welcome to Secret Admin Panel!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// 4. Generic Widget Class with Enum Roles
enum DemoRole { admin, manager, user }

@Secured([DemoRole.admin], fallback: FallbackType.text)
class GenericDataCard<T> extends StatelessWidget {
  final T data;
  final String title;

  const GenericDataCard({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '$title: $data',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


// 5. Named Constructor Widget
@Secured(['admin'])
class NamedConstructorWidget extends StatelessWidget {
  final String label;

  const NamedConstructorWidget.primary({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Text('Primary: $label');
  }
}

// 6. Target Widget with Property Collision ('fallback')
@Secured(['admin'])
class TargetWidgetWithFallback extends StatelessWidget {
  final Widget? fallback;

  const TargetWidgetWithFallback({
    super.key,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(child: fallback);
  }
}


// --- MAIN FLUTTER APP ---

void main() {
  runApp(const GuardifyDemoApp());
}

class GuardifyDemoApp extends StatefulWidget {
  const GuardifyDemoApp({super.key});

  @override
  State<GuardifyDemoApp> createState() => _GuardifyDemoAppState();
}

class _GuardifyDemoAppState extends State<GuardifyDemoApp> {
  String _selectedRole = 'guest';

  @override
  Widget build(BuildContext context) {
    return GuardifyScope(
      currentRole: _selectedRole,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Guardify Example App'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Role Switcher Card
                Card(
                  color: Colors.deepPurple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Select Active User Role:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'guest', label: Text('Guest')),
                            ButtonSegment(value: 'user', label: Text('User')),
                            ButtonSegment(value: 'manager', label: Text('Manager')),
                            ButtonSegment(value: 'admin', label: Text('Admin')),
                          ],
                          selected: {_selectedRole},
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _selectedRole = newSelection.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 1. Clean Secured Button (SecuredDeleteUserButton)
                const Text('1. Delete Button (SecuredDeleteUserButton):',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SecuredDeleteUserButton(
                  userId: 'USR-8890',
                  onDelete: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User USR-8890 deleted!')),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 2. Clean Secured Financial Card (SecuredFinancialReportCard)
                const Text('2. Financial Card (SecuredFinancialReportCard):',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const SecuredFinancialReportCard(
                  totalRevenue: 98450.00,
                ),

                const SizedBox(height: 24),

                // 3. Context Extension Check
                Builder(
                  builder: (context) {
                    final isAdmin = context.hasRole('admin');
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isAdmin ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'context.hasRole("admin"): ${isAdmin ? "YES ✅" : "NO ❌"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // 4. Open Admin Dashboard Screen Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Open Admin Dashboard Screen'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecuredAdminDashboardScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
