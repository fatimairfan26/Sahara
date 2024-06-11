const {usermodel, imageModel, reviewmodel, Report, CardDetail} = require('../model/user.model');
const StoreInfo = require('../model/storeinfo.model');
const jwt = require('jsonwebtoken');
const { response } = require('../app');
const bcrypt = require('bcrypt');  

class UserService{
  static async registration(email, password, username) {
      try {
          const existingUser = await usermodel.findOne({
              $or: [
                  { email: email },
                  { username: username }
              ]
          });
  
          if (existingUser) {
              const error = new Error('User with the provided email or username already exists');
              error.status = 409; 
              throw error;
          }
  
          const createuser = new usermodel({ email, password, username });
          return await createuser.save();
      } catch (err) {
          throw err;
      }
  }


  static async getAllUsers() {
    try {
      const users = await usermodel.find();
      const totalUsers = users.length;
      return { users, totalUsers };
    } catch (err) {
      throw err;
    }
  }
  


  static async checkuser(email){
      try{
          return await usermodel.findOne({email});
      }catch(err){
          throw err;
      }
  }
  static async setPassword(userId, newPassword) {
      try {
          const hashedPassword = await bcrypt.hash(newPassword, 10);
  
          return await usermodel.findByIdAndUpdate(
              userId,
              { password: hashedPassword },
              { new: true }
          );
      } catch (err) {
          console.error('Error in setPassword:', err);
          throw err;
      }
  }
  static async generatetoken(tokendata,secretKey, jwt_expire){
      return jwt.sign(tokendata, secretKey,{expiresIn:jwt_expire});
  }

  

}
class usernamesrvives {
  static async getuser(userId){
      try {
          const user = await usermodel.findById(userId);
          return user ? user.username : null;
        } catch (error) {
          console.error(error);
          throw error;
        }
      }

      static async getemail(userId) {
        try {
          const user = await usermodel.findById(userId);
          return user ? user.email : null;
        } catch (error) {
          console.error(error);
          throw error;
        }
      }
};


class reviewservices{
  static async createreview(userId,review,rating) {
     const createreview = new reviewmodel({userId,review,rating});
  return await createreview.save();
  } 
 
  static async getreviews() {
      try {
          const allReviews = await reviewmodel.find().populate('userId', 'username');
          return allReviews.map(review => ({
              ...review._doc,
              username: review.userId.username
          }));
      } catch (err) {
          throw err;
      }
  }
  static async getReviewsrating() {
    try {
      const allReviews = await reviewmodel.find();
      return allReviews;
    } catch (err) {
      throw err;
    }
  }

}

class imageservices {
    static async saveImage(userId, imagePath, check, isApproved) {
      try {
        const newImage = new imageModel({ userId, imagePath , check, isApproved });
        return await newImage.save();
      } catch (error) {
        console.error('Error saving image:', error);
        throw error;
      }
    }
    
    static async getImagesByUserId(userId) {
      try {
        console.log('Searching for images with userId:', userId);
        const userImages = await imageModel.find({ userId, check: 'profile' }).select('imagePath');
        console.log('Found images:', userImages);
        return userImages;
      } catch (error) {
        console.error('Error in getImagesByUserId:', error);
        throw error;
      }
    }
    
   

    static async getImagesByUserIdandpost(userId) {
      try {
        console.log('Searching for images with userId:', userId);
        const userImages = await imageModel.find({ userId, check: 'post' }).select('imagePath');
        console.log('Found images:', userImages);
        return userImages;
      } catch (error) {
        console.error('Error in getImagesByUserId:', error);
        throw error;
      }
    }
    
    
  }
  

  class searchservices {
    static async searchUsers(query) {
        try {
            return await usermodel.find({
                username: { $regex: query, $options: 'i' }
            }, { _id: 1, username: 1 });
        } catch (error) {
            console.error(error);
            throw error;
        }
    }
}


class SaveReport {
  static async saveReport(userId,Reporteduserid, reportOption, reason) {
      try {
          const report = new Report({ userId,Reporteduserid, reportOption, reason });
          await report.save();
          return report;
      } catch (error) {
          console.error(error);
          throw error;
      }
  }
}


class SaveCardDetail {
  static async saveCardDetails(userId, cardNumber, expiry, cvv) {
    try {
      const cardDetail = new CardDetail({ userId, cardNumber, expiry, cvv });
      await cardDetail.save();
      return cardDetail;
    } catch (error) {
      console.error(error);
      throw error;
    }
  }
}



module.exports = {UserService, imageservices, reviewservices, searchservices, usernamesrvives, SaveReport, SaveCardDetail};


