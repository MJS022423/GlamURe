import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import statusRouter from './src/routes/routes.status.js';
import Authrouter from './src/modules/Auth/Auth.Routes.js';
import Productrouter from './src/modules/Product/Product.routes.js';

const app = express();
const limiter = rateLimit ({
  windowMs: 30 * 60 * 1000,
  limit: 100,
  legacyHeaders: false,
  ipv6Subnet: 60,
});

app.use(cors());

app.use('/Status', statusRouter);
app.use('/auth', Authrouter);
app.use('/product', Productrouter);

app.listen(3000,  () => {
  console.log("[ SERVER RUNNING IN PORT 3000 ]");
});