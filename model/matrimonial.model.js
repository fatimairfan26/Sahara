const mongoose = require('mongoose');
const { Schema } = mongoose;


const acceptedSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: 'user'
    },
    profileId: {
        type: Schema.Types.ObjectId,
        ref: 'storeinfo'
    }
});

const Accepted = mongoose.model('AcceptedUser', acceptedSchema);


const rejectedSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: 'user' 
    },
    profileId: {
        type: Schema.Types.ObjectId,
        ref: 'storeinfo' 
        }
});

const Rejected = mongoose.model('RejectedUser', rejectedSchema);

const blockedSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: 'user'
    },
    profileId: {
        type: Schema.Types.ObjectId,
        ref: 'user'
    }
});

const blocked = mongoose.model('blockeduser', blockedSchema);

module.exports = { Accepted, Rejected, blocked };