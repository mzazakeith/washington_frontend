import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Washington Crud Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String apiResponse = '';
  List<Map<String, dynamic>> users = [];

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/health'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        apiResponse = data['message'];
      });
    } else {
      setState(() {
        apiResponse = 'Failed to fetch data';
      });
    }
  }

  Future<void> getUsers() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/users/get'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['users'] is List) {
        setState(() {
          users = List<Map<String, dynamic>>.from(data['users']);
        });
      }
    } else {
      // Handle the error
    }
  }

  Future<void> addUser(String firstName, String lastName, String email) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/user/add'),
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      await getUsers();
      // Clear the text fields after adding a user
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
    } else {
      // Handle the error
    }
  }

  Future<void> updateUser(
      String id, String firstName, String lastName, String email) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/api/user/update/$id'),
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      await getUsers();
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
    } else {
      // Handle the error
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http
        .delete(Uri.parse('http://localhost:3000/api/user/delete/$id'));

    if (response.statusCode == 200) {
      await getUsers();
    } else {
      // Handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await fetchData();
              },
              child: const Text('Fetch Server Health'),
            ),
            const SizedBox(height: 20),
            Text('API Response: $apiResponse',
                style: Theme.of(context).textTheme.titleMedium),
            ElevatedButton(
              onPressed: () async {
                await getUsers();
              },
              child: const Text('Get All Users'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(user['firstName'] + ' ' + user['lastName']),
                        subtitle: Text(user['email']),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              // Show a dialog or navigate to a new screen for user input
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Update User'),
                                    content: Column(
                                      children: [
                                        TextField(
                                          controller: firstNameController,
                                          decoration: const InputDecoration(
                                              labelText: 'Updated First Name'),
                                        ),
                                        TextField(
                                          controller: lastNameController,
                                          decoration: const InputDecoration(
                                              labelText: 'Updated Last Name'),
                                        ),
                                        TextField(
                                          controller: emailController,
                                          decoration: const InputDecoration(
                                              labelText: 'Updated Email'),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          await updateUser(
                                            user['_id'],
                                            firstNameController.text,
                                            lastNameController.text,
                                            emailController.text,
                                          );
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: const Text('Update'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('Update User'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // Show a confirmation dialog before deleting the user
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete User'),
                                    content: const Text(
                                        'Are you sure you want to delete this user?'),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          await deleteUser(user['_id']);
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('Delete User'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            Column(
              children: [
                // UI component for adding a new user
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Call the add user function with the input values
                    await addUser(
                      firstNameController.text,
                      lastNameController.text,
                      emailController.text,
                    );
                  },
                  child: const Text('Add User'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
