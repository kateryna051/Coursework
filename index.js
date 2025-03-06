const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const flash = require('express-flash');
const rateLimit = require('express-rate-limit');
const auth_route = require('./routes/auth_router');
const event_route = require('./routes/event_router');
const session = require('express-session');
const path = require('path');
const dotenv = require('dotenv');

require('dotenv').config(); 
// Initialize Express
const app = express();
app.use(session({
  secret: 'kkk',  // Change this to a secure key
  resave: false,
  saveUninitialized: true,
  cookie: { secure: false }  // Use 'secure: true' in production with HTTPS
}));
// Middleware
app.use(bodyParser.json());
app.use(flash());
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
// MongoDB connection
mongoose
  .connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('MongoDB connected'))
  .catch((err) => console.log(err));
 
// Routes
app.use(cors());

// Alternatively, allow only specific origins
app.use(
  cors({
    origin: '*', // Change to your Flutter app's origin
    methods: ['GET', 'POST', 'PUT', 'DELETE','PATCH'],
    credentials: true,
  })
);
const limiter = rateLimit({
  max: 1000,
  windowMs: 60 * 60 * 1000,
  message: 'Too many requests from this IP, please try again in an hour!'
});
app.use('/api', limiter);
app.use('/api', auth_route);
app.use('/api/events', event_route);
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));


/*app.post('/api/events/create',(res,req)=>{
  const{ name,description,date,time,photos} = req.body;
  res.status(200).send({message: 'Event created!'});
})*/


// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
