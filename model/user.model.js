const mongoose = require('mongoose');
const db = require('../config/db');
const bcrypt = require('bcrypt');
const { Schema } = mongoose;
const userSchema = new Schema({
    username:{
        type:String,
        unique:true,
    },
    email:{
        type:String,
        lowercase:true,
        required:true,
        unique: true,
    },
    password:{
        type:String,
        required:true,
    }
});


userSchema.pre('save', async function (next) {
    try {
        if (!this.isModified('password')) {
            return next();
        }
        const salt = await bcrypt.genSalt(10);
        const hashpass = await bcrypt.hash(this.password, salt);
        this.password = hashpass;
        next();
    } catch (error) {
        next(error);
    }
});

userSchema.methods.comparepass = async function (userpassword) {
    try {
        console.log('Entered Password (Trimmed):', userpassword);
        console.log('Stored Hashed Password:', this.password);


        const storedHashSnippet = this.password.substring(0, 10);
        const enteredPasswordSnippet = userpassword.substring(0, 10);
        const isMatchSnippet = await bcrypt.compare(enteredPasswordSnippet, storedHashSnippet);
        console.log('bcrypt compare result (snippet):', isMatchSnippet);


        console.log('Stored Hashed Password characters:');
        for (const char of this.password) {
            console.log(char, char.charCodeAt(0));
        }

        console.log('Entered Password characters:');
        for (const char of userpassword) {
            console.log(char, char.charCodeAt(0));
        }


        const trimmedStoredHash = this.password.trim();
        const trimmedEnteredPassword = userpassword.trim();
        const isMatchTrimmed = await bcrypt.compare(trimmedEnteredPassword, trimmedStoredHash);
        console.log('bcrypt compare result (trimmed):', isMatchTrimmed);


        const isMatch = await bcrypt.compare(userpassword, this.password);
        console.log('bcrypt compare result:', isMatch);

        if (isMatch) {
            console.log('Password Comparison Succeeded');
        } else {
            console.error('Password Comparison Failed');
        }

        return isMatch;
    } catch (error) {
        console.error('bcrypt compare error:', error);
        throw error;
    }
};


const usermodel = mongoose.model('user', userSchema);

const imageSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: 'user', 
    },
    imagePath: {
        type: String,
        required: true,
    },
    check: {
        type: String,
        required: true,
    },

    isApproved: {
        type: Boolean,
        default: false,
      },

});



const imageModel = db.model('image', imageSchema);



const reviewSchema = new Schema({
    userId:{
        type: Schema.Types.ObjectId,
        ref: 'user',  
    },
    rating: {
        type: Number,
        required: true,
        min: 1, 
        max: 5, 
      },

    review:{
        type:String,
    }

});
const reviewmodel =db.model('review',reviewSchema);

const reportSchema = new mongoose.Schema({
    userId:{
        type: Schema.Types.ObjectId,
        ref: 'user', 
        required: true, 
    },
    Reporteduserid:{
        type: Schema.Types.ObjectId,
        ref: 'user', 
        required: true, 
    },
    reportOption:{
        type:String,
        required: true,

    },
    reason:{
        type:String,
        required: true,

    },
  });
  
  const Report = mongoose.model('Report', reportSchema);
  

  const cardDetailSchema = new mongoose.Schema({
    userId: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        required: true 
    },
    cardNumber: {
         type: String, 
         required: true 
        },
    expiry: { 
        type: String,
         required: true
         },
    cvv: { 
        type: String,
         required: true 
        },
  });
  
  const CardDetail = mongoose.model('CardDetail', cardDetailSchema);


const eventreviewSchema = new mongoose.Schema({
    eventname: { type: String, required: true },
    userId: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        required: true 
    },
    review: { type: String, required: true },
    rating: { type: Number, required: true },
  });
  
  const eventReview = mongoose.model('eventreview', eventreviewSchema);

module.exports = {usermodel, imageModel, reviewmodel, Report, CardDetail, eventReview};

