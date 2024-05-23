import 'package:meta/meta.dart';
import 'dart:convert';

class Apod {
  String claveMateria;
  String nombreMateria;
  int semestre;
  int planEstudioId;
  String horaInicio;
  String profesorRfc;
  String numeroControl;
  String aula;

  Apod({
    required this.claveMateria,
    required this.nombreMateria,
    required this.semestre,
    required this.planEstudioId,
    required this.horaInicio,
    required this.profesorRfc,
    required this.numeroControl,
    required this.aula,
  });

  factory Apod.fromRawJson(String str) => Apod.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Apod.fromJson(Map<String, dynamic> json) => Apod(
        claveMateria: json["ClaveMateria"],
        nombreMateria: json["NombreMateria"],
        semestre: json["Semestre"],
        planEstudioId: json["PlanEstudioId"],
        horaInicio: json["HoraInicio"],
        profesorRfc: json["ProfesorRFC"],
        numeroControl: json["NumeroControl"],
        aula: json["aula"],
      );

  Map<String, dynamic> toJson() => {
        "ClaveMateria": claveMateria,
        "NombreMateria": nombreMateria,
        "Semestre": semestre,
        "PlanEstudioId": planEstudioId,
        "HoraInicio": horaInicio,
        "ProfesorRFC": profesorRfc,
        "NumeroControl": numeroControl,
        "aula": aula,
};
}