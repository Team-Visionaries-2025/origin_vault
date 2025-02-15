import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class QRCodeGenerationPage extends StatefulWidget {
  const QRCodeGenerationPage({super.key});

  @override
  State<QRCodeGenerationPage> createState() => _QRCodeGenerationPageState();
}

class _QRCodeGenerationPageState extends State<QRCodeGenerationPage> {
  String? selectedProductId;
  List<String> productIds = [];
  final GlobalKey qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchProductIds();
  }

  Future<void> fetchProductIds() async {
    try {
      final supabase = Supabase.instance.client;
      final response =
          await supabase.from('product_data_table').select('product_id');

      setState(() {
        productIds = List<String>.from(
            response.map((item) => item['product_id'].toString()));
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching product IDs: $e')));
    }
  }

  // Function to get QR image bytes
  Future<Uint8List?> _getQrImageBytes() async {
    try {
      final boundary =
          qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      final image = await boundary?.toImage(pixelRatio: 3.0);
      final byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing QR code: $e')));
      return null;
    }
  }

  // Copy QR Code
  Future<void> _copyQR() async {
    if (!mounted) return;

    try {
      if (selectedProductId != null) {
        await Clipboard.setData(ClipboardData(text: selectedProductId!));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product ID copied to clipboard')));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error copying: $e')));
    }
  }

  // Share QR Code
  Future<void> _shareQR() async {
    final bytes = await _getQrImageBytes();
    if (bytes == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_code.png');
      await file.writeAsBytes(bytes);

      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: 'QR Code for Product');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error sharing QR code: $e')));
    }
  }

  // Print QR Code
  Future<void> _printQR() async {
    final bytes = await _getQrImageBytes();
    if (bytes == null) return;

    try {
      final pdf = pw.Document();
      final image = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );

      // Get the downloads directory
      final directory = Directory('/storage/emulated/0/Download');
      final String fileName =
          'qr_code_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '${directory.path}/$fileName';
      final File file = File(filePath);

      // Save PDF
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('PDF saved to: $filePath'),
        duration: const Duration(seconds: 2),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error creating PDF: $e')));
    }
  }

  // Save QR Code to Downloads
  Future<void> _saveQR() async {
    final bytes = await _getQrImageBytes();
    if (bytes == null) return;

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final String fileName =
            'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
        final String filePath = '${directory.path}/$fileName';
        final File file = File(filePath);
        await file.writeAsBytes(bytes);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('QR Code saved to: $filePath'),
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving QR code: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.cyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('QR Code Generation',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedProductId,
              decoration: InputDecoration(
                labelText: 'Product ID',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[900],
                labelStyle: const TextStyle(color: Colors.white),
              ),
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              items: productIds.map((String id) {
                return DropdownMenuItem(
                  value: id,
                  child: Text(id),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedProductId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            if (selectedProductId != null)
              RepaintBoundary(
                key: qrKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(
                    data: selectedProductId!,
                    size: 200,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.copy,
                  label: 'Copy As Image',
                  onPressed: _copyQR,
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onPressed: _shareQR,
                ),
                _buildActionButton(
                  icon: Icons.print,
                  label: 'Print QR',
                  onPressed: _printQR,
                ),
                _buildActionButton(
                  icon: Icons.download,
                  label: 'Save To Device',
                  onPressed: _saveQR,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
