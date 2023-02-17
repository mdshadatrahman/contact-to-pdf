import 'package:contact_to_pdf/views/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer show log;

import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  HomeController? controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ChangeNotifierProvider(
        create: (_) => HomeController(),
        child: Consumer<HomeController>(
          builder: (context, model, child) {
            controller = model;
            return Center(
              child: TextButton(
                onPressed: () async {
                  //TODO
                  controller!.getContacts();
                },
                child: Text(
                  'Generate PDF of Contacts',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
