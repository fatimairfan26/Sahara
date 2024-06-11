const todomodel = require("..//model/todo.model");


class todoservices{
    static async createtodo(userId,religion,caste,nationality,city,height,marital_status,education,occupation) {
       const createtodo = new todomodel({userId,religion,caste,nationality,city,height,marital_status,education,occupation});
    return await createtodo.save();
    } 
}
module.exports = todoservices;