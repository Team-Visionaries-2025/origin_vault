import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';
import 'package:origin_vault/core/widgets/qr_scanner.dart';
import 'package:origin_vault/screens/admin_level/presentation/pages/admin_sidebar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Product {
  final String id;
  final String name;
  final String type;
  final String origin;
  final String processingMethod;

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.origin,
    required this.processingMethod,
  });
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

  Future<void> _onProductScanned(String code) async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('id', code)
          .single();
      
      setState(() {
        _scannedProduct = Product(
          id: response['id'],
          name: response['name'],
          type: response['type'],
          origin: response['origin'],
          processingMethod: response['processing_method'],
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching product: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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

  Widget _buildScannerButton(IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
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
          _buildDetailRow('Product Name:', product?.name ?? 'No product scanned'),
          SizedBox(height: 12.h),
          _buildDetailRow('Product Type:', product?.type ?? 'No product scanned'),
          SizedBox(height: 12.h),
          _buildDetailRow('Product Origin:', product?.origin ?? 'No product scanned'),
          SizedBox(height: 12.h),
          _buildDetailRow(
            'Product Processing Method:',
            product?.processingMethod ?? 'No product scanned',
          ),
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
                          style: TextStyle(color: Colors.white, fontSize: 24.sp),
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
                            _buildScannerButton(
                              Iconsax.scanner,
                              'QR\nScanner',
                              () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const QrScannerPage(),
                                  ),
                                );
                                if (result != null) {
                                  _onProductScanned(result);
                                }
                              },
                            ),
                            SizedBox(width: 16.w),
                            _buildScannerButton(
                              Iconsax.barcode,
                              'Barcode\nScanner',
                              () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const QrScannerPage(),
                                  ),
                                );
                                if (result != null) {
                                  _onProductScanned(result);
                                }
                              },
                            ),
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