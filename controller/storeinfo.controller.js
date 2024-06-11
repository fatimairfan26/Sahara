const storeinfoservices = require('../services/storeinfo.services');
const StoreInfo = require('../model/storeinfo.model');

const saveinfo = async (req, res, next) => {
    try {
        const { userId, gender, height, dateofbirth, disability, marital, nationality, religion, occupation, city,bio, education } = req.body;

        if (!userId || !gender || !height || !dateofbirth || !disability || !marital || !nationality || !religion || !occupation || !city || !bio || !education) {
            return res.status(400).json({ status: false, error: 'Missing required fields' });
        }

        let store = await storeinfoservices.saveinfo(userId, gender, height, dateofbirth, disability, marital, nationality, religion, occupation, city,bio, education);

        console.log('Info saved successfully:', store);
        res.json({ status: true, success: 'Info saved successfully' });
    } catch (error) {
        console.error('Error in saveinfo controller:', error);
        next(error);
    }
}

const getUserInfo = async (req, res, next) => {
    try {
        const userId = req.params.userId;

        const userInfo = await StoreInfo.findOne({ userId });

        if (!userInfo) {
            return res.status(404).json({ error: 'User information not found' });
        }

        res.json(userInfo);
    } catch (error) {
        console.error('Error in getUserInfo controller:', error);
        next(error);
    }
};



module.exports = { saveinfo , getUserInfo};
