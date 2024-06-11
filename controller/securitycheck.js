const express = require('express');
const router = express.Router();
const nodemailer = require('nodemailer');
const { usermodel, imageModel } = require('../model/user.model'); 
const cors = require('cors');
const app = express();
app.use(cors());


router.get('/pendingapproval', async (req, res) => {
  try {
    const images = await imageModel.find({ check: 'security', isApproved: false });
    const userIds = images.map(image => image.userId);
    const users = await usermodel.find({ _id: { $in: userIds } }, 'username');

    const result = users.map(user => ({
      userId: user._id,
      username: user.username,
    }));

    res.status(200).json(result);
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

router.get('/userimage/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const image = await imageModel.findOne({ userId, check: 'security' });

    if (!image) {
      return res.status(404).json({ success: false, error: 'Security image not found' });
    }

    res.status(200).json(image);
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

// Email configuration
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'fatiirfan2345@gmail.com',
    pass: 'pozneihnajmoidyf',
  },
});

// Helper function to send email
const sendEmail = async (to, subject, text) => {
  const mailOptions = {
    from: 'fatiirfan2345@gmail.com',
    to,
    subject,
    text,
  };

  await transporter.sendMail(mailOptions);
};

router.post('/acceptimage', async (req, res) => {
  try {
    const { userId } = req.body;

    const user = await usermodel.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    const image = await imageModel.findOne({ userId, check: 'security' });
    if (!image) {
      return res.status(404).json({ success: false, error: 'Security image not found' });
    }

    image.isApproved = true;
    await image.save();

    await sendEmail(user.email, 'Image Approval Status', 'Your security image has been approved. You can now access the dashboard.');

    res.status(200).json({ success: true, message: 'Image approval status updated' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

router.post('/rejectimage', async (req, res) => {
  try {
    const { userId } = req.body;

    const user = await usermodel.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    const image = await imageModel.findOne({ userId, check: 'security' });
    if (!image) {
      return res.status(404).json({ success: false, error: 'Security image not found' });
    }

    // Delete the image document
    await imageModel.findByIdAndDelete(image._id);


    // Send rejection email to user
    await sendEmail(user.email, 'Image Approval Status', 'Your security image has been rejected. Please upload a valid image.');

    res.status(200).json({ success: true, message: 'Image rejection status updated' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});


module.exports = router;