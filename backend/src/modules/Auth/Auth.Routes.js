import express from 'express';
import Register from './Auth.Register';
import Login from './Auth.Login';

const Authrouter = express.Router();

Authrouter.post('/Login', Login);
Authrouter.post('/Register', Register);

export default Authrouter;
