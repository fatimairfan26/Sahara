const tododservices =require("../services/todo.services");

exports.createtodo =async (req,res,next)=>{
    try{
        const{userId,religion,caste,nationality,city,height,marital_status,education,occupation}= req.body;

        let todo = await tododservices.createtodo(userId,religion,caste,nationality,city,height,marital_status,education,occupation);

        res.json({status:true,success:todo});
    }
    catch(error){
        next(error);
    }
}