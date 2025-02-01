import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  String? selectedProduct;
  int rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final List<String> products = [
    'Product 1',
    'Product 2',
    'Product 3'
  ]; // Replace with your actual product list

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 40.h, 10.w, 0),
      color: AppPallete.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Iconsax.arrow_left, color: Colors.cyan),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Feedback',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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

  Widget _buildProductDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppPallete.secondarybackgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: AppPallete.secondarybackgroundColor,
          isExpanded: true,
          hint: Text(
            'Select Product',
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
          ),
          value: selectedProduct,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.cyan),
          items: products.map((String product) {
            return DropdownMenuItem<String>(
              value: product,
              child: Text(
                product,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedProduct = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.cyan,
            size: 40.sp,
          ),
          onPressed: () {
            setState(() {
              rating = index + 1;
            });
          },
        );
      }),
    );
  }

  Widget _buildReviewField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            'REVIEW:',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppPallete.secondarybackgroundColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              TextField(
                controller: _reviewController,
                maxLines: 4,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(16.w),
                  border: InputBorder.none,
                  hintText: 'Write your review here...',
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(1.0),
                    fontSize: 16.sp,
                  ),
                ),
              ),
              Container(
                height: 1.h,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                color: Colors.grey.withOpacity(0.2),
              ),
              Container(
                height: 1.h,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                color: Colors.grey.withOpacity(0.2),
              ),
              Container(
                height: 1.h,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                color: Colors.grey.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        // Validate and submit the review
        if (selectedProduct == null ||
            rating == 0 ||
            _reviewController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in all fields'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // TODO: Implement submission logic
        print('Product: $selectedProduct');
        print('Rating: $rating');
        print('Review: ${_reviewController.text}');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        setState(() {
          selectedProduct = null;
          rating = 0;
          _reviewController.clear();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan,
        minimumSize: Size(200.w, 50.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
      ),
      child: Text(
        'Submit',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),
                  _buildProductDropdown(),
                  SizedBox(height: 30.h),
                  _buildStarRating(),
                  SizedBox(height: 30.h),
                  _buildReviewField(),
                  SizedBox(height: 40.h),
                  Center(child: _buildSubmitButton()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
