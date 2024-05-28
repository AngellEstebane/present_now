import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:present_now/iniciomaestros/reportes_screen.dart';
import 'save_and_open_pdf.dart';

class SimplePdfApi {
  static Future<File> generateSimpleTextPdf(Subject materia) async {
    final pdf = Document();
    pdf.addPage(Page(
      build: (_) => Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: PdfColors.black),
          borderRadius: BorderRadius.circular(10),
          color: PdfColors.white,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
                'Materia: ${materia.nombreMateria} Grupo: ${materia.nombreGrupo}',
                style: const TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('Hora ${materia.hora} Aula:${materia.aulaNombre}',
                style: const TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('Profesor: ${materia.profesorNombre}',
                style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    ));

    final headers = ['Age', 'name'];
    final users = [
      const User(name: 'oscar', age: '24'),
      const User(name: 'oscar1', age: '25'),
      const User(name: 'oscar2', age: '26'),
    ];

    final data = users.map((user) => [user.name, user.age]).toList();

    pdf.addPage(
      Page(
        build: (context) => TableHelper.fromTextArray(
            data: data,
            headers: headers,
            cellAlignment: Alignment.center,
            tableWidth: TableWidth.max,
            headerHeight: 150,
            cellHeight: 100,
            border: TableBorder.all(width: 5),
            headerStyle: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            cellStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ),
    );
    return SaveAndOpenDocument.savePdf(name: 'reporte.pdf', pdf: pdf);
  }
}

class User {
  final String name;
  final String age;

  const User({required this.name, required this.age});
}
