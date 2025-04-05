const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// هذه السطر يتيح للسيرفر التعامل مع JSON في الطلبات
app.use(express.json()); 

// مسار GET لواجهة الـ Home
app.get('/', (req, res) => {
  res.send('Server is running');
});

// مسار POST لتسجيل الدخول
app.post('/api/auth/login', (req, res) => {
  const { username, password } = req.body;
  // هنا يمكنك إضافة منطق التحقق من المستخدم
  if (username === 'user' && password === 'password') {
    res.json({ message: 'Login successful' });
  } else {
    res.status(401).json({ message: 'Invalid credentials' });
  }
});

// مسار POST للتسجيل
app.post('/api/auth/register', (req, res) => {
  const { username, password } = req.body;
  // هنا يمكنك إضافة منطق لإنشاء حساب جديد
  res.json({ message: 'User registered successfully', username });
});

// بدء السيرفر
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
