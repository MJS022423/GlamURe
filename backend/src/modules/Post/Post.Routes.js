import multer from 'multer';
import express from 'express';
import AddPost from './Post.Add.js';
import RemovePost from './Post.Remove.js';
import DisplayPost from './Post.Display.js';
import { authMiddleware } from '../../../middleware.js';

const Postrouter = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage });

Postrouter.post('/Addpost', authMiddleware, upload.array("images"), AddPost);
Postrouter.post('/Removepost', authMiddleware, RemovePost);
Postrouter.get('/Displaypost', DisplayPost);

export default Postrouter;