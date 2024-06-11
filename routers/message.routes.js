const express = require('express');
const router = express.Router();
// const [messageModel,acceptedConversationModel] = require('../model/messages.model');
// const  { usermodel, reviewmodel,imageModel } = require('../model/user.model');

const [messageModel, acceptedConversationModel] = require('../model/messages.model');
const { usermodel, reviewmodel, imageModel } = require('../model/user.model');

// Send Message Request API
router.post('/send', async (req, res) => {
  try {
    const { from, to, message } = req.body;
    if (!from || !to || !message) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    let status = 'pending';
    let receiverDecision ='pending';

    // Check if there is an accepted conversation between fromUser and toUser
    const acceptedConversationExists = await acceptedConversationModel.exists({ from, to });

    // If there's an accepted conversation, set status to 'accepted'
    if (acceptedConversationExists) {
      status = 'accepted';
      receiverDecision = 'accepted';
    }

    // Create a new message with the determined status
    const newMessage = new messageModel({
      from,
      to,
      message,
      timestamp: new Date(),
      status,
    });

    await newMessage.save();

    res.json({ success: true, message: 'Message request sent successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

// Inbox API
router.get('/inbox/:user/:otherUser', async (req, res) => {
  try {
    const { user, otherUser } = req.params;

    const userMessages = await messageModel
      .find({ $or: [{ from: otherUser, to: user }, { from: user, to: otherUser }] })
      .sort({ timestamp: 1 });

    // Update acceptance status for existing conversations
    await messageModel.updateMany(
      { to: user, from: otherUser, status: 'pending', acceptedConversations: { $all: [otherUser] } },
      { $set: { status: 'accepted', receiverDecision: 'accepted' } }
    );

    res.json({ success: true, messages: userMessages });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

// Get Inbox API for Message Requests
router.get('/requests/:user', async (req, res) => {
  try {
    const { user } = req.params;

    const messageRequests = await messageModel
      .find({ to: user, status: 'pending' })
      .populate('from', 'username'); // Populate sender information

    res.json({ success: true, messageRequests });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

// Accept Message Request API
router.post('/accmsg/:fromUser/:toUser', async (req, res) => {
  try {
    const { fromUser, toUser } = req.params;

    // Find the message between fromUser and toUser with status 'pending'
    const message = await messageModel.findOneAndUpdate(
      { from: fromUser, to: toUser, status: 'pending' },
      { $set: { status: 'accepted', receiverDecision: 'accepted' } },
      { new: true }
    );

    // Check if message exists
    if (message) {
      // Updating acceptedConversations array for the found message
      await messageModel.findByIdAndUpdate(
        message._id,
        { $addToSet: { acceptedConversations: fromUser } }
      );

      // Storing accepted conversation in the 'accmsg' collection
      const acceptedConversation = new acceptedConversationModel({ from: fromUser, to: toUser });
      await acceptedConversation.save();

      // update the conversation from toUser to fromUser
      const reverseAcceptedConversation = new acceptedConversationModel({ from: toUser, to: fromUser });
      await reverseAcceptedConversation.save();

      res.json({ success: true, message: 'Message request accepted successfully', message });
    } else {
      res.status(404).json({ success: false, error: 'Message not found or already accepted' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

// Reject Message Request API
router.post('/rejmsg/:fromUser/:toUser', async (req, res) => {
  try {
    const { fromUser, toUser } = req.params;

    // Finding the message between fromUser and toUser with status 'pending'
    const message = await messageModel.findOneAndUpdate(
      { from: fromUser, to: toUser, status: 'pending' },
      { $set: { status: 'rejected', receiverDecision: 'rejected' } },
      { new: true }
    );

    res.json({ success: true, message: 'Message request rejected successfully', message });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});




router.get('/sent/:user/:otherUser', async (req, res) => {
  try {
    const { user, otherUser } = req.params;
    const userMessages = await messageModel
      .find({ $or: [{ from: user, to: otherUser }, { from: otherUser, to: user }] })
      .sort({ timestamp: 1 });

    res.json({ success: true, messages: userMessages });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

router.get('/interacted/:user', async (req, res) => {
  try {
    const { user } = req.params;

    // Find distinct users interacted with, based on accepted messages
    const interactedUsers = await messageModel.distinct('from', { to: user, status: 'accepted' });
    const sentToUsers = await messageModel.distinct('to', { from: user, status: 'accepted' });

    // Merge the arrays of interacted users and sent-to users
    const allInteractedUsers = [...new Set([...interactedUsers, ...sentToUsers])];

    // Find details of the interacted users
    const users = await usermodel.find({ _id: { $in: allInteractedUsers } }, 'username');

    // Get the last message for each user
    const usersWithLastMessage = await Promise.all(users.map(async (user) => {
      const lastMessage = await messageModel
        .findOne({ $or: [{ from: user._id }, { to: user._id }], status: 'accepted' })
        .sort({ timestamp: -1 });

      return {
        ...user.toObject(),
        lastMessage: lastMessage ? lastMessage.toObject() : null,
      };
    }));

    const response = {
      success: true,
      users: usersWithLastMessage,
    };

    res.json(response);
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});


router.post('/markAsRead/:messageId', async (req, res) => {
  try {
    const { messageId } = req.params;
    await messageModel.findByIdAndUpdate(messageId, { $set: { isUnread: false } });
    res.json({ success: true, message: 'Message marked as read successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

router.get('/unreadMessageCount/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const unreadMessageCount = await messageModel.countDocuments({ to: userId, isUnread: true });

    res.json({ success: true, unreadMessageCount });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});




module.exports = router;