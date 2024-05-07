import 'package:flutter/material.dart';

// Lista de listas de materias para cada retícula
final Map<String, List<List<String>>> materiasPorReticula = {
  "Ingeniería en Energías Renovables": [
    // Primer Semestre
    [
      "Química",
      "Programación",
      "Cálculo Diferencial",
      "Fundamentos de Investigación",
      "Dibujo",
      "Fuentes Renovables de Energía",
    ],
    // Segundo Semestre
    [
      "Bioquímica",
      "Tecnología e Ingeniería de Materiales",
      "Cálculo Vectorial",
      "Cálculo Integral",
      "Taller Ética",
      "Estadística y Diseño de Experimentos",
    ],
    // Tercer Semestre
    [
      "Microbiología",
      "Álgebra Lineal",
      "Electromagnetismo",
      "Estática y Dinámica",
      "Taller de Sistemas de Información Geográfica",
      "Metrología Mecánica y Eléctrica",
    ],
    // Cuarto Semestre
    [
      "Comportamiento Humano en las Organizaciones",
      "Óptica y Semiconductores",
      "Circitos Eléctricos I",
      "Resistencia de Materiales",
      "Ecuaciones Diferenciales",
      "Termodinámica",
    ],
    // Quinto Semestre
    [
      "Biocombustibles",
      "Marco Jurídico en Gestión Energética",
      "Circuitos Eléctricos II",
      "Desarrollo Sustentable",
      "Mecánica de Fluídos",
      "Transferencia de Calor",
    ],
    // Sexto Semestre
    [
      "Taller de Investigación I",
      "Instalaciones Eléctricas e Iluminación",
      "Máquinas Eléctricas",
      "Máquinas Hidráulicas",
      "Refrigeración y Aire Acondicionado",
      "Energía Eólica",
    ],
    // Séptimo Semestre
    [
      "Taller de Investigación II",
      "Sistemas Solares Fotovoltaicos y Térmicos",
      "Simulación de Sistemas de Energías Renovables",
      "Electrónica",
      "Instrumentación",
      "Sistemas Térmicos",
    ],
    // Octavo Semestre
    [
      "Formulación y Evaluación de Proyectos de Energías Renovables",
      "Controles Eléctricos",
      "Diseño Eólico",
      "Administación y Técnicas de Conservación",
      "Auditoría Energética",
      "Gestión de Empresas de Energías Renovables",
    ],
    // Noveno Semestre
    [
      "Diseño Solar Térmico",
      "Diseño Solar Fotovoltaico",
      "Servicio Social",
      "Actividades Complementarias",
      "Residencias Profesionales",
    ],
  ],
};

class IngenieriaEnergiasRenovablesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingeniería en Energías Renovables'),
      ),
      body: ListView.builder(
        itemCount:
            materiasPorReticula['Ingeniería en Energías Renovables']!.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(
              'Semestre ${index + 1}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: materiasPorReticula[
                        'Ingeniería en Energías Renovables']![index]
                    .map((materia) => ListTile(
                          title: Text(materia),
                          // Aquí puedes agregar más detalles si lo deseas
                        ))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
