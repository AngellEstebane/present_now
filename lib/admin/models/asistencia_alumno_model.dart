import 'dart:convert';

List<AsistenciaAlumnoModel> asistenciaAlumnoModelFromJson(String str) => List<AsistenciaAlumnoModel>.from(json.decode(str).map((x) => AsistenciaAlumnoModel.fromJson(x)));

String asistenciaAlumnoModelToJson(List<AsistenciaAlumnoModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AsistenciaAlumnoModel {
    int? id;
    String? alumnoId;
    DateTime? fecha;
    int? presente;
    String? materiaId;
    DateTime? fechaConHora;
    DateTime? asistenciaAlumnoModelFecha;

    AsistenciaAlumnoModel({
        this.id,
        this.alumnoId,
        this.fecha,
        this.presente,
        this.materiaId,
        this.fechaConHora,
        this.asistenciaAlumnoModelFecha,
    });

    factory AsistenciaAlumnoModel.fromJson(Map<String, dynamic> json) => AsistenciaAlumnoModel(
        id: json["id"],
        alumnoId: json["AlumnoID"],
        fecha: json["Fecha"] == null ? null : DateTime.parse(json["Fecha"]),
        presente: json["Presente"],
        materiaId: json["materiaId"],
        fechaConHora: json["fechaConHora"] == null ? null : DateTime.parse(json["fechaConHora"]),
        asistenciaAlumnoModelFecha: json["fecha"] == null ? null : DateTime.parse(json["fecha"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "AlumnoID": alumnoId,
        "Fecha": fecha?.toIso8601String(),
        "Presente": presente,
        "materiaId": materiaId,
        "fechaConHora": fechaConHora?.toIso8601String(),
        "fecha": asistenciaAlumnoModelFecha?.toIso8601String(),
    };
}
