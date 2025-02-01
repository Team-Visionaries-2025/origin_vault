import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:origin_vault/blockchain_service/blockchain_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final BlockchainService blockchainService = BlockchainService();
  bool isLoading = true;
  Map<String, dynamic>? blockchainData;

  @override
  void initState() {
    super.initState();
    fetchBlockChainDetails();
  }

  Future<void> fetchBlockChainDetails() async {
    try {
      final txnHash = widget.product["blockchain_hash"];
      List<dynamic> productData =
          await blockchainService.getProductDetailsByTxnHash(txnHash);

      if (mounted) {
        setState(() {
          blockchainData = {
            "product_id": productData[0],
            "name": productData[1],
            "origin": productData[2],
            "created_at": productData[9],
          };
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          blockchainData = {"error": "Failed to fetch details"};
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Product Details",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Header**
            Text(
              blockchainData?["name"] ?? "Loading...",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Text(
              "Product ID: ${blockchainData?['product_id'] ?? 'Fetching...'}",
              style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),

            // **Blockchain Details**
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.cyan))
                : blockchainData?["error"] != null
                    ? Text("Error: ${blockchainData?["error"]}",
                        style: TextStyle(color: Colors.red, fontSize: 16.sp))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow("Origin", blockchainData!["origin"]),
                          _infoRow("Processing", blockchainData!["processing"]),
                          _infoRow("Stage", blockchainData!["stage"]),
                          _infoRow("Completed", blockchainData!["completed"]),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
            ),
          ),
          Text(
            value,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
