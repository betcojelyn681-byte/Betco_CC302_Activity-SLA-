import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BETCO Fruit Directory',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const FruitHomePage(),
    );
  }
}

class Fruit {
  final int id;
  final String name;
  final String family;
  final String genus;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;

  Fruit({
    required this.id,
    required this.name,
    required this.family,
    required this.genus,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
  });

  factory Fruit.fromJson(Map<String, dynamic> json) {
    final nutritions = json['nutritions'] as Map<String, dynamic>? ?? {};

    return Fruit(
      id: json['id'],
      name: json['name'] ?? '',
      family: json['family'] ?? '',
      genus: json['genus'] ?? '',
      calories: (nutritions['calories'] ?? 0).toDouble(),
      protein: (nutritions['protein'] ?? 0).toDouble(),
      carbohydrates: (nutritions['carbohydrates'] ?? 0).toDouble(),
      fat: (nutritions['fat'] ?? 0).toDouble(),
    );
  }
}

class FruitHomePage extends StatefulWidget {
  const FruitHomePage({super.key});

  @override
  State<FruitHomePage> createState() => _FruitHomePageState();
}

class _FruitHomePageState extends State<FruitHomePage> {
  final String apiUrl = 'https://www.fruityvice.com/api/fruit/all';

  late Future<List<Fruit>> fruits;

  @override
  void initState() {
    super.initState();

    fruits = fetchFruits();
  }

  Future<List<Fruit>> fetchFruits() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((fruitJson) => Fruit.fromJson(fruitJson))
          .toList();
    } else {
      throw Exception('Failed to load fruits');
    }
  }

  void reloadFruits() {
    setState(() {
      fruits = fetchFruits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BETCO Fruit Directory'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Fruit>>(
        future: fruits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: reloadFruits,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No fruits found.'),
            );
          }

          final List<Fruit> fruitList = snapshot.data!;

          return ListView(
            children: [
              const FruitHeader(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fruitList.length,
                itemBuilder: (context, index) {
                  final fruit = fruitList[index];

                  return FruitCard(fruit: fruit);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class FruitHeader extends StatelessWidget {
  const FruitHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.green.shade100,
      child: Column(
        children: [
          const Icon(
            Icons.eco,
            size: 60,
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          const Text(
            'Welcome to BETCO',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover fruits and their nutritional information',
            style: TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.local_dining),
            label: const Text('View Fruits'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class FruitCard extends StatelessWidget {
  final Fruit fruit;

  const FruitCard({
    super.key,
    required this.fruit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.apple,
                size: 45,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fruit.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Family: ${fruit.family}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Genus: ${fruit.genus}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Calories: ${fruit.calories}'),
                  Text('Protein: ${fruit.protein} g'),
                  Text('Carbohydrates: ${fruit.carbohydrates} g'),
                  Text('Fat: ${fruit.fat} g'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}