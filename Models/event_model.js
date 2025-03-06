const mongoose = require('mongoose');

// Event Schema
const EventSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please enter the event name.'],
    unique: true,
    minlength: 3,
  },
  description: {
    type: String,
    required: [true, 'Please enter the event description.'],
    minlength: 10,
  },
  date: {
    type: Date,
    required: [true, 'Please enter the event date.'],
    validate: {
      validator: function(v) {
        // Regex to validate the date format "YYYY-MM-DD"
        return /^\d{4}-\d{2}-\d{2}$/.test(v.toISOString().split('T')[0]);
      },
      message: props => `${props.value} is not a valid date format. The correct format is YYYY-MM-DD.`,
    },
  },
  time: {
    type: String,
    required: [true, 'Please enter the event time.'],
    validate: {
      validator: function(v) {
        // Regex to validate the time format "HH:mm"
        return /^(2[0-3]|[01][0-9]):([0-5][0-9])$/.test(v);
      },
      message: props => `${props.value} is not a valid time format. The correct format is HH:mm.`,
    },
  },
  image: [{
    type: String,  // Store file paths (could be URLs as well)
    required: false,  // Optional
  }],
  place: {
    type: String,
    required: [true, 'Please specify the place of the event.'],
    enum: {
      values: ['Klaipėda', 'Vilnius', 'Alytus', 'Kaunas', 'Šiauliai', 'Whole Lithuania'],
      message: '{VALUE} is not a valid place. Only the following places are allowed: Klaipėda, Vilnius, Alytus, Kaunas, Šiauliai, Whole Lithuania.',
    },
  },
  category:{
  type: String,
  required: [true, 'Please specify the category of the event.'],
  enum: {
    values: [
      'Main places to see in Lithuania',
      'Calm and rest...',
      'Active trips and sports!',
      'Cultural places',
      'Local events',
    ],
    message: '{VALUE} is not a valid category. Allowed categories: Main places to see in Lithuania, Calm and rest..., Active trips and sports!',
  },
},
address:{
type:String,
required:[true,'Please enter the address'],
}, 

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Create and export the Event model
const Event = mongoose.model('Event', EventSchema);

module.exports = Event;
