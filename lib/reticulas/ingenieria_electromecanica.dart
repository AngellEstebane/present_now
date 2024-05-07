import 'package:flutter/material.dart';

// Lista de listas de materias para cada retícula
final Map<String, List<List<String>>> materiasPorReticula = {
  "Ingeniería Electromecánica": [
    // Primer Semestre
    [
      "Taller Ética",
      "Cálculo Diferencial",
      "Álgebra Lineal",
      "Introducción a la Programación",
      "Química",
      "Fundamentos de Investigación",
    ],
    // Segundo Semestre
    [
      "Probabilidad y Estadística",
      "Estática",
      "Desarrollo Sustentable",
      "Cálculo Integral",
      "Metrología y Normalización",
      "Tecnología de los Materiales",
    ],
    // Tercer Semestre
    [
      "Dinámica",
      "Dibujo Electromecánico",
      "Cálculo Vectorial",
      "Electricidad y Magnetismo",
      "Procesos de Manufactura",
    ],
    // Cuarto Semestre
    [
      "Mecánica de Materiales",
      "Análisis y Síntesis de Mecanismos",
      "Ecuaciones Diferenciales",
      "Análisis de Circuitos Eléctricos CD",
      "Electrónica Analógica",
      "Termodinámica",
    ],
    // Quinto Semestre
    [
      "Diseño de Elementos de Máquinas",
      "Mecánica de Fluidos",
      "Análisis de Circuitos Eléctricos CA",
      "Electrónica Digital",
      "Transferencia de Calor",
    ],
    // Sexto Semestre
    [
      "Diseño e Ingeniería Asistido por Computadoras",
      "Sistemas y Máquinas de Fluidos",
      "Máquinas Eléctricas",
      "Instalaciones Eléctricas",
      "Máquinas y Equipos Térmicos I",
      "Taller de Investigación I",
    ],
    // Séptimo Semestre
    [
      "Administración y Técnicas de Mantenimiento",
      "Sistemas Eléctricos de Potencia",
      "Controles Eléctricos",
      "Instrumentación",
      "Máquinas y Equipo Térmicos II",
      "Taller de Investigación II",
    ],
    // Octavo Semestre
    [
      "Ahorro de Energía",
      "Ingeniería de Control Clásico",
      "Sistemas Hidráulico y Neumáticos de Potencia",
      "Subestaciones Eléctricas",
      "Maquinado CNC I",
      "Refrigeración y Aire Acondicionado",
      "Formulación y Evaluación de Proyectos",
    ],
    // Noveno Semestre
    [
      "Calidad Aplicada",
      "Maquinado CNC II",
      "Automatización",
      "Actividades Complementarias",
      "Servicio Social",
      "Residencias Profesionales",
    ],
  ],
};

class IngenieriaElectromecanicaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingeniería Electromecánica'),
      ),
      body: ListView.builder(
        itemCount: materiasPorReticula['Ingeniería Electromecánica']!.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(
              'Semestre ${index + 1}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    materiasPorReticula['Ingeniería Electromecánica']![index]
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
