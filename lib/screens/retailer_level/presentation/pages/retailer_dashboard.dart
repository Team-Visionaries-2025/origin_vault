import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class RetailerDashboard extends StatefulWidget {
  const RetailerDashboard({Key? key}) : super(key: key);

  @override
  State<RetailerDashboard> createState() => _RetailerDashboardState();
}

class _RetailerDashboardState extends State<RetailerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, String>> scannedProducts = [];
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed
        .noDuplicates, // Avoid processing same barcode multiple times
    returnImage: false, // Reduce memory usage
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (barcodeCapture.barcodes.isEmpty) return;

    final String? code = barcodeCapture.barcodes.first.rawValue;

    if (code != null && !scannedProducts.any((p) => p['Product ID'] == code)) {
      setState(() {
        scannedProducts.add({
          'Product ID': code,
          'Product Name': 'Sample Product',
          'Product Type': 'Pulses',
          'Product Origin': 'Location Name',
          'Product Certification': 'Cert No. 12345, Cert No. 67890'
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopNavBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    SizedBox(height: 20.h),
                    _buildScannerButtons(),
                    SizedBox(height: 20.h),
                    _buildScannedProducts(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Iconsax.candle_2, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          IconButton(
            icon: const Icon(Iconsax.notification, color: Colors.white),
            onPressed: () {
              // Handle Notification Navigation
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello Retailer',
            style: TextStyle(color: Colors.white, fontSize: 24.sp)),
        Text('Welcome Back!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  Widget _buildScannerButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _scanBarcode(),
            child: _buildScannerCard('QR Scanner', Iconsax.scan),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: GestureDetector(
            onTap: () => _scanBarcode(),
            child: _buildScannerCard('Barcode Scanner', Iconsax.barcode),
          ),
        ),
      ],
    );
  }

  void _scanBarcode() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 300.h,
          child: MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Text(
                  'Scanner Error: ${error.toString()}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScannerCard(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 32.sp),
          SizedBox(height: 8.h),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 18.sp)),
        ],
      ),
    );
  }

  Widget _buildScannedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          scannedProducts.map((product) => _buildProductTile(product)).toList(),
    );
  }

  Widget _buildProductTile(Map<String, String> product) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: product.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Text('${entry.key}: ${entry.value}',
                style: TextStyle(color: Colors.white, fontSize: 16.sp)),
          );
        }).toList(),
      ),
    );
  }
}
