const express = require('express');
const { protect } = require('../middleware/authMiddleware');

const {
  addToCart,
  updateCartItem,
  removeCartItem,
  getCart,
  clearCart,
} = require('../controllers/cartController');

const router = express.Router();

router.use(protect);

// root routes
router.route('/')
  .post(addToCart)
  .put(updateCartItem)
  .delete(removeCartItem)
  .get(getCart);

// separate route
router.delete('/clear', clearCart);

module.exports = router;