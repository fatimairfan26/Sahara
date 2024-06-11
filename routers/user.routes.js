const express = require('express');
const router = express.Router();
const cors = require('cors');
const usercontroller = require('../controller/user.controller');
const { imageservices, saveReport, SaveCardDetail } = require('../services/user.services');
const matrimonialController = require('../controller/matrimonial.controller');
const { Accepted, Rejected, blocked } = require('../model/matrimonial.model');
const {usermodel} = require('../model/user.model');
const mongoose = require('mongoose');
const nodemailer = require('nodemailer');

router.use(cors());

router.post('/review', usercontroller.createreview);
router.get('/allreviews', usercontroller.getAllReviews); 
router.get('/search/:query', usercontroller.search);
router.get('/user/:userId/username', usercontroller.getusername);
router.post('/registration', usercontroller.register);
router.post('/login', usercontroller.login);
router.post('/login2', usercontroller.login2);
router.post('/updatePassword', usercontroller.updatePassword);
router.post('/uploads', usercontroller.uploadImage);
router.get('/profile/images/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;

    if (!userId) {
      return res.status(400).json({ success: false, error: 'Invalid user ID' });
    }

    const userImages = await imageservices.getImagesByUserId(userId);

    res.status(200).json({ success: true, userImages });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

router.get('/latestprofileimage/:userId', usercontroller.getLatestProfileImage);
router.put('/update/:userId', usercontroller.updateUserDetails);
router.get('/post/images/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;

    if (!userId) {
      return res.status(400).json({ success: false, error: 'Invalid user ID' });
    }

    const userImages = await imageservices.getImagesByUserIdandpost(userId);

    res.status(200).json({ success: true, userImages });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

router.post('/report', usercontroller.createreport);
router.get('/getreports', usercontroller.getReports);
router.post('/storecard', usercontroller.storeCardDetails);
router.get('/getusername/:userId', usercontroller.getusername);
router.get('/suggest/:userId', matrimonialController.provideSuggestions);
router.post('/accept/:userId/:profileId', matrimonialController.acceptUser);
router.post('/reject/:userId/:profileId', matrimonialController.rejectUser)
router.get('/acceptedUsers/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const acceptedUsers = await Accepted.find({ userId }, 'profileId');
    res.status(200).json({ success: true, acceptedUsers });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

router.get('/rejectedUsers/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const rejectedUsers = await Rejected.find({ userId }, 'profileId');
    res.status(200).json({ success: true, rejectedUsers });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

router.post('/blocked', async (req, res) => {
  try {
      const { userId, profileId } = req.body;
      const Blocked = new blocked({ userId, profileId });
      await Blocked.save();
      res.status(201).json(Blocked);
  } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Failed to block user' });
  }
});

router.get('/blocked/:userId', async (req, res) => {
  try {
      const userId = req.params.userId;
      const blockedUsers = await blocked.find({ userId });
      res.json(blockedUsers);
  } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Failed to get blocked users' });
  }
});

router.delete('/deletereport/:id', usercontroller.deleteReport);
router.delete('/deleteuser/:id', usercontroller.deleteUser);
router.get('/getemail/:userId', usercontroller.getemail);
router.get('/allusers', usercontroller.getAllUsers);
router.get('/getrating', usercontroller.getrating);


const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'neeham657@gmail.com',
    pass: 'ihlspydujymmcztx'
  }
});

// Route to send an email
router.post('/send-email', (req, res) => {
  const { recipientEmail, subject, text } = req.body;

  const mailOptions = {
    from: 'neeham657@gmail.com',
    to: recipientEmail,
    subject: subject,
    text: text
  };

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      return res.status(500).json({ error: error.toString() });
    }
    res.status(200).json({ message: 'Email sent: ' + info.response });
  });
});


module.exports = router;
