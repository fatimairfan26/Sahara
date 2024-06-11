const router = require('express').Router();
const cors = require('cors');
const storeinfocontroller = require('../controller/storeinfo.controller');
const StoreInfo = require('../model/storeinfo.model');

router.use(cors());

router.post('/', storeinfocontroller.saveinfo);
router.get('/get/:userId', storeinfocontroller.getUserInfo);

router.get('/compatibility/:userId1/:userId2', async (req, res) => {
    const { userId1, userId2 } = req.params;

    try {
        const userInfo1 = await StoreInfo.findOne({ userId: userId1 });
        const userInfo2 = await StoreInfo.findOne({ userId: userId2 });

        if (!userInfo1 || !userInfo2) {
            return res.status(404).json({ error: 'One or both users not found' });
        }

        const criteria = [
            'religion',
            'nationality',
            'city',
            'height',
            'marital',
            'education',
            'occupation'
        ];

        let matchCount = 0;

        criteria.forEach((criterion) => {
            if (userInfo1[criterion] === userInfo2[criterion]) {
                matchCount++;
            }
        });

        const compatibilityScore = (matchCount / criteria.length) * 100;

        res.json({
            compatibilityScore,
            matches: matchCount,
            totalCriteria: criteria.length,
        });
    } catch (error) {
        console.error('Error calculating compatibility:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});



module.exports = router;
