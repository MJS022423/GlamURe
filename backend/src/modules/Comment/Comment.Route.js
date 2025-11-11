import Add from "./Comment.Add.js";
import Remove from "./Comment.Remove.js";
import Display from "./Comment.Display.js";
import { authMiddleware } from "../../../middleware.js";
import express from 'express';

const CommentRouter = express.Router();

CommentRouter.post('/Addcomment', authMiddleware, Add);
CommentRouter.post('/Removecomment', authMiddleware, Remove);
CommentRouter.get('/Displaycomment', authMiddleware, Display);

export default CommentRouter;