import express from 'express';
import Login from './Auth.Login.js';
import Register from './Auth.Register.js';
import SetupAccount from './Auth.SetupAccount.js';

const Authrouter = express.Router();

Authrouter.post('/Login', Login);
Authrouter.post('/Register', Register);
Authrouter.post('/SetupAccount', SetupAccount);

export default Authrouter;
