const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Event = require('../Models/event_model'); // Event model

// Set up multer storage configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = './uploads/events'; // Directory to store event images
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true }); // Create directory if it doesn't exist
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); // Ensure unique file names
  },
});

// Multer file filter for image files
const fileFilter = (req, file, cb) => {
  const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg']; // Accept only image files
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true); // File type is valid
  } else {
    cb(new Error('Invalid file type. Only JPEG, PNG, and JPG are allowed.'), false);
  }
};

// Multer upload configuration (max 5MB for each image)
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // Max file size of 5MB
  },
}).array('image', 5); // Allow multiple files, change 'photos' to match the input name in the request body

// Create a new event with photo handling
exports.createEvent = (req, res) => {
    console.log('Create event endpoint called');
    upload(req, res, async (err) => {
      if (err) {
        return res.status(400).json({
          success: false,
          message: err.message,
        });
      }
  
      try {
        const { name, description, date, time, place, category,address } = req.body;
        const image = req.files ? req.files.map((file) => file.path) : []; // Use an empty array if no files
  
        // Create a new event with the provided details and photos
        const newEvent = new Event({
          name,
          description,
          date,
          time,
          image, // This will be an empty array if no files are uploaded
          place,
          category,
          address
        });
  
        // Save the event to the database
        await newEvent.save();
  
        console.log('Event created successfully');
        // Check if there are photos to process
        if (image.length > 0) {
          const destinationDir = './uploads/extracted_photos';
          if (!fs.existsSync(destinationDir)) {
            fs.mkdirSync(destinationDir, { recursive: true });
          }
  
          const copiedPhotos = [];
          for (let i = 0; i < image.length; i++) {
            const photoPath = image[i];
            const fileName = path.basename(photoPath);
            const destinationPath = path.join(destinationDir, fileName);
  
            // Copy the photo to the new location
            fs.copyFileSync(photoPath, destinationPath);
  
            // Save the new file path into the array
            copiedPhotos.push(destinationPath);
          }
  
          // Update the event document with the new file paths
          newEvent.image = copiedPhotos;
          await newEvent.save();
        }
  
        return res.status(201).json({
          success: true,
          message: 'Event created successfully!',
          data: {
            event: newEvent,
          },
        });
      } catch (error) {
        console.error('Error creating event:', error);
        return res.status(500).json({
          success: false,
          message: 'Error creating event.',
          error: error.message,
        });
      }
    });
  };
  

// Edit an existing event
exports.editEvent = (req, res) => {
  upload(req, res, async (err) => {
    if (err) {
      return res.status(400).json({
        success: false,
        message: err.message,
      });
    }

    try {
      const { id } = req.params; // Get event ID from URL params
      const updates = req.body;  // Get updated fields from the request body
      const photos = req.files ? req.files.map((file) => file.path) : []; // Get new photos if any

      // Find the event by ID and update it
      const updatedEvent = await Event.findByIdAndUpdate(id, {
        ...updates,
        photos: photos.length > 0 ? photos : undefined, // Only update photos if there are any
      }, {
        new: true,  // Return the updated event
        runValidators: true,  // Ensure the update respects the validation rules
      });

      if (!updatedEvent) {
        return res.status(404).json({
          success: false,
          message: 'Event not found.',
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Event updated successfully!',
        data: {
          event: updatedEvent,
        },
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Error updating event.',
        error: error.message,
      });
    }
  });
};

// Delete an event
exports.deleteEvent = async (req, res) => {
  try {
    const { id } = req.params;  // Get event ID from URL params

    // Find the event by ID and remove it
    const deletedEvent = await Event.findByIdAndDelete(id);

    if (!deletedEvent) {
      return res.status(404).json({
        success: false,
        message: 'Event not found.',
      });
    }

    // Optionally delete event images from the file system
    if (deletedEvent.photos.length > 0) {
      deletedEvent.photos.forEach((photoPath) => {
        fs.unlinkSync(photoPath); // Delete the file from disk
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Event deleted successfully!',
      event: deletedEvent,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Error deleting event.',
      error: error.message,
    });
  }
};

// Fetch events for today
exports.getEventsForToday = async (req, res) => {
  try {
    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0)); // start of today
    const endOfDay = new Date(today.setHours(23, 59, 59, 999)); // end of today

    const events = await Event.find({
      date: { $gte: startOfDay, $lte: endOfDay },
    });

    if (events.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No events found for today.',
      });
    }

    res.status(200).json({
      success: true,
      events: events,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Error fetching events.',
      error: error.message,
    });
  }
};

