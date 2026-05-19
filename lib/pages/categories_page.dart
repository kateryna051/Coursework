import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../design.dart';

class CategoriesPage extends StatefulWidget {
  final String email;

  CategoriesPage({required this.email});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
   final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedCategory;
  String? _selectedPlace1;
  String? _selectedPlace;
  dynamic _selectedImage;
  void _showAlert(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Alert'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog when 'OK' is pressed
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


  List<dynamic> _events = []; // List to hold today's events

  @override
  void initState() {
    super.initState();
    _fetchEventsForToday(); // Fetch today's events when the page is initialized
  }

  Future<void> _fetchEventsForToday() async {
    final url = Uri.parse('http://127.0.0.1:3000/api/events/today');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _events = data['events']; // Update the list with fetched events
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No events for today :(')),
      );
    }
  }

  Future<void> _fetchEventsByDateAndPlace(String date, String place) async {
  final url = Uri.parse('http://127.0.0.1:3000/api/events/placedate');
  final response = await http.get(url.replace(queryParameters: {'date': date, 'place': place}));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    setState(() {
      _events = data['events'];
    });
  if (response.statusCode == 404){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No events in $place  at $date')),
    );
  }
    if (_events.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No events available for $date at $place')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No available events for $date at $place')),
    );
  }
}


    void _showEventForm() {



    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    hintText: 'Enter event name',
                  ),
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: Text(_selectedCategory ?? 'Select Category'),
                  value: _selectedCategory,
                  items: [
                    'Main places to see in Lithuania',
                    'Calm and rest...',
                    'Active trips and sports!',
                    'Local events',

                  ].map((String category) {
                    return DropdownMenuItem<String>(
                        value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter event description',
                  ),
                ),
                TextField(
                  controller: _eventDateController,
                  readOnly: true, // Prevent manual text entry
                  decoration: InputDecoration(
                    labelText: 'Date',
                    hintText: 'YYYY-MM-DD',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );

                    if (selectedDate != null) {
                      setState(() {
                        _eventDateController.text =
                            selectedDate.toIso8601String().split('T').first;
                      });
                    }
                  },
                ),
                TextField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    hintText: 'HH:mm',
                  ),
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Select Place'),
                  value: _selectedPlace1,
                  items: [
                    'Klaipėda',
                    'Vilnius',
                    'Alytus',
                    'Kaunas',
                    'Šiauliai',
                    'Whole Lithuania'
                  ].map((String place) {
                    return DropdownMenuItem<String>(
                        value: place, child: Text(place));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlace1 = value;
                    });
                  },
                ),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter event address',
                  ),
                ),
                SizedBox(height: 20),
             ElevatedButton(
  onPressed: _pickImage,
  child: Text('Pick Image'),
),

SizedBox(height: 20),


                ElevatedButton(
                  onPressed: () {
                    _createEvent(); // Updated to use the independent place
                  },
                  child: Text('Create Event'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


Future<void> _pickImage() async {
  if (kIsWeb) {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = false;
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files!.isEmpty) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(files[0]);
      reader.onLoadEnd.listen((e) {
        final content = reader.result as Uint8List;
        setState(() {
          _selectedImage = html.File([content], files[0].name);
        });
        print('Picked image: ${_selectedImage?.name}'); 
        _showAlert("You picked image: ${_selectedImage?.name}");
      });
    });
  } else {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      print('Picked image: ${_selectedImage?.path.split('/').last}');
      print("Is web: ${kIsWeb}");
       _showAlert("You picked image: ${_selectedImage?.path.split('/').last}");

    }
  }
}

