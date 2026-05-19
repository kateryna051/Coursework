// event_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class EventService {
  final String _baseUrl = 'http://127.0.0.1:3000/api'; // Replace with your backend URL

  Future<List<dynamic>> fetchAllEvents() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/events'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception('Failed to fetch events');
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

 

  // Method to fetch event data by event ID
  Future<Map<String, dynamic>> fetchEventDataById(String eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/events/get/$eventId'),
      );

      print('Request sent to: $_baseUrl/events/get/$eventId');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);  // Parse the JSON response and return it
      } else {
        print('Error: ${response.body}');
        throw Exception('Failed to load event');
      }
    } catch (e) {
      print('Error during fetching event data: $e');
      throw Exception('Failed to fetch event data');
    }
  }

  

Future<void> fetchEventsByCategory(String category, Function(List<dynamic>) onSuccess, Function(String) onError) async {
    final url = Uri.parse('$_baseUrl/events/category?category=$category'); // The endpoint expects category as a query parameter
final response = await http.get(url);
    try {

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        onSuccess(data['events']); // Pass the events data to the success callback
      } else {
        onError('Failed to fetch events for category: $category');
      }
    } catch (e) {
      onError('Error fetching events: $e');
    }
  }
}