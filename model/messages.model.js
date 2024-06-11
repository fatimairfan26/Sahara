const mongoose = require('mongoose');
const { Schema } = mongoose;

const messageSchema = new Schema({
    from: {
      type: Schema.Types.ObjectId,
      ref: 'user',
      required: true
    },
    to: {
      type: Schema.Types.ObjectId,
      ref: 'user',
      required: true
    },
    message: {
      type: String,
      required: true
    },
    timestamp: {
      type: Date,
      default: Date.now
    },
    status: {
      type: String,
      enum: ['pending', 'accepted', 'rejected'],
      default: 'pending'
    },
    receiverDecision: {
      type: String,
      enum: ['accepted', 'rejected', 'pending'],
      default: 'pending'
    },
    acceptedConversations: [{
      type: Schema.Types.ObjectId,
      ref: 'user'
    }]
  });
  
  const messageModel = mongoose.model('message', messageSchema);

  
// new schema for accepted conversations
const acceptedConversationSchema = new Schema({
    from: {
      type: Schema.Types.ObjectId,
      ref: 'user',
      required: true
    },
    to: {
      type: Schema.Types.ObjectId,
      ref: 'user',
      required: true
    }
  });
  
  const acceptedConversationModel = mongoose.model('acceptedConversation', acceptedConversationSchema);
  
  

module.exports = [messageModel,acceptedConversationModel];