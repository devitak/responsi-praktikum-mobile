import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:responsi_mobile/models/model_categories.dart';
import 'category_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
Future<List<CategoriesModel>> fetchCategories() async {
  final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));
  if (response.statusCode == 200) {
    List<CategoriesModel> categories = (json.decode(response.body)['categories'] as List)
        .map((data) => CategoriesModel.fromJson(data))
        .toList();
    return categories;
  } else {
    throw Exception('Failed to load categories');
  }
}

class _HomePageState extends State<HomePage> {
  late Future<List<CategoriesModel>> categories;

  @override
  void initState() {
    super.initState();
    categories = fetchCategories();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        centerTitle: true,
        title: const Text('Meal Categories'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.075),
          child: Center(
            child: FutureBuilder<List<CategoriesModel>>(
              future: categories,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data!.map((category) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => CategoryPage(category: category.strCategory)));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.width * 0.6,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(category.strCategoryThumb),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 10),
                                  Center(
                                    child: Text(
                                      category.strCategory,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  Text(category.strCategoryDescription),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                  ),
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}