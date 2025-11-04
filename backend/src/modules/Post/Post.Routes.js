import express from 'express';
import AddProduct from './Post.Add.js';
import RemoveProduct from './Post.Remove.js';
import DisplayProduct from './Post.Display.js';

const Productrouter = express.Router();

Productrouter.post('/AddProduct', AddProduct);
Productrouter.post('/RemoveProduct', RemoveProduct);
Productrouter.get('/DisplayProduct', DisplayProduct)

export default Productrouter;