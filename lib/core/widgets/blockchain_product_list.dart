// import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:origin_vault/blockchain_service/blockchain_service.dart';
// import 'package:origin_vault/core/common/common_pages/forgotpasswordpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../screens/producer_level/presentation/pages/product_detail_page.dart';

class BlockchainProductList extends StatefulWidget {
  final BlockchainService blockchainService;
  final SupabaseClient supabase;
  const BlockchainProductList(
      {super.key, required this.blockchainService, required this.supabase});

  @override
  State<BlockchainProductList> createState() => _BlockchainProductListState();
}

class _BlockchainProductListState extends State<BlockchainProductList> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          error = null;
        });

        // Fetch transaction hashes from supabase
        final response = await widget.supabase
            .from('product_data_table')
            .select()
            .order('created_at', ascending: false);

        if (response.isEmpty) {
          throw Exception('No products found');
        }

        List<Map<String, dynamic>> productList = [];
        for (var row in response) {
          try {
            final blockchainData = await widget.blockchainService
                .getProductDetailsByTxnHash(row['txn_hash']);

            productList.add({
              ...row,
              ...blockchainData,
            });
          } catch (e) {
            if (mounted) {
              setState(() {
                error = "Failed to fetch blockchain data";
                isLoading = false;
              });
            }
          }
          if (mounted) {
            setState(() {
              products = productList;
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = "Failed to fetch products";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product),
              ),
            ),
            title: Text(
              product['productName'] ?? 'Unknown Product',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Origin: ${product['originLocation']}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                ),
                Text(
                  'Status: ${product['stage']}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ),
        );
      },
    );
  }
}
