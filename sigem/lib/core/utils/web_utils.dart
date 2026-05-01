import 'dart:html' as html;
import 'dart:typed_data';

void downloadCsv(Uint8List bytes) {
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'reporte_asistencia.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
}