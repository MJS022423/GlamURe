import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import Authrouter from './src/modules/Auth/Auth.Routes.js';
// import Productrouter from './src/modules/Post/Post.routes.js';
// import MessageRouter from './src/modules/Message/Message.Routes.js';
// import BookmarkRouter from './src/modules/Bookmark/Bookmark.Routes.js';
import dotenv from 'dotenv';


dotenv.config();
const app = express();
const limiter = rateLimit ({
  windowMs: 30 * 60 * 1000,
  limit: 100,
  legacyHeaders: false,
  ipv6Subnet: 60,
});

app.use(limiter);
app.use(cors());
app.use('/auth', Authrouter);
// app.use('/product', Productrouter);
// app.use('/message', MessageRouter);
// app.use('/bookmark', BookmarkRouter);
app.get('/status', (req, res) => {
  res.status(200).json({ status: 'ok', message: '[ EXPRESS SERVER IS RUNNING ]'});
  console.log('[ EXPRESS SERVER IS RUNNING ]');
});

app.listen(process.env.Port);