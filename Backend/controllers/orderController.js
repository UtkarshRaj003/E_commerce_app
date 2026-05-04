const Order = require('../models/Order');
const Product = require('../models/Product');
const sendNotification = require('../services/notificationService');
const User = require('../models/User');



exports.createOrder = async (req, res, next) => {
  try {
    const {
      items,
      totalAmount,
      paymentMethod,
      shippingAddress,
      shippingCharge = 50,
      razorpayOrderId,
    } = req.body;

    const parsedTotalAmount = Number(totalAmount);
    const parsedShippingCharge = Number(shippingCharge);

    // ✅ BASIC VALIDATION
    if (
      !items ||
      !items.length ||
      Number.isNaN(parsedTotalAmount) ||
      !paymentMethod ||
      !shippingAddress
    ) {
      return res.status(400).json({
        message: 'Items, total amount, payment method and shipping address are required',
      });
    }

    // ✅ IMPORTANT: shippingAddress validation
    const {
      name,
      email,
      phone,
      address,
      city,
      state,
      pincode,
    } = shippingAddress;

    if (!name || !email || !phone || !address) {
      return res.status(400).json({
        message: 'Name, email, phone, and address are required',
      });
    }


    const itemsWithDetails = await Promise.all(
      items.map(async (item) => {
        const product = await Product.findById(item.productId);

        return {
          productId: product._id,
          name: item.name,
          image: item.image,
          quantity: item.quantity,
          price: product.price,
          variant: item.variant
        };
      })
    );

    // ✅ CREATE ORDER
    const order = await Order.create({
      userId: req.user._id,
      items: itemsWithDetails,
      totalAmount: parsedTotalAmount,
      shippingCharge: Number.isNaN(parsedShippingCharge)
        ? 50
        : parsedShippingCharge,
      paymentMethod,

      // 🔥 FULL OBJECT SAVE
      shippingAddress: {
        name,
        email,
        phone,
        address,
        city,
        state,
        pincode,
      },

      razorpayOrderId:
        paymentMethod === 'Razorpay' ? razorpayOrderId : undefined,

      paymentStatus: 'pending',
    });


    const user = await User.findById(req.user._id);
    await sendNotification(
      user,
      "Order Placed",
      "Your order is successful 🎉",
      "order"
    );

    res.status(201).json(order);
  } catch (error) {
    next(error);
  }
};

exports.getUserOrders = async (req, res, next) => {
  try {
    const orders = await Order.find({ userId: req.user._id }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    next(error);
  }
};

exports.getAllOrders = async (req, res, next) => {
  try {
    const orders = await Order.find().sort({ createdAt: -1 }).populate('userId', 'name email');
    res.json(orders);
  } catch (error) {
    next(error);
  }
};

exports.getOrderById = async (req, res, next) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('items.productId');

    const formattedOrder = {
      ...order._doc,
      items: order.items.map(item => ({
        productId: item.productId._id,
        name: item.productId.title,
        image: item.productId.images?.[0] || '',
        price: item.price,
        quantity: item.quantity,
        size: item.variant?.get('size'),
        color: item.variant?.get('color'),
      })),
    };

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // ✅ security check
    if (order.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    res.json(formattedOrder);
  } catch (error) {
    next(error);
  }
};

exports.updateOrderStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { orderStatus } = req.body;

    const order = await Order.findById(id);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    if (orderStatus) {
      order.orderStatus = orderStatus;
    }

    await order.save();
    res.json(order);
  } catch (error) {
    next(error);
  }
};
