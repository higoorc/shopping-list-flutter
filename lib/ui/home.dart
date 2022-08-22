import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../model/item.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Item>> futureItems;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    futureItems = fetchAllItems();
  }

  Future<List<Item>> fetchAllItems() async {
    final response = await http.get(Uri.parse(
        'https://shopping-list-9dc94-default-rtdb.firebaseio.com/items/.json'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final responseBody = Map<String, dynamic>.from(jsonDecode(response.body));

      List<Item> itemList = [];
      responseBody
          .forEach((key, value) => {itemList.add(Item.fromJson(value))});

      return itemList;
    } else {
      throw Exception('Failed to load items.');
    }
  }

  deleteItem(Item item) async {
    final response = await http.delete(Uri.parse(
        'https://shopping-list-9dc94-default-rtdb.firebaseio.com/items/${item.id}.json'));

    if (response.statusCode == 200) {
      setState(() {
        futureItems = fetchAllItems();
      });
    } else {
      throw Exception('Failed to delete item');
    }
  }

  updateItem(Item item, bool value) async {
    final json = '{"isChecked": $value}';

    final response = await http.patch(
        Uri.parse(
            'https://shopping-list-9dc94-default-rtdb.firebaseio.com/items/${item.id}.json'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json);

    if (response.statusCode == 200) {
      setState(() {
        futureItems = fetchAllItems();
      });
    } else {
      throw Exception('Failed to update item');
    }
  }

  addItem() async {
    if (nameController.text.isNotEmpty) {
      var id = const Uuid().v4();
      Item item = Item(id: id, name: nameController.text, isChecked: false);

      final response = await http.put(
          Uri.parse(
              'https://shopping-list-9dc94-default-rtdb.firebaseio.com/items/$id.json'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: jsonEncode(item));

      if (response.statusCode == 200) {
        setState(() {
          futureItems = fetchAllItems();
        });
      } else {
        throw Exception('Failed to add item');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.only(left: 15, top: 50, right: 15),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
          child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: TextField(
              controller: nameController,
              onSubmitted: (value) async {
                await addItem();
                nameController.text = "";
              },
              decoration: const InputDecoration(
                  labelText: 'Tap to add a new item',
                  border: OutlineInputBorder()),
            )),
            const SizedBox(width: 10),
            IconButton(
                icon: const Icon(
                  Icons.add,
                ),
                key: const Key('add'),
                onPressed: () async {
                  await addItem();
                  nameController.text = "";
                })
          ]),
          FutureBuilder<List<Item>>(
            future: futureItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasData) {
                var items = snapshot.data;

                return ListView.builder(
                  itemCount: items?.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var item = items![index];

                    return InkWell(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            color: const Color(0xffffffff),
                            borderRadius: BorderRadius.circular(10)),
                        height: 90,
                        child: Row(
                          children: [
                            Checkbox(
                                value: item.isChecked,
                                onChanged: (value) async {
                                  await updateItem(item, value!);
                                }),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(item.name,
                                          style: item.isChecked
                                              ? GoogleFonts.roboto(
                                                  fontSize: 20,
                                                  decoration: TextDecoration
                                                      .lineThrough)
                                              : GoogleFonts.roboto(
                                                  fontSize: 20))),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ]),
                            const Spacer(),
                            IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                ),
                                onPressed: () async {
                                  await deleteItem(item);
                                })
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                    child: Text('No items added, try to add a new one :)',
                        style: GoogleFonts.roboto(fontSize: 20)));
              }
            },
          )
        ],
      )),
    )
        // color: Colors.red,
        );
  }
}
