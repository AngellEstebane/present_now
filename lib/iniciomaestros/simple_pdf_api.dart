import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Alias para el paquete pdf
import 'package:collection/collection.dart';
import 'package:present_now/admin/reportes_maestros.dart';
import 'package:present_now/iniciomaestros/reportes_screen.dart';
import 'save_and_open_pdf.dart';

class SimplePdfApi {
  static Future<File> generateSimpleTextPdf(
      Subject materia, String materiaId, List<Asistencia> asistencias) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (_) => pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 2, color: PdfColors.black),
          borderRadius: pw.BorderRadius.circular(0),
          color: PdfColors.white,
        ),
        padding: const pw.EdgeInsets.all(20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 20),
            pw.Text(
                'Materia: ${materia.Id_Materia}  Grupo: ${materia.NombreGrupo}  Hora ${materia.Hora}',
                style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 10),
            pw.Text('Aula:${materia.Aula}',
                style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
          ],
        ),
      ),
    ));

    // Obtener todas las fechas únicas y agrupar las asistencias por AlumnoId
    final fechasUnicas = asistencias.map((e) => e.fecha).toSet().toList()
      ..sort();
    final asistenciasPorAlumno = <String, Map<String, String>>{};

    for (var asistencia in asistencias) {
      if (!asistenciasPorAlumno.containsKey(asistencia.alumnoId)) {
        asistenciasPorAlumno[asistencia.alumnoId] = {};
      }
      asistenciasPorAlumno[asistencia.alumnoId]![asistencia.fecha] =
          asistencia.presente.toString();
    }

    // Dividir fechas en grupos de 5
    final List<List<String>> gruposDeFechas = [];
    for (var i = 0; i < fechasUnicas.length; i += 5) {
      gruposDeFechas.add(fechasUnicas.sublist(
          i, i + 5 > fechasUnicas.length ? fechasUnicas.length : i + 5));
    }

    for (var grupoFechas in gruposDeFechas) {
      final headers = ['Numero de control', ...grupoFechas];
      final data = asistenciasPorAlumno.entries.map((entry) {
        final alumnoId = entry.key;
        final asistencias = entry.value;
        return [
          alumnoId,
          ...grupoFechas.map((fecha) => asistencias[fecha] ?? '0')
        ];
      }).toList();

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Table.fromTextArray(
            data: data,
            headers: headers,
            cellAlignment: pw.Alignment.center,
            tableWidth: pw.TableWidth.max,
            border: pw.TableBorder.all(width: 1),
            headerStyle:
                pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(fontSize: 10),
          ),
        ),
      );
    }

    return SaveAndOpenDocument.savePdf(name: 'reporte.pdf', pdf: pdf);
  }

  static Future<File> generateSimpleTextMaestrosPdf(
      Profesor maestro, List<AsistenciaMaestro> asistencias) async {
    final pdf = pw.Document();

    // Agrupar las asistencias por fecha
    final asistenciasPorFecha = groupBy(
      asistencias,
      (asistencia) =>
          DateFormat('yyyy-MM-dd').format(DateTime.parse(asistencia.fechaHora)),
    );

    // Recorrer las asistencias por fecha
    asistenciasPorFecha.forEach((fecha, asistenciasDelDia) {
      final List<List<String>> data = [
        ['Hora', 'Entro', 'Aula']
      ];

      asistenciasDelDia.forEach((asistencia) {
        data.add([
          DateFormat('HH:mm').format(DateTime.parse(asistencia.fechaHora)),
          asistencia.entro.toString(),
          asistencia.aula
        ]);
      });

      pdf.addPage(pw.Page(
        build: (_) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 2, color: PdfColors.black),
            borderRadius: pw.BorderRadius.circular(0),
            color: PdfColors.white,
          ),
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.Text('Fecha: $fecha', style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                data: data,
                cellAlignment: pw.Alignment.center,
                tableWidth: pw.TableWidth.max,
                border: pw.TableBorder.all(width: 1),
                headerStyle:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ));
    });

    return SaveAndOpenDocument.savePdf(name: 'reporte.pdf', pdf: pdf);
  }
}
