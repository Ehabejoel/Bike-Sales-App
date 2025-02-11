import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bike.dart';
import '../services/bike_service.dart';

class SellScreen extends StatefulWidget {
  final bool showAppBar;

  const SellScreen({super.key, this.showAppBar = true});

  @override
  _SellScreenState createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bikeService = BikeService();
  bool _isLoading = false;
  String title = '';
  String description = '';
  double price = 0;
  String imageUrl = '';
  String category = 'Road Bike';

  final List<String> _categories = [
    'Road Bike',
    'Mountain Bike',
    'Electric Bike',
    'Hybrid Bike',
    'BMX',
    'Other'
  ];

  // Add focus nodes
  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _imageFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    print('SellScreen - initState called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('SellScreen - didChangeDependencies called');
  }

  @override
  void didUpdateWidget(SellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('SellScreen - didUpdateWidget called');
    print('Old showAppBar: ${oldWidget.showAppBar}');
    print('New showAppBar: ${widget.showAppBar}');
  }

  @override
  void dispose() {
    print('SellScreen - dispose called');
    // Dispose focus nodes
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _priceFocus.dispose();
    _imageFocus.dispose();
    super.dispose();
  }

  void _submitForm() async {
    print('=== SELL SCREEN FORM SUBMISSION ===');
    print('Starting form submission...');

    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    print('Form validated successfully');
    setState(() => _isLoading = true);
    print('Set loading state to: $_isLoading');

    _formKey.currentState!.save();

    try {
      final user = FirebaseAuth.instance.currentUser;
      print('Current user: ${user?.email}');

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final String sellerName = user.displayName?.isNotEmpty == true
          ? user.displayName!
          : user.email?.split('@')[0] ?? 'Anonymous User';

      final bike = Bike(
        sellerId: user.uid,
        sellerName: sellerName,
        title: title.trim(),
        description: description.trim(),
        price: price,
        imageUrl: imageUrl.trim(),
        category: category,
      );

      await _bikeService.listBike(bike);

      print('Successfully created bike document');
      print('Updating UI state...');

      if (!mounted) {
        print('Widget no longer mounted, cancelling UI update');
        return;
      }

      setState(() {
        print('Resetting form fields...');
        _formKey.currentState?.reset();
        title = '';
        description = '';
        price = 0;
        imageUrl = '';
        category = 'Road Bike';
        _isLoading = false;
      });

      print('Showing success message');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bike listed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      print('Form submission completed successfully');
    } catch (error) {
      print('Error during form submission: $error');
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to list bike: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('SellScreen - build called');
    print('SellScreen - _isLoading: $_isLoading');
    print('SellScreen - showAppBar: ${widget.showAppBar}');

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: Text('List Your Bike'),
                elevation: 0,
              )
            : null,
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          value: category,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((String category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => category = value!),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          focusNode: _titleFocus,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 2022 Trek Domane SL 6',
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            _titleFocus.unfocus();
                            FocusScope.of(context)
                                .requestFocus(_descriptionFocus);
                          },
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a title' : null,
                          onSaved: (value) => title = value!,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          focusNode: _descriptionFocus,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            hintText:
                                'Describe your bike\'s condition and features',
                          ),
                          maxLines: 5,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            _descriptionFocus.unfocus();
                            FocusScope.of(context).requestFocus(_priceFocus);
                          },
                          validator: (value) => value!.isEmpty
                              ? 'Please enter a description'
                              : null,
                          onSaved: (value) => description = value!,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          focusNode: _priceFocus,
                          decoration: InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(),
                            prefixText: '\$',
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            _priceFocus.unfocus();
                            FocusScope.of(context).requestFocus(_imageFocus);
                          },
                          validator: (value) {
                            if (value!.isEmpty) return 'Please enter a price';
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid price';
                            }
                            return null;
                          },
                          onSaved: (value) => price = double.parse(value!),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          focusNode: _imageFocus,
                          decoration: InputDecoration(
                            labelText: 'Image URL',
                            border: OutlineInputBorder(),
                            hintText: 'Enter image URL or upload photo',
                            suffixIcon: Icon(Icons.photo_camera),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Please provide an image' : null,
                          onSaved: (value) => imageUrl = value!,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'List Bike',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
