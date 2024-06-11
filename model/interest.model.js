const mongoose = require('mongoose');
const { Schema } = mongoose;

const interestSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: 'user', 
        required: true,
    },
    interests: {
        type: [String], 
        required: true,
    },
    
});

const InterestModel = mongoose.model('interest', interestSchema);

module.exports = InterestModel;
