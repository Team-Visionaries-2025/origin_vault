import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:origin_vault/screens/admin_level/notification_page.dart';

class Producerdashboard extends StatefulWidget {
  const Producerdashboard({super.key});

  @override
  State<Producerdashboard> createState() => _ProducerdashboardState();
}

class _ProducerdashboardState extends State<Producerdashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controllers for form fields
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productOriginController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  int productQuantity = 1;
  String? selectedProductType;
  String? selectedFilePath;
  LatLng? productLocation;
  GoogleMapController? _mapController;
  List<String> productTypes = ['Organic', 'Non-Organic', 'GMO'];

  /// **Function to Pick File**
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFilePath = result.files.single.name;
      });
    }
  }

  /// **Simulated API Call to Fetch Product Location**
  Future<void> _fetchProductLocation() async {
    setState(() {
      productLocation =
          const LatLng(37.7749, -122.4194); // Example: San Francisco
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: Drawer(
        child: Container(
          color: Colors.grey[900],
          child: Center(
            child: Text("Sidebar Menu", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Top Navigation Bar**
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.candle_2, color: Colors.white),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.notification, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const NotificationScreen()));
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // **Welcome Header**
                    Text('Hello Producer',
                        style: TextStyle(color: Colors.white, fontSize: 24.sp)),
                    Text('Welcome Back!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 20.h),

                    // **Add Product Form (Everything Kept)**
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add Product',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 12.h),

                          // **Product Name Field**
                          Text("Product Name",
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 14.sp)),
                          SizedBox(height: 4.h),
                          TextField(
                            controller: productNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[850],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // **Product Type Dropdown**
                          Text("Product Type",
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 14.sp)),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius: BorderRadius.circular(10.r)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                dropdownColor: Colors.grey[900],
                                style: const TextStyle(color: Colors.white),
                                isExpanded: true,
                                value: selectedProductType,
                                items: productTypes.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedProductType = newValue;
                                  });
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // **Product Quantity Selector**
                          Text("Product Quantity",
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 14.sp)),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    if (productQuantity > 1) productQuantity--;
                                  });
                                },
                              ),
                              Text(productQuantity.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.sp)),
                              IconButton(
                                icon:
                                    const Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    productQuantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                          // **Product Origin Field**
                          Text("Product Origin",
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 14.sp)),
                          SizedBox(height: 4.h),
                          TextField(
                            controller: productOriginController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[850],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // **Product Certification - File Upload**
                          Text("Product Certification",
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 14.sp)),
                          SizedBox(height: 4.h),
                          GestureDetector(
                            onTap: _pickFile,
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedFilePath ??
                                        "Drop files or click to upload",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Icon(Icons.upload_file, color: Colors.cyan),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // **Save & Clear Buttons**
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                  onPressed: () {}, child: const Text("Add")),
                              ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Clear Form")),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // **Product Location Section (Below Form)**
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Track Product Location',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 12.h),
                          TextField(
                            controller: productIdController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[850],
                              hintText: "Enter Product ID",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          ElevatedButton(
                            onPressed: _fetchProductLocation,
                            child: const Text("Find Location"),
                          ),
                          if (productLocation != null) ...[
                            SizedBox(height: 20.h),
                            Container(
                              height: 200.h,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r)),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                    target: productLocation!, zoom: 12),
                                markers: {
                                  Marker(
                                      markerId:
                                          const MarkerId("productLocation"),
                                      position: productLocation!)
                                },
                                onMapCreated: (controller) {
                                  _mapController = controller;
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
