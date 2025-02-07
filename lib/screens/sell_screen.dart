import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SellScreen extends StatefulWidget {
  @override
  _SellScreenState createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _formKey = GlobalKey<FormState>();
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();

      try {
        // TODO: Implement bike listing submission
        await Future.delayed(Duration(seconds: 2)); // Simulate network request
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bike listed successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to list bike. Please try again.')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Your Bike'),
        elevation: 0,
      ),
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
                        onChanged: (value) => setState(() => category = value!),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 2022 Trek Domane SL 6',
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a title' : null,
                        onSaved: (value) => title = value!,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          hintText:
                              'Describe your bike\'s condition and features',
                        ),
                        maxLines: 5,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter a description'
                            : null,
                        onSaved: (value) => description = value!,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
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
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter a price';
                          if (double.tryParse(value) == null)
                            return 'Please enter a valid price';
                          return null;
                        },
                        onSaved: (value) => price = double.parse(value!),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
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
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'List Bike',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
