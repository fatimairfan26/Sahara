const router = require('express').Router();
const cors = require('cors');
const { Registration, Event, PreviousEvent, movePastEvents } = require('../model/registration.model'); 
const InterestModel = require('../model/interest.model'); 
const StoreInfo  = require('../model/storeinfo.model'); 
const registrationController = require('../controller/registration.controller');
const cron = require('node-cron');

router.use(cors());

router.post('/register', registrationController.saveRegistration);               //eventregistrationform

router.get('/events', async (req, res) => {
  try {
    const category = req.query.category;

    if (!category) {
      return res.status(400).json({ error: 'Category is required in the query parameters' });
    }

    const events = await Event.find({ categoryName: category });

    res.json(events);
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.get('/eventsByDisability/:userId', async (req, res) => {              //upcomingevents#onlyforyou
    try {
        const userId = req.params.userId.trim();
        const userInfo = await StoreInfo.findOne({ userId });
        console.log(userId);
        
        if (!userInfo) {
          return res.status(404).json({ status: false, error: 'User not found' });
        }
        const userInterestsDocument = await InterestModel.findOne({ userId });

        if (!userInterestsDocument) {
          return res.status(404).json({ status: false, error: 'User interests not found' });
        }
    
        const userInterests = userInterestsDocument.interests || []; 
        const userDisability = userInfo.disability;
        console.log(userDisability);
        
        // Fetch all events
        const allEvents = await Event.find();
        console.log(allEvents);
  
        const filteredEvents = await Event.find({
          $and: [
            {
              $or: [
                { cantplay: { $exists: false } },
                { cantplay: { $not: { $regex: new RegExp(userDisability, 'i') } } }
              ]
            },
            {
              $or: [
                { interest: { $exists: false } },
                { interest: { $in: userInterests } }
              ]
            }
          ]
        });
        
        res.json(filteredEvents);
    } catch (error) {
      console.error('Error fetching events:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

router.get('/allPreviousEvents', async (req, res) => {                        //seeallfor previous events
    try {
        const allPreviousEvents = await PreviousEvent.find();
        res.json(allPreviousEvents);
    } catch (error) {
        console.error('Error fetching all previous events:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

router.get('/previouseventsByDisability/:userId', async (req, res) => {             //previous events
  try {
    const userId = req.params.userId.trim();
    const userInfo = await StoreInfo.findOne({ userId });

    if (!userInfo) {
      return res.status(404).json({ status: false, error: 'User not found' });
    }
    const userInterestsDocument = await InterestModel.findOne({ userId });

    if (!userInterestsDocument) {
      return res.status(404).json({ status: false, error: 'User interests not found' });
    }

    const userInterests = userInterestsDocument.interests || []; 
    const userDisability = userInfo.disability;

    const allPreviousEvents = await PreviousEvent.find();

    const filteredPreviousEvents = await PreviousEvent.find({
      $and: [
        {
          $or: [
            { cantplay: { $exists: false } },
            { cantplay: { $not: { $regex: new RegExp(userDisability, 'i') } } }
          ]
        },
        {
          $or: [
            { interest: { $exists: false } },
            { interest: { $in: userInterests } }
          ]
        }
      ]
    });
    
    console.log('All previous events:', allPreviousEvents);
    console.log('Filtered previous events:', filteredPreviousEvents);
    
    res.json(filteredPreviousEvents);
  } catch (error) {
    console.error('Error fetching previous events:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.get('/allupcomingEvents', async (req, res) => {                        //seeallfor previous events
    try {
        const allPreviousEvents = await Event.find();
        res.json(allPreviousEvents);
    } catch (error) {
        console.error('Error fetching all previous events:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// Schedule the movePastEvents function to run every minute
cron.schedule('* * * * *', async () => {
  console.log('Checking for past events');
  await movePastEvents();
});




module.exports = router;
