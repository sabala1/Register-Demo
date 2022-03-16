import 'package:flutter/material.dart';
import 'package:register_demo/pages/regitration.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Register Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<FirebaseApp> _initialization =
      Firebase.initializeApp(); //เตรียมรายละเอียดที่set up ให้พร้อมใช้งาน

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {

          return Text('${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              body:
                  TabBarView(children: [const RegistrationPage(), Container()]),
              backgroundColor: Colors.blue,
              bottomNavigationBar: const TabBar(tabs: [
                Tab(
                  text: 'หน้าลงทะเบียน',
                ),
                Tab(
                  text: 'รายชื่อ',
                )
              ]),
            ),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
