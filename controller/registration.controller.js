const registrationServices = require('../services/registration.services');

const saveRegistration = async (req, res, next) => {
    try {
        const {
            eventname, userId, firstName, lastName, email, contactNo,
            gender, city, address, postalCode, transport
        } = req.body;

        console.log(req.body); // Debugging: Log the received body

        // Correctly check if transport is undefined, not its truthiness
        if (
            !eventname || !userId || !firstName || !lastName || !email ||
            !contactNo || !gender || !city || !address || !postalCode ||
            typeof transport === 'undefined'
        ) {
            return res.status(400).json({ status: false, error: 'Missing required fields' });
        }

        // Assuming registrationServices.saveRegistration is the service function to save registration
        let registrationResult = await registrationServices.saveRegistration(
            eventname, userId, firstName, lastName, email, contactNo, gender,
            city, address, postalCode, transport
        );

        console.log("User's event info registered successfully:", registrationResult);
        res.json({ status: true, success: 'Users event info registered successfully' });
    } catch (error) {
        console.error('Error in saveRegistration controller:', error);
        next(error);
    }
};

module.exports = { saveRegistration };
