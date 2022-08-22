class Item {
  final String id;
  final String name;
  final bool isChecked;

  const Item({
    required this.id,
    required this.name,
    required this.isChecked
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['id'],
        name: json['name'],
        isChecked: json['isChecked']
    );
  }
}