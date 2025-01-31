import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:origin_vault/screens/admin_level/notification_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:mime/mime.dart';

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
  final mapController = MapController();
  final uuid = const Uuid();
  File? selectedFile;
  bool isLoading = false;
  int productQuantity = 1;
  String? selectedProductType;
  String? selectedFilePath;
  LatLng? productLocation;
  List<String> productTypes = ['Organic', 'Non-Organic', 'GMO'];
  String? locationString;
  bool isMapReady = false;
  bool _isMapInitialized = false;
  LatLng? _pendingLocation;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
  }
  void _onMapReady() {
    _isMapInitialized = true;
    if (_pendingLocation != null) {
      // Move to pending location if it exists
      mapController.move(_pendingLocation!, 13.0);
      _pendingLocation = null;
    }
  }

  @override
  void dispose() {
    productNameController.dispose();
    productOriginController.dispose();
    productIdController.dispose();
    mapController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );
      
      if (result != null) {
        setState(() {
          selectedFile = File(result.files.single.path!);
          selectedFilePath = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to pick file: ${e.toString()}'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _clearForm() {
    setState(() {
      productNameController.clear();
      productOriginController.clear();
      selectedProductType = null;
      productQuantity = 1;
      selectedFile = null;
      selectedFilePath = null;
    });
  }

  Future<void> _addProduct() async {
    if (productNameController.text.isEmpty ||
        productOriginController.text.isEmpty ||
        selectedProductType == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please fill all required fields'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? certificateUrl;
      final productId = uuid.v4(); // Generate unique product ID
      
      // Upload file if selected
      if (selectedFile != null) {
        final fileExtension = selectedFile!.path.split('.').last;
        final fileName = '$productId.$fileExtension';
        
        // Upload to Supabase Storage
  await supabase.storage
      .from('certificate')
      .upload(
        fileName,
        selectedFile!,
        fileOptions: FileOptions(
          contentType: lookupMimeType(selectedFile!.path),
        ),
      );

        // Get public URL
        certificateUrl = supabase.storage
            .from('certificate')
            .getPublicUrl(fileName);
      }

      // Insert into product_data_table
      await supabase.from('product_data_table').insert({
        'product_id': productId,
        'product_name': productNameController.text,
        'product_type': selectedProductType,
        'product_quantity': productQuantity.toString(),
        'origin_location': productOriginController.text,
        'image_url': certificateUrl,
        'created_at': DateTime.now().toIso8601String(),
        // Add farmer_id if you have it
        // 'farmer_id': currentFarmerId,
      });

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear the form
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to add product: ${e.toString()}'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
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

  Future<LatLng?> getCityCoordinates(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$cityName'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          double lat = double.parse(data[0]['lat']);
          double lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting coordinates: $e');
      }
      return null;
    }
  }

  // Parse string to LatLng if it's in correct format
  LatLng? parseLatLng(String location) {
    try {
      // Check if string is in format "lat,lng"
      final parts = location.split(',');
      if (parts.length == 2) {
        double? lat = double.tryParse(parts[0].trim());
        double? lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchProductLocation() async {
    if (productIdController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please enter a Product ID first'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      final response = await supabase
          .from('product_data_table')
          .select('origin_location')
          .eq('product_id', productIdController.text)
          .single();

      if (response.isEmpty) {
        throw Exception('Product not found');
      }

      String locationData = response['origin_location'] as String;
      
      // First try to parse as LatLng
      LatLng? coordinates = parseLatLng(locationData);
      
      // If not LatLng, try to get coordinates for city name
      coordinates ??= await getCityCoordinates(locationData);

      if (coordinates != null) {
        setState(() {
          locationString = locationData;
          productLocation = coordinates;
          
          // If map is ready, move to location immediately
          if (_isMapInitialized) {
            mapController.move(coordinates!, 13.0);
          } else {
            // Store location to move when map is ready
            _pendingLocation = coordinates;
          }
        });
      } else {
        throw Exception('Could not determine location coordinates');
      }

    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to fetch location: ${e.toString()}'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
      }
    }
  }

  Widget _buildMap() {
    if (productLocation == null) {
      return Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            'Enter Product ID and click Find Location',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: productLocation!,
          initialZoom: 13.0,
          onMapReady: _onMapReady,  // Add this callback
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            maxZoom: 19,
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: productLocation!,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // Rest of your existing build method remains the same until the map section
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: Drawer(
        child: Container(
          color: Colors.grey[900],
          child: const Center(
            child: Text("Sidebar Menu", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Navigation Bar
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
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Main Content
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
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Icon(Icons.upload_file, color: Colors.cyan),
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
        onPressed: isLoading ? null : _addProduct,
        child: isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text("Add"),
      ),
                              ElevatedButton(
                                  onPressed: isLoading ? null : _clearForm,
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
                          Text(
                            'Track Product Location',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          ElevatedButton(
                            onPressed: _fetchProductLocation,
                            child: const Text("Find Location"),
                          ),
                          SizedBox(height: 20.h),
                          _buildMap(),
                  ],
                ),
              ),
          ],),
        
        ),
      ),
    ],
    ),
    ),
    );
  }
}
