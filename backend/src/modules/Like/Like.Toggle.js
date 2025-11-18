import Database from '../modules.connection.js';
import { ObjectId } from 'mongodb';

const Toggle = async (req, res) => {
  try {
    const { postId } = req.query;
    const userId = req.userId;

    if (!postId) {
      return res.status(400).json({ success: false, error: 'Post ID is required' });
    }

    const dbInstance = new Database();
    const db = await dbInstance.Connection();
    const postsCollection = db.collection('posts');
    const likesCollection = db.collection('likes');

    // Check if the user has already liked the post
    const existingLike = await likesCollection.findOne({ postId: new ObjectId(postId), userId: new ObjectId(userId) });

    let newLikesCount;
    if (existingLike) {
      // Unlike: Remove the like
      await likesCollection.deleteOne({ postId: new ObjectId(postId), userId: new ObjectId(userId) });
      // Decrement likes count
      await postsCollection.updateOne(
        { _id: new ObjectId(postId) },
        { $inc: { likes: -1 } }
      );
      newLikesCount = (await postsCollection.findOne({ _id: new ObjectId(postId) })).likes;
    } else {
      // Like: Add the like
      await likesCollection.insertOne({ postId: new ObjectId(postId), userId: new ObjectId(userId), createdAt: new Date() });
      // Increment likes count
      await postsCollection.updateOne(
        { _id: new ObjectId(postId) },
        { $inc: { likes: 1 } }
      );
      newLikesCount = (await postsCollection.findOne({ _id: new ObjectId(postId) })).likes;
    }

    res.status(200).json({ success: true, likes: newLikesCount });
  } catch (error) {
    console.error('Error toggling like:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
};

export default Toggle;
