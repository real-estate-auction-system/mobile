import 'package:flutter/material.dart';

class News extends StatefulWidget {
  const News({super.key});
  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('This is news page'),
      ),
      body:const  Center(
        child: null
      ),
    );
  }
}
