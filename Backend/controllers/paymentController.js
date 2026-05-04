const Razorpay = require('razorpay');
const crypto = require('crypto');
const Order = require('../models/Order');

const razorpayKeyId = process.env.RAZORPAY_KEY_ID;
const razorpayKeySecret = process.env.RAZORPAY_KEY_SECRET;
if (!razorpayKeyId || !razorpayKeySecret) {
  throw new Error('Razorpay credentials are required');
}

const razorpayClient = new Razorpay({
  key_id: razorpayKeyId,
  key_secret: razorpayKeySecret,
});

exports.createRazorpayOrder = async (req, res, next) => {
  try {
    const { items, totalAmount, shippingCharge = 50 } = req.body;

    const parsedTotalAmount = Number(totalAmount);
    const parsedShippingCharge = Number(shippingCharge);

    if (!items || !items.length || Number.isNaN(parsedTotalAmount)) {
      return res.status(400).json({ message: 'Items and total amount are required' });
    }

    if (parsedTotalAmount > 500000) {
      return res.status(400).json({
        message: 'Amount too large. Max allowed is ₹5,00,000',
      });
    }

    const amountInPaise = Math.round(
      (parsedTotalAmount + (Number.isNaN(parsedShippingCharge) ? 50 : parsedShippingCharge)) * 100
    );

    const razorpayOrder = await razorpayClient.orders.create({
      amount: amountInPaise,
      currency: 'INR',
      receipt: `receipt_${Date.now()}`,
    });


    res.status(200).json({
      razorpayOrderId: razorpayOrder.id,
      amount: razorpayOrder.amount,
      currency: razorpayOrder.currency,
    });

  } catch (error) {
    next(error);
  }
};

exports.verifyRazorpayPayment = async (req, res, next) => {
  try {
    const { orderId, razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;
    if (!orderId || !razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({ message: 'Payment validation parameters are required' });
    }

    const generatedSignature = crypto
      .createHmac('sha256', razorpayKeySecret)
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');

    if (generatedSignature !== razorpay_signature) {
      return res.status(400).json({ message: 'Payment verification failed' });
    }
    // // TEMPORARY TEST MODE
    // console.log("Generated:", generatedSignature);
    // console.log("Received:", razorpay_signature);

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    order.paymentStatus = 'paid';
    order.razorpayPaymentId = razorpay_payment_id;
    order.orderStatus = 'processing';
    await order.save();

    res.json({ message: 'Payment verified successfully', order });
  } catch (error) {
    next(error);
  }
};
