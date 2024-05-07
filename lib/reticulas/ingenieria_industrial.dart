import 'package:flutter/material.dart';

// Lista de listas de materias para cada retícula
final Map<String, List<List<String>>> materiasPorReticula = {
  "Ingeniería Industrial": [
    // Lista de materias por semestre para Ingeniería Industrial
    [
      "Cálculo Diferencial",
      "Taller de Ética",
      "Química",
      "Taller de Herramientas Intelectuales",
      "Dibujo Industrial",
      "Fundamentos de Investigación",
    ],
    // Lista de materias por semestre para Ingeniería Industrial
    [
      "Cálculo Integral",
      "Electricidad y Electrónica Industrial",
      "Probabilidad y Estadística",
      "Propiedad de los Materiales",
      "Ingeniería de Sistemas",
      "Análisis de la Realidad Nacional",
      "Taller de Liderazgo",
    ],
    // Lista de materias por semestre para Ingeniería Industrial
    [
      "Cálculo Vectorial",
      "Estudio del Trabajo I",
      "Estadística Inferencial I",
      "Metrología y Normalización",
      "Álgebra Lineal",
      "Economía",
    ],
    // Lista de materias por semestre para Ingeniería Industrial
    [
      "Higiene y Seguridad Industrial",
      "Estudio del Trabajo II",
      "Estadística Inferencial II",
      "Proceso de Fabricación",
      "Física",
      "Investigación de Operaciones",
      "Algoritmos y Lenguaje de Programación",
    ],
    // Lista de materias por semestre para Ingeniería Industrial
    [
      "Administración de Proyectos",
      "Ergonomía",
      "Control Estadístico de la Calidad",
      "Gestión de Costos",
      "Desarrollo Sustentable",
      "Investigación de Operaciones II",
      "Administración de las Operaciones I",
    ],
    // Lista de materias por semestre para Ingeniería Industrial
    [
      "Administración del Mantenimiento",
      "Mercadotecnia",
      "Diseño De Experimentos Avanzados",
      "Ingeniería Económica",
      "Taller de Investigación I",
      "Simulación",
      "Administración de las Operaciones II",
    ],
    // Lista de materias por semestre para Ingeniería Industrial
    [
      "Planeación y Diseño de Instalaciones",
      "Sistemas de Manufactura",
      "Planeación Financiera",
      "Taller de Investigación II",
      "Diseño Asistido por Computadoras y Máquinas CNC",
      "Gestión de los Sistemas de Calidad",
    ],
    // Lista de materias por semestre para Ingeniería Industrial
    [
      "Logística y Cadenas de Suministro",
      "Auditoria de Sistemas de Gestión",
      "Herramientas Lean",
      "Formulación y Evaluación de Proyectos",
      "Introducción a la Industria 4.0",
      "Manufactura Moderna",
      "Relaciones Industriales",
    ],
    // Lista de materias por semestre para Ingeniería Industrial
    [
      "Servicio Social",
      "Actividades Complementarias",
      "Residencias Profesionales",
    ],
  ],
};

class IngenieriaIndustrialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingeniería Industrial'),
      ),
      body: ListView.builder(
        itemCount: materiasPorReticula['Ingeniería Industrial']!.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(
              'Semestre ${index + 1}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: materiasPorReticula['Ingeniería Industrial']![index]
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
