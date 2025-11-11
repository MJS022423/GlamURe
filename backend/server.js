import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import Authrouter from './src/modules/Auth/Auth.Routes.js';
import Postrouter from './src/modules/Post/Post.Routes.js';
import BookmarkRouter from './src/modules/Bookmark/Bookmark.Routes.js'
//import CommentRouter from './src/modules/Comment/Comment.Route.js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();

// Configure CORS
app.use(cors({
  origin: 'http://localhost:5173',
  credentials: true
}));

// Configure json
app.use(express.json());

// Configure rate limiting
const limiter = rateLimit({
  windowMs: 30 * 60 * 1000,
  limit: 100,
  standardHeaders: true,
  legacyHeaders: false
});

app.use(limiter);
app.use(cors());

app.use('/auth', Authrouter);
app.use('/post', Postrouter);
app.use('/bookmark', BookmarkRouter);
//app.use('/comment', CommentRouter);

app.get('/status', (req, res) => {
  res.status(200).json({ status: 'ok', message: '[ EXPRESS SERVER IS RUNNING ]'});
  console.log('[ EXPRESS SERVER IS RUNNING ]');
});

app.listen(process.env.Port);