import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:origin_vault/screens/consumer_level/presentation/pages/product_information.dart';

class ScannedProduct {
  final String historyId;
  final String userId;
  final String productId;
  final String productName;
  final DateTime? purchaseDate;
  final double amount;
  final String purchaseLocation;
  final String originLocation;
  final String productType;
  final int productQuantity;
  final String imageUrl;

  ScannedProduct({
    required this.historyId,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.purchaseDate,
    required this.amount,
    required this.purchaseLocation,
    required this.originLocation,
    required this.productType,
    required this.productQuantity,
    required this.imageUrl,
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
  bool _isLoading = true;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchScanHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        title: const Text('Scan History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return _buildProductTile(_products[index]);
              },
            ),
    );
  }

  Future<void> _fetchScanHistory() async {
    try {
      final response = await supabase
          .from('consumer_product_history_table')
          .select('*')
          .order('purchase_date', ascending: false);

      setState(() {
        _products = response.map((data) {
          DateTime? purchaseDate;
          try {
            purchaseDate = data['purchase_date'] != null &&
                    data['purchase_date'].toString().isNotEmpty
                ? DateTime.parse(data['purchase_date'])
                : null;
          } catch (e) {
            print('Invalid date format: ${data['purchase_date']}');
            purchaseDate = null;
          }

          return ScannedProduct(
            historyId: data['history_id'] ?? '',
            userId: data['user_id'] ?? '',
            productId: data['product_id'] ?? '',
            productName: data['product_name'] ?? 'Unknown Product',
            purchaseDate: purchaseDate,
            amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
            purchaseLocation: data['purchase_location'] ?? 'Unknown',
            originLocation: data['origin_location'] ?? 'Unknown',
            productType: data['product_type'] ?? 'Unknown',
            productQuantity:
                int.tryParse(data['product_quantity']?.toString() ?? '0') ?? 0,
            imageUrl: data['image_url'] ?? '',
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching consumer product history: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProductTile(ScannedProduct product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productName: product.productName,
              date: product.purchaseDate != null
                  ? DateFormat('dd/MM/yyyy').format(product.purchaseDate!)
                  : 'Unknown',
              time: product.purchaseDate != null
                  ? DateFormat('h:mm a').format(product.purchaseDate!)
                  : 'Unknown',
              origin: product.originLocation,
              description: 'Purchased at ${product.purchaseLocation}',
              imageUrl: product.imageUrl,
              rating: 4.0,
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
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.productName,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold)),
                  Text('Origin: ${product.originLocation}',
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                  Text('Product Type: ${product.productType}',
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                  Text('Quantity: ${product.productQuantity}',
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                  Text('Purchased at: ${product.purchaseLocation}',
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                  Text('Amount: ₹${product.amount.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.cyan, fontSize: 14.sp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
