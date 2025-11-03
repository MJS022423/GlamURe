import express from 'express';
import DisplayNotif from './Notification.Display';

const Notifrouter = express.Router();

Notifrouter.get('/notification', DisplayNotif);