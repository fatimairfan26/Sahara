const InterestModel = require('../model/interest.model');
const {usermodel, imageModel} = require('../model/user.model');

class InterestService {
    static async saveInterests(userId, interests) {
        try {
            const existingUser = await usermodel.findById(userId);
            if (!existingUser) {
                throw new Error('User does not exist');
            }

            const saveInterests = new InterestModel({ userId, interests });
            return saveInterests.save();
        } catch (err) {
            console.error('Error in saveInterests service:', err);
            throw new Error(`An error occurred while saving interests: ${err.message}`);
        }
    }
}

module.exports = InterestService;
