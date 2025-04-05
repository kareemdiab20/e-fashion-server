// api/auth/register.js
const admin = require('firebase-admin');
if (!admin.apps.length) {
  const serviceAccount = require('../../serviceAccountKey.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}
const db = admin.firestore();

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' });
  }
  const { fullName, email, password, phone } = req.body;
  if (!emailRegex.test(email)) {
    return res.status(400).json({ message: 'Error! Invalid email address.' });
  }

  try {
    // 1) إنشاء المستخدم في Firebase Auth
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: fullName,
      phoneNumber: phone,         // اختياري
    });

    // 2) إصدار Custom Token (تقدر تستخدمه كـ accessToken)
    const customToken = await admin.auth().createCustomToken(userRecord.uid);

    // 3) (اختياري) خزّن بيانات إضافية في Firestore
    await db.collection('users').doc(userRecord.uid).set({
      fullName,
      email,
      phone,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 4) ردّ الـ tokens مع الرسالة
    return res.status(200).json({
      accessToken: customToken,
      refreshToken: customToken, // لو ما عندك refresh flow منفصل
      message: 'User registered successfully',
      id: userRecord.uid,
    });

  } catch (e) {
    console.error('Registration error:', e);
    return res.status(500).json({ message: 'Server error', error: e.message });
  }
};