exports.getEvent =  async (req, res) => {
    try {
      const eventId = req.params.id;  // Get event ID from the request parameters
      const event = await Event.findById(eventId);  // Find the event by ID
  console.log("Event founded");
      if (!event) {
        return res.status(404).json({ message: 'Event not found' });
        console.error('Error founding event:', err);
      }
      
      res.json(event);  // Return the event object
    } catch (error) {
      res.status(500).json({ message: 'Server error' });
    }
  };

// Fetch events by a specific date
exports.getEventsByDate = async (req, res) => {
    try {
      const { date } = req.query; // Get date from request body
  
      if (!date) {
        return res.status(400).json({
          success: false,
          message: 'Date is required in the request body.',
        });
      }
  
      // Ensure the date format is correct
      const queryDate = new Date(date);
      if (isNaN(queryDate)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid date format. Use YYYY-MM-DD.',
        });
      }
  
      const startOfDay = new Date(queryDate.toISOString().split('T')[0] + 'T00:00:00Z');
      const endOfDay = new Date(queryDate.toISOString().split('T')[0] + 'T23:59:59Z');
      
  
      // Query events within the date range
      const events = await Event.find({
        date: { $gte: startOfDay, $lte: endOfDay },
      });
  
      if (events.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'No events found for the specified date.',
        });
      }
  
      res.status(200).json({
        success: true,
        events: events,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Error fetching events.',
        error: error.message,
      });
    }
  };
  
  exports.getEventsByPlace = async (req, res) => {
    try {
      const { place } = req.query; // Get place from the request body
  
      if (!place) {
        return res.status(400).json({
          success: false,
          message: 'Place is required',
        });
      }
  
      // Query the database for events at the specified place
      const events = await Event.find({ place: place });
  
      if (events.length === 0) {
        return res.status(404).json({
          success: false,
          message: `No events found for place: ${place}`,
        });
      }
  
      res.status(200).json({
        success: true,
        events: events,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Error fetching events by place.',
        error: error.message,
      });
    }
  };

  exports.getEventsByDateAndPlace = async (req, res) => {
    try {
      const { date, place } = req.query; // Get date and place from the request query parameters
      
      if (!date || !place) {
        return res.status(400).json({
          success: false,
          message: 'Both date and place are required',
        });
      }
  
      // Query the database for events matching the specified date and place
      const events = await Event.find({
        date: date, // Assuming the date is stored in the "date" field
        place: place, // Assuming the place is stored in the "place" field
      });
  
      if (events.length === 0) {
        return res.status(404).json({
          success: false,
          message: `No events found for place: ${place} on date: ${date}`,
        });
      }
  
      res.status(200).json({
        success: true,
        events: events,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Error fetching events by date and place.',
        error: error.message,
      });
    }
  };
  
  
  // Fetch events by category
  exports.getEventsByCategory = async (req, res) => {
    try {
        const { category } = req.query; // Get category from the request query parameters
        
        if (!category) {
            return res.status(400).json({
                success: false,
                message: 'Category is required.',
            });
        }

        const now = Date.now(); // Get the current timestamp

        // Query the database for events in the specified category
        const events = await Event.find({ category: category });

        // Filter the events to keep only future events
        const futureEvents = events.filter(event => {
            const eventDate = new Date(event.date); // Create a Date object from the event's date field
            const [hours, minutes] = event.time.split(":"); // Split the time into hours and minutes
            eventDate.setHours(hours); // Set the hours on the event date
            eventDate.setMinutes(minutes); // Set the minutes on the event date
            eventDate.setSeconds(0); // Set the seconds to 0
            eventDate.setMilliseconds(0); // Set milliseconds to 0

            return eventDate > now; // Check if the event is in the future
        });

        if (futureEvents.length === 0) {
            return res.status(404).json({
                success: false,
                message: `No upcoming events found for category: ${category}`,
            });
        }

        res.status(200).json({
            success: true,
            events: futureEvents,
        });
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: 'Error fetching events by category.',
            error: error.message,
        });
    }
};



  
  