import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'account_settings_page.dart';

class ProfilePage extends StatefulWidget {
  final String email;

  ProfilePage({required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  Uint8List? _webImageBytes;
  String? avatarUrl;
  bool isLoading = true; // Declare the loading state
  final TextEditingController messageController = TextEditingController();

  // Fetch the avatar URL from the server if it exists
  Future<void> _fetchUserData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:3000/api/user/${widget.email}'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        avatarUrl = responseData['user']['avatar'] != null
            ? 'http://127.0.0.1:3000${responseData['user']['avatar']}' // Prepend base URL to avatar path
            : null;
        isLoading = false; // Set loading to false after data is fetched
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error if user is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch the avatar when the page is initialized
  }

  // Upload image for web
  Future<void> _uploadImageWeb(Uint8List imageBytes, String filename) async {
    final uri = Uri.parse('http://127.0.0.1:3000/api/ava');
    final request = http.MultipartRequest('POST', uri);

    // Add the email and image to the request
    request.fields['email'] = widget.email;

    final multipartFile = http.MultipartFile.fromBytes(
      'avatar',
      imageBytes,
      filename: filename,
    );

    request.files.add(multipartFile);

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Avatar uploaded successfully (Web)')));
        _fetchUserData(); // Refresh the avatar after upload
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload avatar (Web)')));
      }
    } catch (e) {
      print('Error uploading avatar (Web): $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading avatar (Web)')));
    }
  }

  // Upload image for mobile
  Future<void> _uploadImageMobile(File imageFile) async {
    final uri = Uri.parse('http://127.0.0.1:3000/api/ava');
    final request = http.MultipartRequest('POST', uri);

    // Add the email and image to the request
    request.fields['email'] = widget.email;

    request.files.add(await http.MultipartFile.fromPath(
      'avatar',
      imageFile.path,
    ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Avatar uploaded successfully (Mobile)')));
        _fetchUserData(); // Refresh the avatar after upload
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload avatar (Mobile)')));
      }
    } catch (e) {
      print('Error uploading avatar (Mobile): $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading avatar (Mobile)')));
    }
  }

  // Pick image for avatar
  Future<void> _pickImage() async {
    if (kIsWeb) {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        await _uploadImageWeb(bytes, pickedFile.name);

        setState(() {
          _profileImage = File(pickedFile.path);
          _webImageBytes = bytes;
        });
      }
    } else {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        await _uploadImageMobile(File(pickedFile.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontFamily: 'Jua')),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      isLoading
                          ? CircularProgressIndicator() // Show loading while fetching data
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl!) // Use avatar from the database
                                  : null,
                              child: avatarUrl == null
                                  ? Icon(Icons.person, size: 50, color: Colors.grey)
                                  : null,
                            ),
                      IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.orange),
                        onPressed: _pickImage, // Trigger image picking
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.email,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            _buildOption(
              context,
              title: "Account Settings",
              icon: Icons.settings,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountSettingsPage(email: widget.email),
                  ),
                );
              },
            ),
            _buildOption(
              context,
              title: "Invite Friends",
              icon: Icons.share,
              onTap: () {
                _showInviteFriendsDialog(context);
              },
            ),
            _buildOption(
              context,
              title: "Help",
              icon: Icons.help,
              onTap: () {
                _showHelpDialog(context);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Explore Lithuania App",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }

  void _showInviteFriendsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Invite Friends"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Share the following link with your friends to invite them:"),
              SizedBox(height: 10),
              SelectableText(
                "https://explore-lithuania.com/invite",
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Help"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Phone: +37060070342"),
              SizedBox(height: 10),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Message",
                  hintText: "Type your message here",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _sendHelpMessage();  // Call the method to send the help message
              },
              child: Text("Send"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendHelpMessage() async {
    final message = messageController.text;

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message cannot be empty")));
      return;
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:3000/api/sendEmail'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': widget.email,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message sent successfully')));
      Navigator.pop(context); // Close dialog after sending
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message')));
    }
  }
}
