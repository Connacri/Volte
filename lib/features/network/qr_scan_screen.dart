import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Écran plein cadre qui scanne un QR code et fait un `Navigator.pop`
/// avec la valeur décodée (l'ID du pair) dès qu'un code valide est lu.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();
    _controller.start().then((_) {
      if (mounted) setState(() => _cameraReady = true);
    }).catchError((_) {});
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final value = barcodes.first.rawValue;
    if (value == null || value.trim().isEmpty) return;

    _handled = true;
    Navigator.of(context).pop(value.trim());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner l'ID d'un pair"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            fit: BoxFit.cover,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      "Impossible d'accéder à la caméra.\n"
                      "Vérifie les permissions dans les paramètres.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          if (_cameraReady) ...[
            Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Text(
                "Cadre le QR code du pair à ajouter",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}