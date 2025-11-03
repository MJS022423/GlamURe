import express from 'experss';
import AddProduct from './Post.Add';
import RemoveProduct from './Post.Remove';
import DisplayProduct from './Post.Display';

const Productrouter = express.Router();

Productrouter.post('/AddProduct', AddProduct);
Productrouter.post('/RemoveProduct', RemoveProduct);
Productrouter.get('/DisplayProduct', DisplayProduct)

export default Productrouter;