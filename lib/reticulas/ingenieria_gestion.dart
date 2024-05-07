import 'package:flutter/material.dart';

// Lista de listas de materias para cada retícula
final Map<String, List<List<String>>> materiasPorReticula = {
  "Ingeniería en Gestión Empresarial": [
    // Primer Semestre
    [
      "Cálculo Diferencial",
      "Fundamentos de Física",
      "Fundamentos de Química",
      "Fundamentos de Gestión Empresarial",
      "Desarrollo Humano",
      "Fundamentos de Investigación",
    ],
    // Segundo Semestre
    [
      "Cálculo Integral",
      "Software de Aplicación Ejecutivo",
      "Contabilidad Orientada a los Negocios",
      "Dinámica Social",
      "Taller de Ética",
      "Legislación Laboral",
    ],
    // Tercer Semestre
    [
      "Álgebra Lineal",
      "Probabilidad y Estadística Descriptiva",
      "Costos Empresariales",
      "Habilidades Directivas I",
      "Economía Empresarial",
      "Marco Legal de las Organizaciones",
    ],
    // Cuarto Semestre
    [
      "Investigación de Operaciones",
      "Estadística Inferencial I",
      "Instrumentos de Presupuestación Empresarial",
      "Habilidades Directivas II",
      "Entorno Macro-Económico",
      "Ingeniería Económica",
    ],
    // Quinto Semestre
    [
      "Ingeniería de Procesos",
      "Estadística Inferencial II",
      "Finanzas en las Organizaciones",
      "Gestión del Capital Humano",
      "Mercadotecnia",
      "Taller de Investigación I",
    ],
    // Sexto Semestre
    [
      "Administración de la Salud y Seguridad Organizacional",
      "Gestión de la Producción I",
      "El Emprendedor y la Innovación",
      "Diseño Organizacional",
      "Sistemas de Información de la Mercadotecnia",
      "Taller de Investigación II",
    ],
    // Séptimo Semestre
    [
      "Trámites legales y Gestión del Financiamiento",
      "Gestión de la Producción II",
      "Plan de Negocios",
      "Gestión Estratégica",
      "Mercadotecnia Electrónica",
      "Desarrollo Sustentable",
    ],
    // Octavo Semestre
    [
      "Gestión de Sistemas de Calidad",
      "Negocios Internacionales",
      "Cadena de Suministro",
      "Relaciones Públicas y Servicios",
      "Taller de Simulador de Negocios",
      "Calidad Aplicada a la Gestión Empresarial",
    ],
    // Noveno Semestre
    [
      "Manufactura Esbelta",
      "Actividades Complementarias",
      "Servicio Social",
      "Residencias Profesionales",
    ],
  ],
};

class IngenieriaGestionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingeniería en Gestión Empresarial'),
      ),
      body: ListView.builder(
        itemCount:
            materiasPorReticula['Ingeniería en Gestión Empresarial']!.length,
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
                        'Ingeniería en Gestión Empresarial']![index]
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
