import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';
import 'package:origin_vault/screens/consumer_level/presentation/pages/product_information.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ScannedProduct {
  final String id;
  final String name;
  final String origin;
  final String processingMethod;
  final String imageUrl;
  final DateTime scanDate;

  ScannedProduct({
    required this.id,
    required this.name,
    required this.origin,
    required this.processingMethod,
    required this.imageUrl,
    required this.scanDate,
  });
}

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ScannedProduct> _products = [];
  List<ScannedProduct> _filteredProducts = [];
  bool _isLoading = true;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchScanHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchScanHistory() async {
    try {
      final response = await supabase
          .from('scan_history')
          .select('*, products(*)')
          .order('scan_date', ascending: false);

      setState(() {
        _products = response
            .map((data) => ScannedProduct(
                  id: data['products']['id'],
                  name: data['products']['name'],
                  origin: data['products']['origin'],
                  processingMethod: data['products']['processing_method'],
                  imageUrl: data['products']['image_url'],
                  scanDate: DateTime.parse(data['scan_date']),
                ))
            .toList();
        _filteredProducts = List.from(_products);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching scan history: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.id.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      height: 48.h,
      decoration: BoxDecoration(
        color: AppPallete.secondarybackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.cyan
              .withOpacity(0.2), // Reduced opacity for subtler border
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Icon(
              Iconsax.search_normal,
              color: Colors.cyan.withOpacity(0.7), // Slightly dimmed icon
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: Colors.grey[900], // Lighter grey for better visibility
                fontSize: 15.sp,
                height: 1.0,
              ),
              cursorColor: Colors.cyan.withOpacity(0.7), // Custom cursor color
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search product code or name...',
                hintStyle: TextStyle(
                  color: Colors.grey[200], // Darker grey for hint text
                  fontSize: 15.sp,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                focusedBorder: InputBorder.none, // Remove focus border
                enabledBorder: InputBorder.none, // Remove enabled border
              ),
              onChanged: _filterProducts,
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 8.w),
            child: Icon(
              Icons.arrow_drop_down,
              color: Colors.cyan.withOpacity(0.7), // Matching icon color
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(ScannedProduct product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productName: product.name,
              date: DateFormat('dd/MM/yyyy').format(product.scanDate),
              time: DateFormat('h:mm a').format(product.scanDate),
              origin: product.origin,
              description:
                  'Lorem Ipsum is simply dummy text...', // You might want to add description field to your ScannedProduct model
              imageUrl: product.imageUrl,
              rating:
                  4.0, // You might want to add rating field to your ScannedProduct model
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppPallete.secondarybackgroundColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Rest of your existing tile UI code remains the same
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                product.imageUrl,
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80.w,
                    height: 80.w,
                    color: Colors.grey.shade800,
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Origin: ${product.origin}',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                  Text(
                    'Processing Method: ${product.processingMethod}',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(product.scanDate),
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
                Text(
                  DateFormat('h:mm a').format(product.scanDate),
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppPallete.backgroundColor,
        elevation: 0,
        title: Text(
          'Searched Product History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.cyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.cyan))
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          return _buildProductTile(_filteredProducts[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
