const admin = require('firebase-admin');
const path = require('path');

// المسار الصحيح لملف serviceAccountKey.json في المجلد الرئيسي للمشروع
const serviceAccount = path.join(__dirname, '..', 'serviceAccountKey.json'); // تعديل المسار ليشير للمجلد الرئيسي

// إذا لم يتم تهيئة Firebase من قبل، نقوم بتهيئته باستخدام خدمة الحساب
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

// مثال على كيفية إضافة بيانات إلى Firestore
db.collection('users').add({
  name: 'John Doe',
  email: 'johndoe@example.com',
  createdAt: new Date()
})
.then(docRef => {
  console.log('Document written with ID: ', docRef.id);
})
.catch(error => {
  console.error('Error adding document: ', error);
});

module.exports = (req, res) => {
  res.status(200).send('Firebase connection established');
};
