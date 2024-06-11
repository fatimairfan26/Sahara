const express = require('express');
const router = express.Router();
const cors = require('cors');
const interestController = require('../controller/interest.controller');

router.use(cors());

router.post('/', interestController.saveInterests);

module.exports = router;
