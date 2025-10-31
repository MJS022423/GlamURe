import express from 'experss';
import AddProduct from './Product.Add';
import RemoveProduct from './Produect.Remove';

const Productrouter = express.Router();

Productrouter.post('/AddProduct', AddProduct);
Productrouter.post('/RemoveProduct', RemoveProduct);

export default Productrouter;