const express = require('express');
const app = express();
const cors = require('cors');
const multer = require('multer');
const eventRoutes = require('./routers/event.routes');
const registrationRoutes = require('./routers/registration.routes');
const userRoutes = require('./routers/user.routes');
const interestsRoutes = require('./routers/interest.routes');
const storeinfoRoutes = require('./routers/storeinfo.routes');
const todoroutes = require('./routers/todo.routes');
const messageroutes = require('./routers/message.routes');
const security = require('./controller/securitycheck');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    console.log('Multer destination function invoked');
    cb(null, 'C:/Users/Maheen Irfan/Desktop/nodejs/pictures');
  },
  filename: (req, file, cb) => {
    console.log('Multer filename function invoked');
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage });

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(upload.single('image'));

app.get('/', (req, res) => {
  res.send('Hello, hi, bye!');
});

app.use((req, res, next) => {
  console.log(`Incoming Request: ${req.method} ${req.url}`);
  next();
});

app.use('/api', (req, res, next) => {
  console.log(`API Route Hit: ${req.method} ${req.url}`);
  next();
});

app.use('/api', eventRoutes);
app.use('/', eventRoutes);
app.use('/', userRoutes);
app.use('/',security);
app.use('/interests', interestsRoutes);
app.use('/', storeinfoRoutes);
app.use('/', todoroutes);
app.use('/message', messageroutes);
app.use('/', registrationRoutes);
app.use('/images', express.static('C:/Users/Maheen Irfan/Desktop/nodejs/pictures'));

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: err.message || 'Something went wrong!' });
});

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

module.exports = app;
