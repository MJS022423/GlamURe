import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';


const app = express();
const limiter = rateLimit ({
  windowMs: 30 * 60 * 1000,
  limit: 100,
  legacyHeaders: false,
  ipv6Subnet: 60,
});

app.use(cors());

app.listen(3000,  () => {
  console.log("[ SERVER RUNNING IN PORT 3000 ]");
});