import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Alias para el paquete pdf
import 'package:present_now/admin/reportes_maestros.dart';
import 'package:present_now/iniciomaestros/save_and_open_pdf.dart';

class SimplePdfApiMaestros {
  static Future<File> generateSimpleTextPdf(Profesor profesor,
      List<AsistenciaMaestro> asistencias, String fecha) async {
    final pdf = pw.Document();

    final imageData1 = await loadAsset('lib/assets/SEP.png');
    final imageData2 = await loadAsset('lib/assets/TecDelicias.png');
    final imageData3 = await loadAsset('lib/assets/TECNM.png');

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
                  width: 100,
                  height: 100,
                  child: pw.Image(
                    pw.MemoryImage(imageData1),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.Container(
                  width: 100,
                  height: 100,
                  child: pw.Image(
                    pw.MemoryImage(imageData3),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.Container(
                  width: 100,
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
                child: pw.Text('LISTA DE ASISTENCIA CATEDRATICO',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('NOMBRE:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1, color: PdfColors.black),
                      ),
                      child: pw.Text(profesor.profesorNombre,
                          style: const pw.TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('RFC:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1, color: PdfColors.black),
                      ),
                      child: pw.Text(profesor.rfc,
                          style: const pw.TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Departamento:',
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1, color: PdfColors.black),
                      ),
                      child: pw.Text('${profesor.departamentoId}',
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
                      child: pw.Text(
                          DateFormat('yyyy-MM-dd-HH:mm').format(
                              DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ')
                                  .parse(asistencias[0].fechaHora)),
                          style: const pw.TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.center,
              headers: ['ID', 'Fecha/Hora', 'Estado', 'Aula'],
              data: asistencias.map((asistencia) {
                return [
                  asistencia.id.toString(),
                  DateFormat('yyyy-MM-dd-HH:mm').format(
                      DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ')
                          .parse(asistencia.fechaHora)),
                  asistencia.entro == 0 ? 'Ausente' : 'Presente',
                  asistencia.aula,
                ];
              }).toList(),
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
