const express = require('express');
const app = express();
const port = 3000;

// تعريف معالج لمسار الجذر "/"
app.get('/', (req, res) => {
  res.send('Server is running');
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
