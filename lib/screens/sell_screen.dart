import 'package:flutter/material.dart';

class SellScreen extends StatefulWidget {
  @override
  _SellScreenState createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  double price = 0;
  String imageUrl = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // TODO: Implement bike listing submission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
              onSaved: (value) => title = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
              onSaved: (value) => description = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onSaved: (value) => price = double.parse(value!),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Image URL'),
              onSaved: (value) => imageUrl = value!,
            ),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('List Bike'),
            ),
          ],
        ),
      ),
    );
  }
}
