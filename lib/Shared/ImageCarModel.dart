class ImageCarModel {
  int id;
  String idimagesCars;
  String idcars;
  String urlimagesCars;

  ImageCarModel({
    this.id = 0,
    this.idimagesCars = "",
    this.idcars = "",
    this.urlimagesCars = "",
  });

  /// 🔄 FROM JSON (données éventuellement incomplètes)
  factory ImageCarModel.fromJson(Map<String, dynamic> json) {
    return ImageCarModel(
      id: json["id"] is int ? json["id"] : int.tryParse("${json["id"]}") ?? 0,

      idimagesCars: json["idimages_cars"]?.toString() ?? "",
      idcars: json["idcars"]?.toString() ?? "",
      urlimagesCars: json["urlimages_cars"]?.toString() ?? "",
    );
  }

  /// 🔄 TO JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "idimages_cars": idimagesCars,
      "idcars": idcars,
      "urlimages_cars": urlimagesCars,
    };
  }
}
