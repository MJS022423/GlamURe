import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import Authrouter from './src/modules/Auth/Auth.Routes.js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

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
// app.use('/product', Productrouter);
// app.use('/message', MessageRouter);
// app.use('/bookmark', BookmarkRouter);
app.get('/status', (req, res) => {
  res.status(200).json({ status: 'ok', message: '[ EXPRESS SERVER IS RUNNING ]'});
  console.log('[ EXPRESS SERVER IS RUNNING ]');
});

app.listen(process.env.Port);