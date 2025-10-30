import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import statusRouter from './src/routes/routes.status.js';
import UserRouter from './src/modules/Auth/Auth.LoginRegister.js';


const app = express();
const limiter = rateLimit ({
  windowMs: 30 * 60 * 1000,
  limit: 100,
  legacyHeaders: false,
  ipv6Subnet: 60,
});

app.use(cors());

app.use('Status/', statusRouter);
app.use('Login/', UserRouter);

app.listen(3000,  () => {
  console.log("[ SERVER RUNNING IN PORT 3000 ]");
});