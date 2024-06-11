const express = require('express');
const app = require('./app');
const db = require('./config/db');
const port = 3000;
const cors = require('cors');
const usermodel = require('./model/user.model');
const imageModel = require('./model/user.model');
const todomodel = require('./model/todo.model');
const reviewmodel = require('./model/user.model');

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(cors());

db.once('open', () => {
  console.log('Database connection established successfully.');

  app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
  });
});

db.on('error', (error) => {
  console.error('Error connecting to the database:', error);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});
