const { response } = require('../app');
const {UserService, imageservices, reviewservices, searchservices, usernamesrvives, SaveReport, SaveCardDetail} = require('../services/user.services');
const StoreInfo = require('../model/storeinfo.model');
const {usermodel, imageModel, reviewmodel, Report, CardDetail } = require('../model/user.model');
const bcrypt = require('bcrypt');

exports.login = async (req, res, next) => {
  try {
      const { email, password } = req.body;

      const user = await UserService.checkuser(email);

      if (!user) {
          return res.status(401).json({ status: false, error: 'Email does not exist' });
      }

      const isMatch = await user.comparepass(password);

      if (!isMatch) {
          return res.status(401).json({ status: false, error: 'Invalid password' });
      }

      const image = await imageModel.findOne({ userId: user._id, check: 'security' });

      if (!image) {
          return res.status(200).json({ status: true, message: 'Your profile is under review' });
      }

      if (!image.isApproved) {
          return res.status(200).json({ status: true, message: 'Your profile is under review' });
      }

      let tokendata = { _id: user._id, email: user.email };
      const token = await UserService.generatetoken(tokendata, "secretKey", '1h');
      res.status(200).json({ status: true, token: token });
  } catch (error) {
      console.error(error); 
      res.status(500).json({ status: false, error: 'An error occurred during login' });
  }
};

exports.login2 = async (req, res, next) => {
  try {
      const { email, password } = req.body;
     
      const user = await UserService.checkuser(email);

      if (!user) {
          return res.status(401).json({ status: false, error: 'Email does not exist' });
      }

      const isMatch = await user.comparepass(password);

      if (!isMatch) {
          return res.status(401).json({ status: false, error: 'Invalid password' });
      }

      let tokendata = { _id: user._id, email: user.email };
      const token = await UserService.generatetoken(tokendata, "secretKey", '1h');
      res.status(200).json({ status: true, token: token });
  } catch (error) {
      console.error(error); 
      res.status(500).json({ status: false, error: 'An error occurred during login' });
  }
};

