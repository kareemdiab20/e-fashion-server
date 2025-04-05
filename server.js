const express = require('express');
const app = express();
const port = process.env.PORT || 3000;  // استخدم المنفذ الذي تحدده Vercel

app.get('/', (req, res) => {
  res.send('Server is running');
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
