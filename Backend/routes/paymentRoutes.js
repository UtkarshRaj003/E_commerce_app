const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  createRazorpayOrder,
  verifyRazorpayPayment,
} = require('../controllers/paymentController');

const router = express.Router();

router.use(protect);
router.post('/order', createRazorpayOrder);
router.post('/verify', verifyRazorpayPayment);

module.exports = router;