exports.updatePassword = async (req, res, next) => {
    try {
      console.log('Update Password endpoint reached!');
      console.log('Request body:', req.body); 
  
      const { email, newPassword } = req.body;
      console.log('Email:', email);
      console.log('New Password:', newPassword);
      
      if (!email || !newPassword) {
        return res.status(400).json({ status: false, error: 'Email and newPassword are required in the request body' });
      }
  
      const user = await UserService.checkuser(email);
  
      if (!user) {
        return res.status(404).json({ status: false, error: 'User not found for the provided email' });
      }
  
      await UserService.setPassword(user._id, newPassword);
  
      res.status(200).json({ status: true, success: 'Password updated successfully' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ status: false, error: 'An error occurred during password update' });
    }
  };
  


  exports.uploadImage = async (req, res) => {
    try {
      const { userId, check} = req.body; 
      if (!req.file) {
        return res.status(400).json({ success: false, error: 'No image uploaded' });
      }
  
      const imagePath = req.file.path;
      await imageservices.saveImage(userId, imagePath, check);
  
      res.status(200).json({ success: true, imagePath , check});
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
  };

  exports.getAllUserImages = async (req, res) => {
    try {
        const { userIds } = req.body;
        const postUserImages = [];

        for (const userId of userIds) {
            const userImages = await imageservices.getAllUserImages(userId);
            const postImages = userImages.filter(image => image.check === 'post');
            postUserImages.push({ userId, images: postImages });
        }

        res.status(200).json({ success: true, postUserImages });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
};

  


exports.register = async (req, res, next) => {
    try {
        const { email, password,username } = req.body;
        const successres = await UserService.registration(email, password,username);
        res.json({ status: true, success: "user registered successfully" });
    } catch (error) {
        throw error;
    }
};

exports.getusername= async (req, res) => {
  const { userId } = req.params;
  try {
    const username = await usernamesrvives.getuser(userId);
    res.json({ username });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

exports.getemail = async (req, res) => {
  const { userId } = req.params;
  try {
    const email = await usernamesrvives.getemail(userId);
    res.json({ email });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

exports.createreview =async (req,res,next)=>{
    try{
        const{userId,review,rating}= req.body;

        let RE = await reviewservices.createreview(userId,review,rating);

        res.json({status:true,success:RE});
    }
    catch(error){
        next(error);
    }
}


exports.getAllUsers = async (req, res) => {
  try {
    const { users, totalUsers } = await UserService.getAllUsers();
    res.status(200).json({ success: true, users, totalUsers });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Failed to fetch users' });
  }
};


exports.getAllReviews = async (req, res, next) => {
    try {
        const allReviews = await reviewservices.getreviews();
        res.json({ status: true, success: allReviews });
    } catch (error) {
        next(error);
    }
 };

 exports.getrating = async (req, res, next) => {
  try {
    const allReviews = await reviewservices.getReviewsrating();
    
    // Calculate the average rating
    const totalRatings = allReviews.reduce((sum, review) => sum + (review.rating || 0), 0);
    const averageRating = allReviews.length > 0 ? (totalRatings / allReviews.length) : 0;
    
    res.json({ status: true, success: allReviews, averageRating });
  } catch (error) {
    next(error);
  }
};



  exports.getemail = async (req, res) => {
  const { userId } = req.params;
  try {
    const email = await usernamesrvives.getemail(userId);
    res.json({ email });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

  exports.search = async (req, res, next) => {
    try {
        const { query } = req.params;

        if (!query) {
            return res.status(400).json({ error: 'Search query is required' });
        }

        console.log('Received search query:', query);

        const foundUsers = await searchservices.searchUsers(query);
        res.json(foundUsers);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
};



exports.createreport = async (req, res, next) => {
  const { userId,Reporteduserid, reportOption, reason } = req.body;
  try {
    await SaveReport.saveReport(userId,Reporteduserid ,reportOption, reason);
    res.status(201).json({ success: true, message: 'Report saved successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Failed to save report' });
  }
};

exports.getReports = async (req, res, next) => {
  try {
    const reports = await Report.find();
    res.status(200).json({ success: true, reports });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Failed to fetch reports' });
  }
};

exports.deleteUser = async (req, res, next) => {
  const { id } = req.params;
  try {
    const User = await usermodel.findByIdAndDelete(id);
    if (User) {
      res.status(200).json({ success: true, message: 'User deleted successfully' });
    } else {
      res.status(404).json({ success: false, message: 'User not found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Failed to delete user' });
  }
};

exports.deleteReport = async (req, res, next) => {
  const { id } = req.params;
  try {
    const report = await Report.findByIdAndDelete(id);
    if (report) {
      res.status(200).json({ success: true, message: 'Report deleted successfully' });
    } else {
      res.status(404).json({ success: false, message: 'Report not found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Failed to delete report' });
  }
};

exports.storeCardDetails = async (req, res, next) => {
  try {
    const { userId, cardNumber, expiry, cvv } = req.body;
    const cardDetail = new CardDetail({ userId, cardNumber, expiry, cvv });
    await cardDetail.save();
    res.status(201).json({ message: 'Card details saved successfully' });
  } catch (error) {
    console.error('Error saving card details:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}



exports.getLatestProfileImage = async (req, res) => {
  try {
      const userId = req.params.userId;

      
      const latestImage = await imageModel.findOne({ userId, check: 'profile' })
          .sort({ _id: -1 }) 
          .exec();

      if (!latestImage) {
          return res.status(404).json({ success: false, error: 'No profile image found' });
      }

      res.status(200).json({ success: true, image: latestImage });
  } catch (error) {
      console.error('Error fetching latest profile image:', error);
      res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};



const storeInfoModel = require('../model/storeinfo.model'); 

exports.updateUserDetails = async (req, res) => {
    try {
        const userId = req.params.userId;
        const { email, bio } = req.body;

        if (!email && !bio) {
            return res.status(400).json({ success: false, error: 'No details to update' });
        }

        let updatedUser, updatedStoreInfo;

        if (email) {
            updatedUser = await usermodel.findByIdAndUpdate(
                userId,
                { email },
                { new: true }
            );
        }

        // Update bio in storeinfo model if provided
        if (bio) {
            updatedStoreInfo = await storeInfoModel.findOneAndUpdate(
                { userId },
                { bio },
                { new: true }
            );
        }

        res.status(200).json({
            success: true,
            message: 'User details updated successfully',
            updatedUser,
            updatedStoreInfo,
        });
    } catch (error) {
        console.error('Error updating user details:', error);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
};