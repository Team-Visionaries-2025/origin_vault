import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/blockchain_service/blockchain_service.dart';
import 'package:origin_vault/screens/producer_level/presentation/pages/product_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final supabase = Supabase.instance.client;
  final BlockchainService blockchainService = BlockchainService();

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response = await supabase.from('product_data_table').select();
    if (response.isEmpty) {
      if (kDebugMode) {
        print("No products found ");
      }
    }
    List<Map<String, dynamic>> productList =
        List<Map<String, dynamic>>.from(response);

    // Fetch blockchain data for each product
    List<Map<String, dynamic>> fullProductList = [];

    for (var product in productList) {
      try {
        String txnHash = product['txn_hash'];
        if (txnHash.isEmpty) continue;
        List<dynamic> productData =
            await blockchainService.getProductDetailsByTxnHash(txnHash);

        if (productData.isEmpty) continue;

        fullProductList.add({
          'blochchain_hash': txnHash,
          'name': productData[1],
          'origin': productData[2],
          'created_at': product['created_at'],
        });
      } catch (e) {
        throw Exception("Error fetching product data: $e");
      }
    }
    return fullProductList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
            const Text("Your Products", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.cyan));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("No products added yet",
                  style: TextStyle(color: Colors.grey[400])),
            );
          }
          final products = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        product: product,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? 'Unknown Product',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Origin: ${product['origin'] ?? 'Unknown'}",
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Iconsax.arrow_right_3,
                          color: Colors.cyan, size: 24),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
