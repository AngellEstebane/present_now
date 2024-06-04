// lib/models/entradas_maestrosprovider.dart

class MaestrosResponse {
  final int id;
  final String profesorRfc;
  final DateTime fechaHora;
  final int entro;
  final String aula;
  final DateTime fechaConHora;

  MaestrosResponse({
    required this.id,
    required this.profesorRfc,
    required this.fechaHora,
    required this.entro,
    required this.aula,
    required this.fechaConHora,
  });

 factory MaestrosResponse.fromJson(Map<String, dynamic> json) => MaestrosResponse(
      id: json["id"],
      profesorRfc: json["profesorRfc"],
      fechaHora: DateTime.parse(json["fechaHora"].toString()), // Add .toString()
      entro: json["entro"],
      aula: json["aula"],
      fechaConHora: DateTime.parse(json["fechaConHora"].toString()), // Add .toString()
    );

  Map<String, dynamic> toJson() => {
        "id": id,
        "profesorRfc": profesorRfc,
        "fechaHora": fechaHora.toIso8601String(),
        "entro": entro,
        "aula": aula,
        "fechaConHora": fechaConHora.toIso8601String(),
      };
}
