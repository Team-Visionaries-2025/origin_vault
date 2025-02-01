import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';
import 'package:origin_vault/screens/admin_level/presentation/pages/admin_sidebar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Product {
  final String id;
  final String name;
  final String type;
  final String origin;

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.origin,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] ?? '',
      name: json['product_name'] ?? '',
      type: json['product_type'] ?? '',
      origin: json['origin_location'] ?? '',
    );
  }
}

class Consumerdashboard extends StatefulWidget {
  const Consumerdashboard({super.key});

  @override
  State<Consumerdashboard> createState() => _ConsumerdashboardState();
}

class _ConsumerdashboardState extends State<Consumerdashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final supabase = SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_KEY']!,
  );

  Product? _scannedProduct;
  bool _isLoading = false;

  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    print("Barcode detected: ${barcodeCapture.barcodes}");

    if (barcodeCapture.barcodes.isNotEmpty) {
      final String? code = barcodeCapture.barcodes.first.rawValue;
      print("Code value: $code");

      if (code != null && code.isNotEmpty) {
        Navigator.pop(context);
        print("Fetching data for code: $code");
        _onProductScanned(code);
      }
    }
  }

  Future<void> _onProductScanned(String code) async {
    setState(() => _isLoading = true);
    try {
      print("Making Supabase request for product ID: $code");

      final response = await supabase
          .from('product_data_table')
          .select('product_id, product_name, product_type, origin_location')
          .eq('product_id', code)
          .single();

      print("Supabase response: $response");

      if (mounted && response != null) {
        setState(() {
          _scannedProduct = Product.fromJson(response);
        });
        print("Product data: ${_scannedProduct?.name}");
      }
    } catch (e) {
      print("Error fetching data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scanBarcode() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error, child) {
                    print("Scanner error: $error");
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 50.sp),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Text(
                              'Scanner Error: ${error.toString()}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 200.w,
                      height: 200.w,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 40.h, 10.w, 0),
      color: AppPallete.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Iconsax.candle_2, color: Colors.cyan),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          IconButton(
            icon: const Icon(Iconsax.notification, color: Colors.cyan),
            onPressed: () {
              // Handle notification action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScannerButton(IconData icon, String label) {
    return Expanded(
      child: ElevatedButton(
        onPressed: _scanBarcode,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPallete.secondarybackgroundColor,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.cyan, size: 40.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150.w,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationIcon(Color color) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.verified,
        color: Colors.white,
        size: 24.sp,
      ),
    );
  }

  Widget _buildProductDetailsTile(Product? product) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppPallete.secondarybackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Product ID:', product?.id ?? 'No product scanned'),
          SizedBox(height: 12.h),
          _buildDetailRow(
              'Product Name:', product?.name ?? 'No product scanned'),
          SizedBox(height: 12.h),
          _buildDetailRow(
              'Product Type:', product?.type ?? 'No product scanned'),
          SizedBox(height: 12.h),
          _buildDetailRow(
              'Product Origin:', product?.origin ?? 'No product scanned'),
          if (product != null) ...[
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCertificationIcon(Colors.orange),
                _buildCertificationIcon(Colors.grey),
                _buildCertificationIcon(Colors.amber),
                _buildCertificationIcon(Colors.purple),
                _buildCertificationIcon(Colors.green),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppPallete.backgroundColor,
      drawer: const SideMenu(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello Consumer',
                          style:
                              TextStyle(color: Colors.white, fontSize: 24.sp),
                        ),
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            _buildScannerButton(Iconsax.scanner, 'QR\nScanner'),
                            SizedBox(width: 16.w),
                            _buildScannerButton(
                                Iconsax.barcode, 'Barcode\nScanner'),
                          ],
                        ),
                        _buildProductDetailsTile(_scannedProduct),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.cyan,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
