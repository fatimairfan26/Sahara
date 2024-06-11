const StoreInfo = require('../model/storeinfo.model');


class storeinfoservices{
    static async saveinfo(userId, gender, height, dateofbirth , disability, marital, nationality, religion, occupation, city,bio, education){
        const saveinfo = new StoreInfo({userId, gender, height, dateofbirth , disability, marital, nationality, religion, occupation, city,bio, education});
        return await saveinfo.save();
    }
}


module.exports = storeinfoservices;