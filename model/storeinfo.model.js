const mongoose = require('mongoose');
const {usermodel, imageModel} = require('../model/user.model');
const { Schema } = mongoose;

const storeinfoSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: usermodel.modelName
    },
    gender: {
        type: String,
        required: true,
    },
    height: {
        type: String,
        required: true,
    },
    dateofbirth: {
        type: Date,
        required: true,
    },
    disability: {
        type: String,
        required: true,
    },
    marital: {
        type: String,
        required: true,
    },
    nationality: {
        type: String,
        required: true,
    },
    religion: {
        type: String,
        required: true,
    },
    occupation: {
        type: String,
        required: true,
    },
    city: {
        type: String,
        required: true,
    }, 
    education: {
        type: String,
        required: true,
    },
    bio:{
        type: String,
        required: true,
    }
});

const StoreInfo = mongoose.model('info', storeinfoSchema);

module.exports = StoreInfo;

