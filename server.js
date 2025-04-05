// 1. حمّل .env أول ما يشتغل السكربت
require('dotenv').config();

const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// بعدها تقدر تقرأ FIREBASE_CONFIG بأمان
const serviceAccount = JSON.parse(process.env.FIREBASE_CONFIG);

const admin = require('firebase-admin');
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}
const db = admin.firestore();

app.use(express.json());

app.get('/', (req, res) => {
  res.send('Server is running');
});

app.post('/api/auth/login', (req, res) => {
  const { username, password } = req.body;
  if (username === 'user' && password === 'password') {
    res.json({ message: 'Login successful' });
  } else {
    res.status(401).json({ message: 'Invalid credentials' });
  }
});

app.post('/api/auth/register', (req, res) => {
  const { username, password } = req.body;
  res.json({ message: 'User registered successfully', username });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
