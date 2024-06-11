const Registration = require('../model/registration.model').Registration;

class RegistrationServices {
    static async saveRegistration(eventname,userId, firstName, lastName, email, contactNo, gender, city, address, postalCode, transport) {
        const registration = new Registration({ eventname, userId, firstName, lastName, email, contactNo, gender, city, address, postalCode, transport });
        return await registration.save();
    }
}


module.exports = RegistrationServices;