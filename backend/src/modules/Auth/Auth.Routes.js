import express from 'express';
import Login from './Auth.Login.js';
import Register from './Auth.Register.js';
import Logout from './Auth.Logout.js';
import Delete from './Auth.Delete.js';
import { authMiddleware } from '../../../middleware.js';
import { UpdateProfile, UpdatePassword } from './Auth.Changes.js';
import SetupAccount from './Auth.SetupAccount.js';

const Authrouter = express.Router();

Authrouter.post('/Login', Login);
Authrouter.post('/Register', Register);
Authrouter.post('/Logout', authMiddleware, Logout);
Authrouter.post('/UpdateProfile', authMiddleware, UpdateProfile);
Authrouter.post('/UpdatePass', authMiddleware, UpdatePassword);
Authrouter.post('/DeleteAccount', authMiddleware, Delete);
Authrouter.post('/SetupAccount', SetupAccount);

export default Authrouter;
