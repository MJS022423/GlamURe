import express from 'express';

const router = express.Router();

router.get('/status', (req, res) => {
  res.status(200).json({ status: 'ok', message: '[ EXPRESS SERVER IS RUNNING ]'});
  console.log('[ EXPRESS SERVER IS RUNNING ]');
});