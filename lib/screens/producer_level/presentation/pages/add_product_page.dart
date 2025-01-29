import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:origin_vault/blockchain_service/blockchain_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_pallete.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final BlockchainService blockchainService = BlockchainService();
  final _formKey = GlobalKey<FormState>();
  final supabase =
      SupabaseClient(dotenv.env['SUPABASE_URL']!, dotenv.env['SUPABASE_KEY']!);

  final _productNameController = TextEditingController();
  final _productTypeController = TextEditingController();
  final _productQuantityController = TextEditingController();
  final _productOriginController = TextEditingController();

  XFile? _pickedImage;
  String _productHexCode = '';
  String _farmerHexCode = '';

  @override
  void initState() {
    super.initState();
    _productHexCode = _generate32HexCode();
    _farmerHexCode = _generate32HexCode();
    blockchainService.initialize();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productTypeController.dispose();
    _productQuantityController.dispose();
    _productOriginController.dispose();
    super.dispose();
  }

  String _generate32HexCode() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl;
        if (_pickedImage != null) {
          imageUrl = await _uploadImage();
        }

        await supabase.from('product_data_table').insert({
          'product_name': _productNameController.text,
          'product_type': _productTypeController.text,
          'product_quantity': _productQuantityController.text,
          'origin_location': _productOriginController.text,
          'product_id': _productHexCode,
          'farmer_id': _farmerHexCode,
          'image_url': imageUrl,
        });

        // Add to product to blockchain
        final String transactionHash = await blockchainService.createProduct(
          _productNameController.text,
          _productOriginController.text,
          '${_productTypeController.text}, Quantity: ${_productQuantityController.text}',
          imageUrl ?? '',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Product added successfully. Transaction Hash: $transactionHash')),
          );
          _resetForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding product: $e')),
          );
        }
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _productNameController.clear();
      _productTypeController.clear();
      _productQuantityController.clear();
      _productOriginController.clear();
      _pickedImage = null;
      _productHexCode = _generate32HexCode();
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedImage == null) return null;

    final bytes = await _pickedImage!.readAsBytes();
    final tempDir = await getTemporaryDirectory();
    final tempFile =
        File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(bytes);

    try {
      final String path = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('certificate').upload(path, tempFile);
      return supabase.storage.from('certificate').getPublicUrl(path);
    } finally {
      await tempFile.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: AppPallete.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.cyan),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppPallete.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_productNameController, 'Product Name'),
                const SizedBox(height: 16),
                _buildTextField(_productTypeController, 'Product Type'),
                const SizedBox(height: 16),
                _buildTextField(_productQuantityController, 'Product Quantity',
                    isNumeric: true),
                const SizedBox(height: 16),
                _buildTextField(_productOriginController, 'Product Origin'),
                const SizedBox(height: 16),
                _buildHexCodeField(),
                const SizedBox(height: 20),
                _buildImagePickerButton(),
                const SizedBox(height: 20),
                _buildAddButton(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (isNumeric && int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildHexCodeField() {
    return TextFormField(
      initialValue: _productHexCode,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Product Hex Code',
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildImagePickerButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.upload_file),
      label: Text(_pickedImage == null ? 'Pick Image' : 'Change Image'),
      onPressed: _pickImage,
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _addProduct,
      child: const Text('Add Product'),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      notchMargin: 8.0,
      shape: const CircularNotchedRectangle(),
      color: AppPallete.secondarybackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Iconsax.box, "Products", () {}),
          _buildNavItem(Iconsax.message_notif, "Message", () {}),
          const SizedBox(width: 48), // Space for FAB
          _buildNavItem(Iconsax.d_cube_scan, "Supply Chain", () {}),
          _buildNavItem(Iconsax.setting_2, "Settings", () {}),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, color: AppPallete.iconColor),
            Text(label, style: const TextStyle(color: AppPallete.iconColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return SizedBox(
      height: 80.h,
      width: 80.w,
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppPallete.secondarybackgroundColor,
        elevation: 0,
        shape: const CircleBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.house_2, size: 24.sp, color: AppPallete.iconColor),
            SizedBox(height: 5.h),
            Text('Home',
                style: TextStyle(color: AppPallete.iconColor, fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
}
