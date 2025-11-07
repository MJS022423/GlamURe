import dotenv from 'dotenv';
import jwt from 'jsonwebtoken';

dotenv.config();

const key = process.env.Secret_key;

export function generateKey(user_id) {
  return jwt.sign({ id: user_id }, key);
}

export function verifyToken(token) {
  try {
    return jwt.verify(token, key);
  } catch ( error ) {
    return null;
  }
}