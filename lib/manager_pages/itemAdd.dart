import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import '../databaseHelper.dart';
import '../usersAndItemsModel.dart';
import './itemRedirect.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  late String itemName;
  late String itemType;
  late int itemPrice;

  String _btnColor = "004225";

  String? _itemNameError;
  String? _itemTypeError;
  String? _itemPriceError;
  String? _imagePath;

  bool isImageSubmitted = false;

   void _onImageSubmitted() async {
     while (_imagePath == null) {
      await Future.delayed(Duration(milliseconds: 100)); // Adjust the delay as needed
    }

    setState(() {
        isImageSubmitted = true;
    });
  }

  final ItemDatabaseHelper _databaseHelper = ItemDatabaseHelper();

  void _sumbitItem() async {
    // ITEMNAME VALIDATION
    if (itemName.isEmpty) {
      setState(() {
        _itemNameError = "Nama Obat Tidak Boleh Kosong";
      });
    } else if (itemName.length <= 3) {
      setState(() {
        _itemNameError = "Nama Obat Tidak Boleh Kurang Dari 3 Karakter";
      });
    } else {
      setState(() {
        _itemNameError = null;
      });
    }

    // ITEMTYPE VALIDATION
    if (itemType.isEmpty) {
      setState(() {
        _itemTypeError = "Tipe Obat Tidak Boleh Kosong";
      });
    } else if (itemType.length <= 3) {
      setState(() {
        _itemTypeError = "Tipe Obat Tidak Boleh Kurang Dari 3 Karakter";
      });
    } else {
      setState(() {
        _itemTypeError = null;
      });
    }

    // ITEMTYPE VALIDATION
    if (itemPrice == null) {
      setState(() {
        _itemPriceError = "Harga Obat Tidak Boleh Kosong";
      });
    } else if (itemPrice <= 0) {
      setState(() {
        _itemPriceError = "Harga Obat Tidak Boleh Kurang Dari 0";
      });
    } else if (itemPrice.isNaN) {
      setState(() {
        _itemPriceError = "Harga Obat Harus Berupa Angka";
      });
    } else {
      setState(() {
        _itemPriceError = null;
      });
    }

    // IMAGE ITEM VALIDATION
    if (_imagePath == null) {
      // Show an error message for missing image
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih gambar Obat terlebih dahulu.'),
        ),
      );
      return; // Stop execution if image is missing
    }

    // ADD TO DATABASE
    final newItem = Item(
        name: itemName,
        type: itemType,
        price: itemPrice,
        imagePath: _imagePath);
    final result = await _databaseHelper.addItem(newItem);

    // REDIRECT TO SUCCESS/FAILURE PAGE
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ItemRedirectPage(
          status: result > 0 ? "success" : "failure",
          title:
              result > 0 ? "Penambahan Obat Sukses" : "Penambahan Obat Gagal",
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          preferredCameraDevice: CameraDevice.rear);

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambahkan Obat'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Title(
              child: Text(
                "Silahkan Masukan Informasi Mengenai Obat Yang Akan Di Tambahkan.",
                textScaleFactor: 1.2,
              ),
              color: Colors.black,
            ),
            SizedBox(height: 16.0),
            TextField(
              onChanged: (value) => itemName = value,
              decoration: InputDecoration(
                labelText: 'Nama Obat',
                errorText: _itemNameError,
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              onChanged: (value) => itemType = value,
              decoration: InputDecoration(
                labelText: 'Tipe Obat',
                errorText: _itemTypeError,
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              onChanged: (value) => itemPrice = int.tryParse(value) ?? 0,
              decoration: InputDecoration(
                labelText: 'Harga Obat per Pack',
                errorText: _itemPriceError,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8.0),
            ElevatedButton.icon(
              onPressed: () {
                _pickImage();
                _onImageSubmitted();
              },
              style: ButtonStyle(
                // backgroundColor: MaterialStateProperty.all<Color>(HexColor(_btnColor)),
                minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
              ),
              icon: Icon(Icons.photo_library),
              label: Text(
                isImageSubmitted ? 'Ganti Gambar Obat' : 'Pilih Gambar Obat',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _sumbitItem,
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(HexColor(_btnColor)),
                minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
              ),
              icon: Icon(Icons.add), // Add the plus icon
              label:
                  Text('Tambahkan Obat', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
