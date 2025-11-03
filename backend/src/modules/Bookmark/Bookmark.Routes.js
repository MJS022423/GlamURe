import express from 'express';
import Save from "./Bookmark.Add";
import RemoveSave from "./Bookmark.Remove";

const BookmarkRouter = express.Router();

BookmarkRouter.post('/Save', Save);
BookmarkRouter.post('/Removesave', RemoveSave);

export default BookmarkRouter;