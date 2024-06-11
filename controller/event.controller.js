const eventServices = require('../services/event.services');

const saveUpcomingEvent = async (req, res, next) => {
    try {
        const {
            name, rating, categoryName, location, about, time, money, date, day, cantplay, interest, imagePath
        } = req.body;

        console.log('Request Body:', req.body);

        if (
            !name || !categoryName || !location || !about || !time ||
            !money || !date || !day || !Array.isArray(cantplay) || !Array.isArray(interest) || !imagePath
        ) {
            console.log('Missing required fields');
            return res.status(400).json({ status: false, error: 'Missing required fields' });
        }

        let eventResult = await eventServices.saveUpcomingEvent(
            name, rating, categoryName, location, about, time, money, date, day, cantplay, interest, imagePath
        );

        console.log("Upcoming event info saved successfully:", eventResult);
        res.json({ status: true, success: 'Upcoming event info saved successfully' });
    } catch (error) {
        console.error('Error in saveUpcomingEvent controller:', error);
        next(error);
    }
};

module.exports = { saveUpcomingEvent };
