const express = require('express');
const eventController = require('../Controllers/event_controller');
const authController = require('../Controllers/auth_controller')
const router = express.Router();

router.post('/create', eventController.createEvent, authController.protect);
router.put('/edit/:id', eventController.editEvent);
router.delete('/delete/:id', eventController.deleteEvent);
router.get('/get/:id',eventController.getEvent);
router.get('/today', eventController.getEventsForToday);
router.get('/bydate', eventController.getEventsByDate);
router.get('/byplace', eventController.getEventsByPlace);
router.get('/placedate', eventController.getEventsByDateAndPlace);
router.get('/category', eventController.getEventsByCategory);

module.exports = router;