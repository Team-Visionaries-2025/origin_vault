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
  String selectedWarehouse = 'Select Warehouse';
  String selectedProduct = 'Select Product';
  DateTime? expirationDate;

  // Sample inventory data - Replace with your database fetch
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
                    _buildInventoryManagement(),
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
        underline: SizedBox(),
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
          lastDate: DateTime.now().add(Duration(days: 365 * 2)),
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

  Widget _buildScannedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scanned Products',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        ...scannedProducts
            .map((product) => _buildProductTile(product))
            .toList(),
      ],
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
            child: Text(
              '${entry.key}: ${entry.value}',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          );
        }).toList(),
      ),
    );
  }
}
