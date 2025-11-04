import express from 'express';
import Save from "./Bookmark.Add.js";
import RemoveSave from "./Bookmark.Remove.js";

const BookmarkRouter = express.Router();

BookmarkRouter.post('/Save', Save);
BookmarkRouter.post('/Removesave', RemoveSave);

export default BookmarkRouter;