const router = require('express').Router();
const todocontroller = require('../controller/todo.controller');

router.post('/pop', todocontroller.createtodo);

module.exports = router;