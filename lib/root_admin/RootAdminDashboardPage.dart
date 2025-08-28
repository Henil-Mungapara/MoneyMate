import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moneymate/root_admin/RootAdminProfilePage.dart';
import 'package:moneymate/root_admin/UpdateRolePage.dart';

class RootAdminDashboardPage extends StatefulWidget {
  const RootAdminDashboardPage({super.key});

  @override
  State<RootAdminDashboardPage> createState() => _RootAdminDashboardPageState();
}

class _RootAdminDashboardPageState extends State<RootAdminDashboardPage> {
  void _deleteUser(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Root Admin Dashboard'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B2E33),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFB8E3E9),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "Manage Admin & Users's Role",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B2E33)),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                final users = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final uid = user.id;
                    final data = user.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(data['email'] ?? 'No Email',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          'UID: $uid\nRole: ${data['role'] ?? 'user'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF0B2E33),size: 30,),
                              tooltip: 'Update',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UpdateRolePage(
                                      uid: uid,
                                      currentRole: data['role'] ?? 'user',
                                    ),
                                  ),
                                );
                              },

                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded, color: Color(0xFF0B2E33),size: 30,),
                              tooltip: 'Delete',
                              onPressed: () {
                                _deleteUser(uid);
                              },
                            ),
                          ],
                        ),

                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RootAdminProfilePage()),
          );
        },
        icon: const Icon(Icons.person, color: Colors.white),
        label: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0B2E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

    );
  }
}
