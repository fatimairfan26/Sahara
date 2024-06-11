const express = require('express');
const router = express.Router();
const cors = require('cors');
const eventController = require('../controller/event.controller');
const {eventReview} = require('../model/user.model');

router.use(cors());

router.post('/saveUpcomingEvent', eventController.saveUpcomingEvent);

router.post('/add-review', async (req, res) => {
    const { eventname, userId, review , rating} = req.body;
  
    try {
      const newReview = new eventReview({
        eventname,
        userId,
        review,
        rating
      });
  
      await newReview.save();
      res.status(200).json({ message: 'Review added successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });
  
  // Get reviews by event name
  router.get('/get-reviews/:eventname', async (req, res) => {
    const { eventname } = req.params;
  
    try {
      const reviews = await eventReview.find({ eventname });
      res.status(200).json({ reviews });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });

module.exports = router;
