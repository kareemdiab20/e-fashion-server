// api/auth/register.js
const admin = require('firebase-admin');
// تهيئة Firebase بنفس الطريقة في index.js
if (!admin.apps.length) {
  const serviceAccount = require('../../serviceAccountKey.json'); // تعديل المسار ليشير للمجلد الجذر
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}
const db = admin.firestore();

// أبسط مثال على فحص الإيميل
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' });
  }
  const { fullName, email, password, phone } = req.body;
  if (!emailRegex.test(email)) {
    return res.status(400).json({ message: 'Error! Invalid email address.' });
  }
  // هنا بقية منطق الحفظ أو إنشاء المستخدم
  try {
    const docRef = await db.collection('users').add({ fullName, email, phone, createdAt: new Date() });
    return res.status(200).json({ message: 'User registered successfully', id: docRef.id });
  } catch (e) {
    return res.status(500).json({ message: 'Server error', error: e.message });
  }
};
