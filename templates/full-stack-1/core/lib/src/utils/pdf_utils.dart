
//import 'package:pdf_fork/pdf.dart';
import 'package:new_sali_core/new_sali_core.dart';
import 'package:pdf_fork/widgets.dart';


// import 'package:http/http.dart' as http;

/// Download an image from the network.
// Future<ImageProvider> networkImage(
//   String url, {
//   Map<String, String>? headers,
//   PdfImageOrientation? orientation,
//   double? dpi,
// }) async {
//   var response = await http.get(Uri.parse(url), headers: headers);
//   return MemoryImage(response.bodyBytes, orientation: orientation, dpi: dpi);
// }


List<Widget> breakTextWidget(String text,
    {int limit = 1023, TextStyle? style}) {
  if (text.length < limit) {
    return [Text(text, style: style)];
  } else {
    final items = <Widget>[];
    final chunks = SaliCoreUtils.slicesText(text, length: limit);
    for (var chunk in chunks) {
      items.add(Text(chunk, style: style));
    }

    return items;
  }
}
