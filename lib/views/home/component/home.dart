import 'package:contact_to_pdf/views/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
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
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ChangeNotifierProvider(
        create: (_) => HomeController(),
        child: Consumer<HomeController>(
          builder: (context, model, child) {
            controller = model;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                controller!.contacts.isEmpty
                    ? const Text('No Contacts')
                    : SizedBox(
                        height: height * 0.8,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller!.contacts.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(controller!.contacts.elementAt(index).displayName!),
                            );
                          },
                        ),
                      ),
                controller!.isLoading
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: () async {
                          controller!.generatePdf();
                        },
                        child: Text(
                          'Generate PDF of Contacts',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
