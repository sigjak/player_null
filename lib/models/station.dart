class Station {
  late String name;
  late String source;
  late String logo;

  Station({required this.name, required this.source, required this.logo});

  Map<String, dynamic> toMap() {
    var map = {
      "name": name,
      "source": source,
      "logo": logo,
    };
    return map;
  }

  Station.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    source = json['source'];
    logo = json['logo'];
  }
}
