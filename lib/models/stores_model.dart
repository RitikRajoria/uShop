class StoresModel {
  String? name;
  String? iconUrl;

  StoresModel({this.name, this.iconUrl});

  StoresModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    iconUrl = json['iconUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['iconUrl'] = this.iconUrl;
    return data;
  }
}