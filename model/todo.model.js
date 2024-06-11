const db = require('../config/db');
const mongoose = require('mongoose');
const { Schema } = mongoose;
const { usermodel, reviewmodel } =require("../model/user.model")

const todoSchema = new Schema({
    userId:{
        type: Schema.Types.ObjectId,
        ref: usermodel.modelName
    },
    religion:{
        type:String,
        required:true,
        
    },
    caste:{
        type:String,
        required:true,
    },
    nationality:{
        type:String,
        required:true,
    }
    ,
    city:{
        type:String,
        required:true,
    },
    height:{
        type:String,
        required:true,
    },
    marital_status:{
        type:String,
        required:true,
    },
    education:{
        type:String,
        required:true,
    },
    occupation:{
        type:String,
        required:true,
    },
});

const todomodel = db.model('todo',todoSchema);
module.exports= todomodel;