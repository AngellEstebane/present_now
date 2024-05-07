import 'package:flutter/material.dart';

// Lista de listas de materias para cada retícula
final Map<String, List<List<String>>> materiasPorReticula = {
  "Ingeniería en Sistemas Computacionales": [
    // Primer Semestre
    [
      "Cálculo Diferencial",
      "Fundamentos de Programación",
      "Taller de Ética",
      "Matemáticas Discretas",
      "Fundamentos de Investigación",
      "Taller de Administración",
    ],
    // Segundo Semestre
    [
      "Cálculo Integral",
      "Programación Orientada a Objetos",
      "Contabilidad Financiera",
      "Química",
      "Desarrollo Sustentable",
      "Probabilidad y Estadística",
    ],
    // Tercer Semestre
    [
      "Cálculo Vectorial",
      "Estructura de Datos",
      "Cultura Empresarial",
      "Álgebra Lineal",
      "Sistemas Operativos",
      "Física General",
    ],
    // Cuarto Semestre
    [
      "Ecuaciones Diferenciales",
      "Tópicos Avanzados de Programación",
      "Fundamentos de Bases de Datos",
      "Métodos Numéricos",
      "Taller de Sistemas Operativos",
      "Principios Eléctricos y Aplicaciones Digitales",
    ],
    // Quinto Semestre
    [
      "Investigación de Operaciones",
      "Fundamentos de Telecomunicaciones",
      "Taller de Bases de Datos",
      "Simulación",
      "Fundamentos de Ingeniería de Software",
      "Arquitectura de Computadoras",
    ],
    // Sexto Semestre
    [
      "Lenguajes y Autómatas",
      "Redes de Computadoras",
      "Administración de Bases de Datos",
      "Graficación",
      "Ingeniería de Software",
      "Lenguajes de Interfaz",
    ],
    // Séptimo Semestre
    [
      "Lenguajes y Autómatas II",
      "Conmutación y Enrutamiento de Redes de Datos",
      "Gestión de Proyectos de Software",
      "Taller de Investigación I",
      "Estándares de Calidad de Software",
      "Sistemas Programables",
      "Programación Web",
    ],
    // Octavo Semestre
    [
      "Programación Lógica y Funcional",
      "Administración de Redes",
      "Tecnologías Móviles I",
      "Taller de Investigación II",
      "Inteligencia Artificial",
      "Desarrollo Web Full Stack",
    ],
    // Noveno Semestre
    [
      "Tecnologías Móviles II",
      "Metodologías Ágiles Para el Desarrollo de Software",
      "Actividades Complementarias",
      "Servicio Social",
      "Residencias Profesionales",
    ],
  ],
};

class IngenieriaSistemasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingeniería en Sistemas Computacionales'),
      ),
      body: ListView.builder(
        itemCount:
            materiasPorReticula['Ingeniería en Sistemas Computacionales']!
                .length,
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
                        'Ingeniería en Sistemas Computacionales']![index]
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