Future<void> _createEvent() async {
  if (_nameController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _eventDateController.text.isEmpty ||
      _timeController.text.isEmpty ||
      _selectedCategory == null ||
      _selectedPlace1 == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill in all fields')),
    );
    return;
  }

  final uri = Uri.parse('http://127.0.0.1:3000/api/events/create');
  var request = http.MultipartRequest('POST', uri);
  request.fields['name'] = _nameController.text;
  request.fields['description'] = _descriptionController.text;
  request.fields['date'] = _eventDateController.text;
  request.fields['time'] = _timeController.text;
  request.fields['place'] = _selectedPlace1!;
  request.fields['category'] = _selectedCategory!;
  request.fields['address'] = _addressController.text;

  print("Event Name: ${_nameController.text}");
  print("Description: ${_descriptionController.text}");
  print("Date: ${_eventDateController.text}");
  print("Time: ${_timeController.text}");
  print("Place: ${_selectedPlace1}");
  print("Category: ${_selectedCategory}");
  print("Address: ${_addressController}");

  // Process image
  if (_selectedImage != null) {
    try {
      if (kIsWeb && _selectedImage is html.File) {
        // Web: Handle html.File
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_selectedImage);
        await reader.onLoadEnd.first;
        final bytes = reader.result as Uint8List;

        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: _selectedImage.name,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else if (_selectedImage is File) {
        // Non-web: Handle dart:io File
        final bytes = await (_selectedImage as File).readAsBytes();

        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: _selectedImage.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        throw Exception('Unsupported image type');
      }
    } catch (e) {
      print('Error processing the image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process the image: $e')),
      );
      return;
    }
  }

  // Send request
  await _sendRequest(request);
}


  Future<void> _sendRequest(http.MultipartRequest request) async {
    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event created successfully')),
        );
        Navigator.of(context).pop();
           // Clear all fields and reset state
      _nameController.clear();
      _descriptionController.clear();
      _eventDateController.clear();
      _timeController.clear();
      _addressController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedPlace1 = null;
        _selectedImage = null;
      });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: ${responseBody.body}')),
        );
      }
    } catch (e) {
      print('Error during request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore Lithuania!',
          style: TextStyle(fontFamily: 'Jua'),
        ),
        backgroundColor: Design.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildDatePlaceSelectors(),
            SizedBox(height: 20),
            _buildWidgetTitle('Today\'s Events:'),
            _buildEventList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEventForm,
        child: Icon(Icons.add),
        backgroundColor: Design.primaryColor,
      ),
    );
  }

  Widget _buildWidgetTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Jua',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Design.primaryColor,
      ),
    );
  }

  Widget _buildEventList() {
  if (_events.isEmpty) {
    return Center(
      child: Text('No events for today'),
    );
  }

  return ListView.builder(
    shrinkWrap: true,  // This ensures the list does not overflow with other content.
    itemCount: _events.length,
    itemBuilder: (context, index) {
      final event = _events[index];
      
      // Extract the relevant fields, excluding 'id' and 'createdAt'
      final String name = event['name'] ?? 'No name';
      final String description = event['description'] ?? 'No description';
      final String date = event['date'] ?? 'No date';
      final String time = event['time'] ?? 'No time';
      final String place = event['place'] ?? 'No place';
      final String address = event['address'] ?? 'No address';
      final String category = event['category'] ?? 'No category';
      String? imagePath;
      if (event['image'] != null && event['image'].isNotEmpty) {
        imagePath = 'http://127.0.0.1:3000/${event['image'][0]}';  // Prefix with the base URL
      }

      return Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display event name
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 8),
            
            // Display event description
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Category: $category",
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade700,
              ),
            ),
            SizedBox(height: 8),
            // Display event date
            Text(
              "Date: ${_formatDate(date)}",  // Format the date to remove time part
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
              ),
            ),
            SizedBox(height: 8),
            
            // Display event time
            Text(
              "Time: $time", 
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
              ),
            ),
            SizedBox(height: 8),
            
            // Display event place
            Text(
              "Place: $place", 
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
              ),
            ),
            Text(
              "Address: $address", 
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
              ),
            ),
            SizedBox(height: 8),
            
            // Display event image if exists
            imagePath != null
                ? Image.network(imagePath)  // Load image from URL
                : Container(),  // Empty container if no image is available
          ],
        ),
      );
    },
  );
}

// Helper method to format the date if needed
String _formatDate(String date) {
  try {
    DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
  } catch (e) {
    return date;  // Return original date if parsing fails
  }
}

   Widget _buildDatePlaceSelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date and Place:'),
        SizedBox(height: 10),
        Text('Date:'),
        SizedBox(height: 5),
        TextField(
          controller: _dateController,
          decoration: InputDecoration(
            labelText: 'Select Date',
            hintText: 'YYYY-MM-DD',
          ),
          readOnly: true,
          onTap: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (selectedDate != null) {
              setState(() {
                _dateController.text = selectedDate.toIso8601String().split('T').first;
              });
            }
          },
        ),
        SizedBox(height: 10),
        Text('Place:'),
        DropdownButton<String>(
          isExpanded: true,
          value: _selectedPlace,
          hint: Text('Select a place'),
          items: ['Klaipėda', 'Vilnius', 'Alytus', 'Kaunas', 'Šiauliai', 'Whole Lithuania']
              .map((place) => DropdownMenuItem<String>(value: place, child: Text(place)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedPlace = value;
            });
          },
        ),
        SizedBox(height: 10),
        ElevatedButton(
  onPressed: () {
    if (_dateController.text.isNotEmpty && _selectedPlace != null) {
      // Both date and place are selected
      _fetchEventsByDateAndPlace(_dateController.text, _selectedPlace!);
    } else if (_dateController.text.isNotEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select place')),
      );
    } else if (_selectedPlace1 != null) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select date')),
      );
    } else {
      // Neither date nor place is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select either date, place, or both')),
      );
    }
  },
  child: Text('Search Events'),
),

      ],
    );
  }

}
