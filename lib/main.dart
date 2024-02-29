import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp(),);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class UserData {
  String name;
  String email;
  String password;
  bool isMale;

  UserData({
    required this.name,
    required this.email,
    required this.password,
    required this.isMale,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      isMale: json['isMale'] ?? false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<UserData> users = [];
  late SharedPreferences prefs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isMale = true;

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
  }

  Future<void> loadSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    // Load existing user data from shared preferences
    List<String>? userDataList = prefs.getStringList('userDataList');
    if (userDataList != null) {
      setState(() {
        users = userDataList
            .map((userDataString) => UserData.fromJson(userDataString as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> saveSharedPreferences() async {
    // Save user data to shared preferences
    List<String> userDataList =
    users.map((userData) => userData.toJson()).toList();
    await prefs.setStringList('userDataList', userDataList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Preferences'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Male'),
              Checkbox(
                value: isMale,
                onChanged: (value) {
                  setState(() {
                    isMale = value ?? false;
                  });
                },
              ),
              Text('Female'),
              Checkbox(
                value: !isMale,
                onChanged: (value) {
                  setState(() {
                    isMale = !(value ?? true);
                  });
                },
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                users.add(UserData(
                  name: nameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                  isMale: isMale,
                ));
              });
              await saveSharedPreferences();
            },
            child: Text('Save'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  padding: EdgeInsets.all(8.0),
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${users[index].name}'),
                      Text('Email: ${users[index].email}'),
                      Text('Password: ${users[index].password}'),
                      Text(
                          'Gender: ${users[index].isMale ? 'Male' : 'Female'}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              _showUpdateDialog(index);
                            },
                            child: Text('Update'),
                          ),
                          SizedBox(width: 8.0),
                          ElevatedButton(
                            onPressed: () async {
                              // Delete user data
                              setState(() {
                                users.removeAt(index);
                              });
                              await saveSharedPreferences();
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _showUpdateDialog(int index) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update User Data'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Male'),
                    Checkbox(
                      value: isMale,
                      onChanged: (value) {
                        setState(() {
                          isMale = value ?? false;
                        });
                      },
                    ),
                    Text('Female'),
                    Checkbox(
                      value: !isMale,
                      onChanged: (value) {
                        setState(() {
                          isMale = !(value ?? true);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  users[index] = UserData(
                    name: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                    isMale: isMale,
                  );
                });
                await saveSharedPreferences();
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

}
extension UserDataSerialization on UserData {
  String toJson() {
    return '{"name": "$name", "email": "$email", "password": "$password", "isMale": $isMale}';
  }

  static UserData fromJson(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    return UserData(
      name: data['name'],
      email: data['email'],
      password: data['password'],
      isMale: data['isMale'],
    );
  }

}


