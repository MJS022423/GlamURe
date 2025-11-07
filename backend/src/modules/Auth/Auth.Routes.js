import express from 'express';
import Login from './Auth.Login.js';
import Register from './Auth.Register.js';
import Delete from './Auth.Delete.js';
import { authMiddleware } from '../../../middleware.js';
import { UpdateUsername, UpdateProfile, UpdatePassword } from './Auth.Changes.js';

const Authrouter = express.Router();

Authrouter.post('/Login', Login);
Authrouter.post('/Register', Register);
Authrouter.post('/UpdateProfile', authMiddleware, UpdateProfile);
Authrouter.post('/UpdateUser', authMiddleware, UpdateUsername);
Authrouter.post('/UpdatePass', authMiddleware, UpdatePassword);
Authrouter.post('/DeleteAccount', authMiddleware, Delete);

export default Authrouter;
