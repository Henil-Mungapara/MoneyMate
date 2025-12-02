import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneymate/Bottom_Navigation_Page.dart';

class FillUpFormPage extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final String? entryId;

  const FillUpFormPage({super.key, this.existingData, this.entryId});

  @override
  State<FillUpFormPage> createState() => _FillUpFormPageState();
}

class _FillUpFormPageState extends State<FillUpFormPage> {
  String? selectedCategory;
  String selectedType = 'Income';
  String selectedPayment = 'Cash';
  DateTime? selectedDate;

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final amountController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      final data = widget.existingData!;
      titleController.text = data['title'] ?? '';
      descController.text = data['description'] ?? '';
      amountController.text = data['amount']?.toString() ?? '';
      selectedCategory = data['category'];
      selectedType = data['type'] ?? 'Income';
      selectedPayment = data['paymentMode'] ?? 'Cash';
      if (data['date'] != null && data['date'] is String) {
        selectedDate = DateTime.tryParse(data['date']);
      }
      if (data['imageUrl'] != null) {
        _imageFile = File(data['imageUrl']);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitForm() async {
    if (titleController.text.isEmpty ||
        descController.text.isEmpty ||
        amountController.text.isEmpty ||
        selectedCategory == null ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all the required fields."),
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docRef = FirebaseFirestore.instance
          .collection('transactions')
          .doc(user.uid)
          .collection('entry');

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = _imageFile!.path; // Save local image path as string
      }

      final transactionData = {
        "title": titleController.text.trim(),
        "description": descController.text.trim(),
        "category": selectedCategory,
        "type": selectedType,
        "paymentMode": selectedPayment,
        "amount": double.tryParse(amountController.text.trim()) ?? 0.0,
        "date": selectedDate!.toIso8601String(),
        "createdAt": FieldValue.serverTimestamp(),
        if (imageUrl != null) "imageUrl": imageUrl,
      };

      if (widget.entryId != null) {
        await docRef.doc(widget.entryId).update(transactionData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Entry updated successfully")),
        );
      } else {
        await docRef.add(transactionData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction submitted successfully!")),
        );
      }

      // Clear form
      titleController.clear();
      descController.clear();
      amountController.clear();
      setState(() {
        selectedCategory = null;
        selectedType = 'Income';
        selectedPayment = 'Cash';
        selectedDate = null;
        _imageFile = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Add Transection'),
        backgroundColor: const Color(0xFF0B2E33),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BottomNavigationPage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Fill All Details Please!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Item Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Item Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: [
                'Salary', 'Freelancing', 'Investments', 'Rental Income', 'Bonus', 'Other Income',
                'Food', 'Transportation', 'Utilities', 'Entertainment', 'Healthcare', 'Other Expense',
              ]
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (val) => setState(() => selectedCategory = val),
              decoration: const InputDecoration(
                labelText: "Select Category",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Align(alignment: Alignment.centerLeft, child: Text("Type:")),
            Wrap(
              spacing: 10,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(value: 'Income', groupValue: selectedType, onChanged: (val) => setState(() => selectedType = val!)),
                    const Text('Income'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(value: 'Expense', groupValue: selectedType, onChanged: (val) => setState(() => selectedType = val!)),
                    const Text('Expense'),
                  ],
                ),
              ],
            ),
            const Align(alignment: Alignment.centerLeft, child: Text("Payment Mode:")),
            Wrap(
              spacing: 10,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(value: 'Cash', groupValue: selectedPayment, onChanged: (val) => setState(() => selectedPayment = val!)),
                    const Text('Cash'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(value: 'Card', groupValue: selectedPayment, onChanged: (val) => setState(() => selectedPayment = val!)),
                    const Text('Card'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(value: 'Net Banking', groupValue: selectedPayment, onChanged: (val) => setState(() => selectedPayment = val!)),
                    const Text('Net Banking'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  selectedDate == null
                      ? "No Date Selected"
                      : "Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                ),
                const Spacer(),
                ElevatedButton(onPressed: _selectDate, child: const Text("Select Date")),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _imageFile == null
                  ? const Icon(Icons.image, size: 60, color: Colors.grey)
                  : Image.file(_imageFile!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 12),
                child: Text(
                  "Submit",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
