
const mongoose = require('mongoose');
const { Schema } = mongoose;
const {usermodel, imageModel} = require('../model/user.model');


const registrationSchema = new Schema({
  eventname: {
    type: String, 
    ref: 'Event',
  },
  userId: {
    type: Schema.Types.ObjectId,
    ref: usermodel.modelName,
  },
  firstName: {
    type: String,
    required: true,
  },
  lastName: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
  },
  contactNo: {
    type: String,
    required: true,
  },
  gender: {
    type: String,
    required: true,
  },
  city: {
    type: String,
    required: true,
  },
  address: {
    type: String,
    required: true,
  },
  postalCode: {
    type: String,
    required: true,
  },
  transport: {
    type: Boolean,
     required: true // Default value for transport field
  },
});

const Registration = mongoose.model('Registration', registrationSchema);

const eventSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  rating: {
    type: Number,
    default: 0,
  },
  categoryName: {
    type: String,
    required: true,
  },
  location: {
    type: String,
    required: true,
  },
  about: {
    type: String,
    required: true,
  },
  time: {
    type: String,
    required: true,
  },
  money: {
    type: String,
    required: true,
  },
  date: {
    type: String,
    required: true,
  },
  day: {
    type: String,
    required: true,
  },
  cantplay :{ type: [String], required: true},
  interest: { type: [String], required: true }, 
  imagePath: {
    type: String,
    required: true,
},
}, { collection: 'upcomingevent' });

const Event = mongoose.model('Event', eventSchema);

const previouseventsSchema = new mongoose.Schema({
    eventName: { type: String, required: true },
    time: { type: String, required: true },
    date: { type: String, required: true },
    day: { type: String, required: true },
    rating: { type: Number, required: true },
    categoryName: { type: String, required: true },
    about: { type: String, required: true },
    cantplay :{ type: [String], required: true},
    location: {
      type: String,
      required: true,
    },
    interest: { type: [String], required: true }, 
    imagePath: {
      type: String,
      required: true,
  },
}, { collection: 'previousevents' });

const PreviousEvent = mongoose.model('previousevents', previouseventsSchema);


const movePastEvents = async () => {
  try {
    const currentDateTime = new Date();

    // Find all upcoming events
    const upcomingEvents = await Event.find();

    // Iterate over each event
    for (const event of upcomingEvents) {
      const eventDateTimeString = `${event.date.replace('rd', '').replace('th', '').replace('st', '').replace('nd', '')} ${event.time}`;
      const eventDateTime = new Date(eventDateTimeString);

      // Compare event's date and time with current date and time
      if (eventDateTime < currentDateTime) {
        // Check if the event has the required fields for PreviousEvent model
        if ( !event.name) {
          console.log(`Event '${event.name}' is missing required fields for PreviousEvent and cannot be moved`);
          console.log('Event details:', event);
          continue;
        }

        // Create a new PreviousEvent object with required fields
        const previousEvent = new PreviousEvent({
          eventName: event.name,
          time: event.time,
          date: event.date,
          day: event.day,
          rating: event.rating,
          categoryName: event.categoryName,
          about: event.about,
          cantplay: event.cantplay , // Default to empty array if not present
          location: event.location,
          interest: event.interest , // Default to empty array if not present
          imagePath: event.imagePath
        });

        // Save the previous event
        await previousEvent.save();

        // Delete the event from the upcoming events collection
        await Event.deleteOne({ _id: event._id });

        console.log(`Moved event '${event.name}' to PreviousEvent collection`);
      }
    }

    console.log('Checked all events for past dates');
  } catch (error) {
    console.error('Error moving past events:', error);
  }
};




module.exports = { Registration, Event, PreviousEvent , movePastEvents};