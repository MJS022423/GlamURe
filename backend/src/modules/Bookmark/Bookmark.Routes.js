import express from 'express';
import Save from "./Bookmark.Save.js";
import Remove from "./Bookmark.Remove.js";
import Display from './Bookmark.Display.js';
import { authMiddleware } from '../../../middleware.js';


const BookmarkRouter = express.Router();

BookmarkRouter.post('/SaveBookmark', authMiddleware, Save);
BookmarkRouter.post('/RemoveBookmark', authMiddleware, Remove);
BookmarkRouter.get('/DisplayBookmark', authMiddleware, Display);

export default BookmarkRouter;