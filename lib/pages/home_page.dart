import 'package:flutter/material.dart';
import '../event_service.dart';  // Import EventService class
import '../widgets/category_tile.dart';  // Import the CategoryTile widget
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String email;

  HomePage({required this.email});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final EventService _eventService = EventService();  // Create an instance of EventService
  Map<String, bool> _eventVisibility = {};  // Tracks visibility of events by category
  Map<String, List<dynamic>> _events = {};  // Stores events by category
  bool _isLoading = false;  // Loading state for when events are being fetched

  // Method to fetch events by category
  Future<void> _fetchEventsByCategory(String category) async {
    setState(() {
      _isLoading = true;  // Start loading
    });

    if (_eventVisibility[category] == true) {
      // If events are already visible, hide them by returning early
      setState(() {
        _eventVisibility[category] = false;
        _isLoading = false;
      });
      return;
    }

    // Use the event service to fetch events by category
    await _eventService.fetchEventsByCategory(
      category,
      (events) {
        // On success: update events and stop loading
        setState(() {
          _events[category] = events;  // Store events by category
          _eventVisibility[category] = true;
          _isLoading = false;
        });
      },
      (error) {
        // On error: show error message and stop loading
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  }

  // Format date to remove the time part
  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.year}-${parsedDate.month}-${parsedDate.day}';
    } catch (e) {
      return date;  // In case of any formatting issues, just return the original date
    }
  }

  // Widget to build event list for a specific category
  Widget _buildEventList(String category) {
    final events = _events[category];

    if (events == null || events.isEmpty) {
      return Center(
        child: Text('No events for this category'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,  // This ensures the list does not overflow with other content.
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        // Extract the relevant fields safely
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
              SizedBox(height: 8),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore Lithuania',
          style: TextStyle(fontFamily: 'Jua'),
        ),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView( // Make the body scrollable to avoid overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Suggestions Title
            Text(
              'Our suggestions:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Jua',
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 10),

            // Categories list
        

                    CategoryTile(
              title: 'Local events',
              imagePath: 'assets/local-events.jpg',
              onTap: () => _fetchEventsByCategory('Local events'),
            ),
            if (_eventVisibility['Local events'] == true)
              _isLoading
                  ? CircularProgressIndicator()  // Show loading indicator while fetching events
                  : _buildEventList('Local events'),

            CategoryTile(
              title: 'Main places to see in Lithuania',
              imagePath: 'assets/lithuania.jpg',
              onTap: () => _fetchEventsByCategory('Main places to see in Lithuania'),
            ),
            if (_eventVisibility['Main places to see in Lithuania'] == true)
              _isLoading
                  ? CircularProgressIndicator()  // Show loading indicator while fetching events
                  : _buildEventList('Main places to see in Lithuania'),

            CategoryTile(
              title: 'Calm and rest...',
              imagePath: 'assets/calm-rest.jpg',
              onTap: () => _fetchEventsByCategory('Calm and rest...'),
            ),
            if (_eventVisibility['Calm and rest...'] == true)
              _isLoading
                  ? CircularProgressIndicator()  // Show loading indicator while fetching events
                  : _buildEventList('Calm and rest...'),

            CategoryTile(
              title: 'Active trips and sports!',
              imagePath: 'assets/active-trips.jpg',
              onTap: () => _fetchEventsByCategory('Active trips and sports!'),
            ),
            if (_eventVisibility['Active trips and sports!'] == true)
              _isLoading
                  ? CircularProgressIndicator()  // Show loading indicator while fetching events
                  : _buildEventList('Active trips and sports!'),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> eventData;

  EventDetailPage({required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details', style: TextStyle(fontFamily: 'Jua')),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event name
            Text(
              eventData['name'],
              style: TextStyle(
                fontFamily: 'Jua',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 10),
            // Event description
            Text(
              'Description:',
              style: TextStyle(
                fontFamily: 'Jua',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 5),
            Text(eventData['description'], style: TextStyle(fontFamily: 'Jua', fontSize: 16)),
            SizedBox(height: 20),
            // Event time
            Text(
              'Time:',
              style: TextStyle(
                fontFamily: 'Jua',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 5),
            Text(eventData['time'], style: TextStyle(fontFamily: 'Jua', fontSize: 16)),
            SizedBox(height: 20),
            // Event city
            Text(
              'City:',
              style: TextStyle(
                fontFamily: 'Jua',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 5),
            Text(eventData['city'] ?? 'Unknown City', style: TextStyle(fontFamily: 'Jua', fontSize: 16)),
            SizedBox(height: 20),
            // Event photos
            Text(
              'Photos:',
              style: TextStyle(
                fontFamily: 'Jua',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 10),
            // Displaying event photos (horizontal scroll)
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: eventData['photos']?.length ?? 0,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Image.network(eventData['photos'][index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
