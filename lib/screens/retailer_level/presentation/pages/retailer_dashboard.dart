import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Define Product class at the top level
class ProductModel {
  final String id;
  final String name;
  final String type;
  final String origin;
  final String farmerId;
  final String createdAt;
  final String blockchainHash;
  final String quantity;
  final String? imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.type,
    required this.origin,
    required this.farmerId,
    required this.createdAt,
    required this.blockchainHash,
    required this.quantity,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['product_id'] ?? '',
      farmerId: json['farmer_id'] ?? '',
      name: json['product_name'] ?? '',
      type: json['product_type'] ?? '',
      origin: json['origin_location'] ?? '',
      createdAt: json['created_at'] ?? '',
      blockchainHash: json['blockchain_hash'] ?? '',
      quantity: json['product_quantity'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}

class RetailerDashboard extends StatefulWidget {
  const RetailerDashboard({super.key});

  @override
  State<RetailerDashboard> createState() => _RetailerDashboardState();
}

class _RetailerDashboardState extends State<RetailerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final supabase = Supabase.instance.client;
  ProductModel? scannedProduct;
  bool isLoading = false;
  String selectedWarehouse = 'Select Warehouse';
  String selectedProduct = 'Select Product';
  DateTime? expirationDate;

  final List<Map<String, dynamic>> inventoryData = [
    {'name': 'Product 1', 'type': 'Fruit', 'stock': 120},
    {'name': 'Product 2', 'type': 'Wheat', 'stock': 264},
    {'name': 'Product 3', 'type': 'Rice', 'stock': 544},
    {'name': 'Product 4', 'type': 'Vegetables', 'stock': 74},
    {'name': 'Product 5', 'type': 'Milk', 'stock': 221},
  ];

  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchProductData(String productId) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (kDebugMode) {
        print("Making Supabase request for product ID: $productId");
      } // Debug print

      final response = await supabase
          .from('product_data_table')
          .select()
          .eq('product_id', productId)
          .single();

      if (kDebugMode) {
        print("Supabase response: $response");
      } // Debug print

      if (mounted) {
        setState(() {
          scannedProduct = ProductModel.fromJson(response);
        });
        if (kDebugMode) {
          print("Product data: ${scannedProduct?.name}");
        } // Debug print
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      } // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching product data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (kDebugMode) {
      print("Barcode detected: ${barcodeCapture.barcodes}");
    } // Debug print

    if (barcodeCapture.barcodes.isNotEmpty) {
      final String? code = barcodeCapture.barcodes.first.rawValue;
      if (kDebugMode) {
        print("Code value: $code");
      } // Debug print

      if (code != null && code.isNotEmpty) {
        Navigator.pop(context);
        if (kDebugMode) {
          print("Fetching data for code: $code");
        } // Debug print
        _fetchProductData(code);
      }
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
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.cyanAccent,
                        ),
                      )
                    else if (scannedProduct != null)
                      _buildProductDetailsTile(scannedProduct),
                    SizedBox(height: 20.h),
                    _buildInventoryManagement(),
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

  // Previous widget building methods remain the same

  Widget _buildProductDetailsTile(ProductModel? product) {
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
          SizedBox(height: 12.h),
          _buildDetailRow(
              'Farmer ID:', product?.farmerId ?? 'No product scanned'),
          SizedBox(height: 12.h),
          _buildDetailRow(
              'Created At:', product?.createdAt ?? 'No product scanned'),
          SizedBox(height: 12.h),
          _buildDetailRow('Blockchain Hash:',
              product?.blockchainHash ?? 'No product scanned'),
          SizedBox(height: 12.h),
          _buildDetailRow(
              'Quantity:', product?.quantity ?? 'No product scanned'),
          if (product?.imageUrl != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                product!.imageUrl!,
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.cyanAccent,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
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

  void _scanBarcode() {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow closing by tapping outside
      builder: (context) => Dialog(
        child: SizedBox(
          height: 300.h,
          child: MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              if (kDebugMode) {
                print("Scanner error: $error");
              } // Debug print
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 50.sp),
                    SizedBox(height: 8.h),
                    Text(
                      'Scanner Error: ${error.toString()}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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

  Widget _buildInventoryManagement() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDropdownButton(
            selectedWarehouse,
            ['Select Warehouse', 'Warehouse 1', 'Warehouse 2'],
            (value) => setState(() => selectedWarehouse = value!),
          ),
          SizedBox(height: 20.h),
          _buildInventoryTable(),
          SizedBox(height: 20.h),
          _buildDropdownButton(
            selectedProduct,
            [
              'Select Product',
              ...inventoryData.map((e) => e['name'] as String)
            ],
            (value) => setState(() => selectedProduct = value!),
          ),
          SizedBox(height: 16.h),
          _buildExpirationDateField(),
          SizedBox(height: 20.h),
          _buildReOrderButton(),
        ],
      ),
    );
  }

  Widget _buildDropdownButton(
      String value, List<String> items, void Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
        dropdownColor: Colors.black,
        isExpanded: true,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildInventoryTable() {
    return Column(
      children: [
        Row(
          children: [
            _buildTableHeader('Product\nName', flex: 2),
            _buildTableHeader('Product\nType', flex: 2),
            _buildTableHeader('Stock\nLevels', flex: 1),
          ],
        ),
        SizedBox(height: 8.h),
        ...inventoryData.map((item) => Column(
              children: [
                Row(
                  children: [
                    _buildTableCell(item['name'], flex: 2),
                    _buildTableCell(item['type'], flex: 2),
                    _buildTableCell(item['stock'].toString(), flex: 1),
                  ],
                ),
                SizedBox(height: 8.h),
              ],
            )),
      ],
    );
  }

  Widget _buildTableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.cyanAccent,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
    );
  }

  Widget _buildExpirationDateField() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Colors.cyanAccent,
                  surface: Colors.grey[900]!,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() => expirationDate = date);
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Expiration Date: ${expirationDate?.toString().split(' ')[0] ?? 'dd/mm/yyyy'}',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
            Icon(Icons.calendar_today, color: Colors.white, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildReOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle re-order logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          'Re-Order',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
