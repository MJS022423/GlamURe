import express from 'express';
import Display from './Leaderboard.Display';

const LeaderboardRouter = express.Router();

LeaderboardRouter.get('/notification', Display);

export default LeaderboardRouter;