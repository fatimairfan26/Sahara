const Event = require('../model/registration.model').Event;

class EventServices {
  static async saveUpcomingEvent(name, rating, categoryName, location, about, time, money, date, day, cantplay, interest, imagePath) {
    const event = new Event({ name, rating, categoryName, location, about, time, money, date, day, cantplay, interest, imagePath });
    return await event.save();
  }
}

module.exports = EventServices;
