import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'owner_dashboard.dart';
import '../property/create_property_screen.dart';
import '../property/property_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Route to appropriate dashboard based on role
    if (authProvider.isOwner) {
      return const OwnerHome();
    }
    return const StudentHome();
  }
}

/// Owner dashboard with property management
class OwnerHome extends StatelessWidget {
  const OwnerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1B16),
        elevation: 0,
      ),
      body: const OwnerDashboard(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePropertyScreen()),
          );
        },
        backgroundColor: const Color(0xFF5287B2),
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
      ),
    );
  }
}

/// Student home with property browsing
class StudentHome extends StatelessWidget {
  const StudentHome({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Home'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1B16),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: const PropertyListScreen(),
    );
  }
}
