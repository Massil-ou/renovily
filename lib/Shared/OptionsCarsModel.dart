class OptionsCarsModel {
  int id;
  String idoptionsCars;
  String idcars;

  int abs;
  int esp;
  int airbags;
  int climatisation;
  int climAuto;
  int regulateurVitesse;
  int limiteurVitesse;
  int gps;
  int siegesChauffants;
  int siegesCuir;
  int toitOuvrant;
  int cameraRecul;
  int aideStationnement;
  int radarAvant;
  int radarArriere;
  int detecteurAngleMort;
  int feuxAuto;
  int essuieGlaceAuto;
  int bluetooth;
  int usb;
  int ecranTactile;
  int jantesAlliage;
  int retroviseursElectriques;
  int vitresTeintees;
  int fermetureCentralisee;
  int startStop;
  int alarme;
  int antiDemarrage;
  int projecteursLed;
  int projecteursXenon;
  int toitPanoramique;
  int directionAssistee;
  int ordinateurBord;
  int volantMultifonction;
  int aideDemarrageCote;

  DateTime createdAt;

  OptionsCarsModel({
    this.id = 0,
    this.idoptionsCars = "",
    this.idcars = "",
    this.abs = 0,
    this.esp = 0,
    this.airbags = 0,
    this.climatisation = 0,
    this.climAuto = 0,
    this.regulateurVitesse = 0,
    this.limiteurVitesse = 0,
    this.gps = 0,
    this.siegesChauffants = 0,
    this.siegesCuir = 0,
    this.toitOuvrant = 0,
    this.cameraRecul = 0,
    this.aideStationnement = 0,
    this.radarAvant = 0,
    this.radarArriere = 0,
    this.detecteurAngleMort = 0,
    this.feuxAuto = 0,
    this.essuieGlaceAuto = 0,
    this.bluetooth = 0,
    this.usb = 0,
    this.ecranTactile = 0,
    this.jantesAlliage = 0,
    this.retroviseursElectriques = 0,
    this.vitresTeintees = 0,
    this.fermetureCentralisee = 0,
    this.startStop = 0,
    this.alarme = 0,
    this.antiDemarrage = 0,
    this.projecteursLed = 0,
    this.projecteursXenon = 0,
    this.toitPanoramique = 0,
    this.directionAssistee = 0,
    this.ordinateurBord = 0,
    this.volantMultifonction = 0,
    this.aideDemarrageCote = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Petit helper interne pour convertir tinyint/bool/string -> int (0/1)
  static int _toTinyInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is bool) return v ? 1 : 0;
    return int.tryParse('$v') ?? 0;
  }

  /// 🔄 FROM JSON (toutes les colonnes sont optionnelles côté API)
  factory OptionsCarsModel.fromJson(Map<String, dynamic> json) {
    return OptionsCarsModel(
      id: json["id"] is int ? json["id"] : int.tryParse("${json["id"]}") ?? 0,
      idoptionsCars: json["idoptions_cars"]?.toString() ?? "",
      idcars: json["idcars"]?.toString() ?? "",

      abs: _toTinyInt(json["abs"]),
      esp: _toTinyInt(json["esp"]),
      airbags: _toTinyInt(json["airbags"]),
      climatisation: _toTinyInt(json["climatisation"]),
      climAuto: _toTinyInt(json["clim_auto"]),
      regulateurVitesse: _toTinyInt(json["regulateur_vitesse"]),
      limiteurVitesse: _toTinyInt(json["limiteur_vitesse"]),
      gps: _toTinyInt(json["gps"]),
      siegesChauffants: _toTinyInt(json["sieges_chauffants"]),
      siegesCuir: _toTinyInt(json["sieges_cuir"]),
      toitOuvrant: _toTinyInt(json["toit_ouvrant"]),
      cameraRecul: _toTinyInt(json["camera_recul"]),
      aideStationnement: _toTinyInt(json["aide_stationnement"]),
      radarAvant: _toTinyInt(json["radar_avant"]),
      radarArriere: _toTinyInt(json["radar_arriere"]),
      detecteurAngleMort: _toTinyInt(json["detecteur_angle_mort"]),
      feuxAuto: _toTinyInt(json["feux_auto"]),
      essuieGlaceAuto: _toTinyInt(json["essuie_glace_auto"]),
      bluetooth: _toTinyInt(json["bluetooth"]),
      usb: _toTinyInt(json["usb"]),
      ecranTactile: _toTinyInt(json["ecran_tactile"]),
      jantesAlliage: _toTinyInt(json["jantes_alliage"]),
      retroviseursElectriques: _toTinyInt(json["retroviseurs_electriques"]),
      vitresTeintees: _toTinyInt(json["vitres_teintees"]),
      fermetureCentralisee: _toTinyInt(json["fermeture_centralisee"]),
      startStop: _toTinyInt(json["start_stop"]),
      alarme: _toTinyInt(json["alarme"]),
      antiDemarrage: _toTinyInt(json["anti_demarrage"]),
      projecteursLed: _toTinyInt(json["projecteurs_led"]),
      projecteursXenon: _toTinyInt(json["projecteurs_xenon"]),
      toitPanoramique: _toTinyInt(json["toit_panoramique"]),
      directionAssistee: _toTinyInt(json["direction_assistee"]),
      ordinateurBord: _toTinyInt(json["ordinateur_bord"]),
      volantMultifonction: _toTinyInt(json["volant_multifonction"]),
      aideDemarrageCote: _toTinyInt(json["aide_demarrage_cote"]),

      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now(),
    );
  }

  /// 🔄 TO JSON (vers l'API / DB)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "idoptions_cars": idoptionsCars,
      "idcars": idcars,
      "abs": abs,
      "esp": esp,
      "airbags": airbags,
      "climatisation": climatisation,
      "clim_auto": climAuto,
      "regulateur_vitesse": regulateurVitesse,
      "limiteur_vitesse": limiteurVitesse,
      "gps": gps,
      "sieges_chauffants": siegesChauffants,
      "sieges_cuir": siegesCuir,
      "toit_ouvrant": toitOuvrant,
      "camera_recul": cameraRecul,
      "aide_stationnement": aideStationnement,
      "radar_avant": radarAvant,
      "radar_arriere": radarArriere,
      "detecteur_angle_mort": detecteurAngleMort,
      "feux_auto": feuxAuto,
      "essuie_glace_auto": essuieGlaceAuto,
      "bluetooth": bluetooth,
      "usb": usb,
      "ecran_tactile": ecranTactile,
      "jantes_alliage": jantesAlliage,
      "retroviseurs_electriques": retroviseursElectriques,
      "vitres_teintees": vitresTeintees,
      "fermeture_centralisee": fermetureCentralisee,
      "start_stop": startStop,
      "alarme": alarme,
      "anti_demarrage": antiDemarrage,
      "projecteurs_led": projecteursLed,
      "projecteurs_xenon": projecteursXenon,
      "toit_panoramique": toitPanoramique,
      "direction_assistee": directionAssistee,
      "ordinateur_bord": ordinateurBord,
      "volant_multifonction": volantMultifonction,
      "aide_demarrage_cote": aideDemarrageCote,
      "created_at": createdAt.toIso8601String(),
    };
  }
}
