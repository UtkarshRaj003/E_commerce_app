const express = require('express');
const { protect, admin } = require('../middleware/authMiddleware');
const {
  createOrder,
  getUserOrders,
  getAllOrders,
  updateOrderStatus,
  getOrderById,
} = require('../controllers/orderController');

const router = express.Router();

router.use(protect);
router.post('/', createOrder);
router.get('/my-orders', getUserOrders);
router.get('/all', admin, getAllOrders);
router.get('/:id', getOrderById);
router.put('/:id/status', admin, updateOrderStatus);

module.exports = router;
