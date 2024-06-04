import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:present_now/iniciomaestros/reportes_screen.dart';
import 'save_and_open_pdf.dart';

class SimplePdfApi {
  static Future<File> generateSimpleTextPdf(Subject materia, String materiaId,
      List<Asistencia> asistencias, String fecha) async {
    final pdf = pw.Document();

    final imageData1 = await loadAsset('lib/assets/SEP.png');
    final imageData2 = await loadAsset('lib/assets/TecDelicias.png');
    final imageData3 = await loadAsset('lib/assets/TECNM.png');

    // Obtener fecha inicial y final
    final startDate = DateTime.parse(fecha);
    final endDate = startDate.add(Duration(days: 5)); // 5 días después

    // Obtener asistencias dentro del rango de fechas
    final asistenciasEnRango = asistencias.where((asistencia) {
      final asistenciaDate = DateTime.parse(asistencia.fecha);
      return asistenciaDate.isAfter(startDate) &&
          asistenciaDate.isBefore(endDate);
    }).toList();

    // Obtener todas las fechas únicas y agrupar las asistencias por AlumnoId
    final fechasUnicas = asistenciasEnRango.map((e) => e.fecha).toSet().toList()
      ..sort();
    final asistenciasPorAlumno = <String, Map<String, String>>{};

    for (var asistencia in asistenciasEnRango) {
      if (!asistenciasPorAlumno.containsKey(asistencia.alumnoId)) {
        asistenciasPorAlumno[asistencia.alumnoId] = {};
      }
      asistenciasPorAlumno[asistencia.alumnoId]![asistencia.fecha] =
          asistencia.presente == 1 ? 'Presente' : 'Ausente';
    }

    // Dividir fechas en grupos de 5
    final List<List<String>> gruposDeFechas = [];
    for (var i = 0; i < fechasUnicas.length; i += 5) {
      gruposDeFechas.add(fechasUnicas.sublist(
          i, i + 5 > fechasUnicas.length ? fechasUnicas.length : i + 5));
    }

    // Building the PDF
    pdf.addPage(pw.Page(
      build: (_) => pw.Container(
        padding: const pw.EdgeInsets.all(5),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: 100, // Set the width and height as needed
                  height: 100,
                  child: pw.Image(
                    pw.MemoryImage(imageData1),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.Container(
                  width: 100, // Set the width and height as needed
                  height: 100,
                  child: pw.Image(
                    pw.MemoryImage(imageData3),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.Container(
                  width: 100, // Set the width and height as needed
                  height: 100,
                  child: pw.Image(
                    pw.MemoryImage(imageData2),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Center(
                child: pw.Text('Instituto Tecnologico de Delicias',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 10),
            pw.Center(
                child: pw.Text('LISTA DE ASISTENCIA',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Materia:',
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1, color: PdfColors.black),
                      ),
                      child: pw.Text('${materia.Id_Materia}',
                          style: const pw.TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Grupo:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1, color: PdfColors.black),
                      ),
                      child: pw.Text('${materia.NombreGrupo}',
                          style: const pw.TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Hora:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1, color: PdfColors.black),
                      ),
                      child: pw.Text(materia.Hora,
                          style: const pw.TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Aula:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1, color: PdfColors.black),
                      ),
                      child: pw.Text(materia.Aula,
                          style: const pw.TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Fecha:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1, color: PdfColors.black),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Text(
                            DateFormat('dd/MM/yyyy')
                                .format(DateTime.parse(fecha)),
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(' - ',
                              style: const pw.TextStyle(fontSize: 12)),
                          pw.Text(
                            DateFormat('dd/MM/yyyy').format(
                                DateTime.parse(fecha).add(Duration(days: 5))),
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),
            // Table of Attendance
            pw.Table.fromTextArray(
              data: [
                [
                  'Numero de control',
                  ...fechasUnicas.map((fecha) =>
                      DateFormat('yyyy-MM-dd').format(DateTime.parse(fecha)))
                ],
                ...asistenciasPorAlumno.entries.map((entry) {
                  final alumnoId = entry.key;
                  final asistencias = entry.value;
                  return [
                    alumnoId,
                    ...fechasUnicas.map((fecha) => asistencias[fecha] ?? '0')
                  ];
                }).toList(),
              ],
              cellAlignment: pw.Alignment.center,
              tableWidth: pw.TableWidth.max,
              border: pw.TableBorder.all(width: 1),
              headerStyle: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    ));

    return SaveAndOpenDocument.savePdf(name: 'reporte.pdf', pdf: pdf);
  }

  static Future<Uint8List> loadAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }
}
