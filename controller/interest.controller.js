const interestService = require('../services/interest.services');

exports.saveInterests = async (req, res, next) => {
    try {
        const { userId, interests } = req.body;

        if (!userId || !interests || !Array.isArray(interests) || interests.length === 0) {
            return res.status(400).json({ status: false, error: 'Invalid input data. Please provide userId and a non-empty array of interests.' });
        }

        const savedInterests = await interestService.saveInterests(userId, interests);

        console.log('Interests saved successfully:', savedInterests);
        res.status(200).json({ status: true, success: 'Interests saved successfully' });
    } catch (error) {
        console.error('Error in saveInterests controller:', error);
        res.status(500).json({ status: false, error: 'An error occurred while saving interests. Please try again later.' });
    }
};
