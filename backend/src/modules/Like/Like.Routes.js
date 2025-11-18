import express from 'express';
import { authMiddleware } from '../../../middleware.js';
import Toggle from './Like.Toggle.js';

const router = express.Router();

router.post('/ToggleLike', authMiddleware, Toggle);

export default router;
