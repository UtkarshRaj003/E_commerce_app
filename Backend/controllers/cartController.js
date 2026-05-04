const Cart = require('../models/Cart');
const sendNotification = require('../services/notificationService');
const User = require('../models/User');

// Safe variant comparison - handles undefined values
const isSameVariant = (a = {}, b = {}) => {
  return a.size === b.size && a.color === b.color;
};

// Compare cart item by productId and variant
const isSameCartItem = (item, productId, selectedVariant) => {
  return (
    item.productId.toString() === productId.toString() &&
    isSameVariant(item.selectedVariant, selectedVariant)
  );
};

exports.addToCart = async (req, res, next) => {
  try {
    const { productId, quantity = 1, selectedVariant = {} } = req.body;

    // Validation
    if (!productId) {
      return res.status(400).json({ message: 'Product ID is required' });
    }

    const normalizedQuantity = Number(quantity) || 1;
    const normalizedVariant = {
      size: selectedVariant?.size || '',
      color: selectedVariant?.color || '',
    };

    // Debug logs
    console.log('Incoming:', productId, normalizedVariant);

    let cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      cart = await Cart.create({ userId: req.user._id, items: [] });
    }

    console.log('Cart items:', cart.items.length);

    // Find existing item - if exists, increase quantity
    const existingItem = cart.items.find((item) =>
      isSameCartItem(item, productId, normalizedVariant)
    );

    if (existingItem) {
      existingItem.quantity += normalizedQuantity;
      console.log('Updated existing item quantity:', existingItem.quantity);
    } else {
      // Push new item only if no duplicate exists
      cart.items.push({
        productId,
        quantity: normalizedQuantity,
        selectedVariant: normalizedVariant,
      });
      console.log('Added new item to cart');
    }

    await cart.save();

    // Return populated cart
    const populatedCart = await Cart.findById(cart._id).populate('items.productId');


    const user = await User.findById(req.user._id);
    await sendNotification(
      user,
      "Cart Updated",
      "Item added to cart 🛒",
      "cart"
    );
    res.status(200).json(populatedCart);
  } catch (error) {
    next(error);
  }
};

exports.updateCartItem = async (req, res, next) => {
  try {
    const { productId, selectedVariant = {}, quantity } = req.body;

    // Validation
    if (!productId || quantity === undefined) {
      return res.status(400).json({ message: 'Product ID and quantity are required' });
    }

    const normalizedQuantity = Number(quantity);
    const normalizedVariant = {
      size: selectedVariant?.size || '',
      color: selectedVariant?.color || '',
    };

    // Debug logs
    console.log('Update request:', productId, normalizedVariant, normalizedQuantity);

    const cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      return res.status(404).json({ message: 'Cart not found' });
    }

    // Find item using isSameCartItem
    const item = cart.items.find((cartItem) =>
      isSameCartItem(cartItem, productId, normalizedVariant)
    );

    if (!item) {
      return res.status(404).json({ message: 'Cart item not found' });
    }

    // Update quantity
    item.quantity = normalizedQuantity;

    // If quantity <= 0, remove item
    if (item.quantity <= 0) {
      cart.items = cart.items.filter(
        (cartItem) => !isSameCartItem(cartItem, productId, normalizedVariant)
      );
      console.log('Removed item due to zero/negative quantity');
    }

    await cart.save();

    // Return populated cart
    const populatedCart = await Cart.findById(cart._id).populate('items.productId');
    res.json(populatedCart);
  } catch (error) {
    next(error);
  }
};

exports.removeCartItem = async (req, res, next) => {
  try {
    const { productId, selectedVariant = {} } = req.body;

    // Validation
    if (!productId) {
      return res.status(400).json({ message: 'Product ID is required' });
    }

    const normalizedVariant = {
      size: selectedVariant?.size || '',
      color: selectedVariant?.color || '',
    };

    // Debug logs
    console.log('Remove request:', productId, normalizedVariant);

    const cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      return res.status(404).json({ message: 'Cart not found' });
    }

    // Remove item using isSameCartItem - removes only exact variant match
    const initialLength = cart.items.length;
    cart.items = cart.items.filter(
      (item) => !isSameCartItem(item, productId, normalizedVariant)
    );

    console.log('Items removed:', initialLength - cart.items.length);

    await cart.save();

    // Return populated cart
    const populatedCart = await Cart.findById(cart._id).populate('items.productId');
    res.json(populatedCart);
  } catch (error) {
    next(error);
  }
};


exports.clearCart = async (req, res, next) => {
  try {
    const cart = await Cart.findOne({ userId: req.user._id });

    if (!cart) {
      return res.status(404).json({ message: 'Cart not found' });
    }


    cart.items = [];
    await cart.save();

    res.json({ message: 'Cart cleared successfully' });
  } catch (error) {
    next(error);
  }
};

exports.getCart = async (req, res, next) => {
  try {
    const cart = await Cart.findOne({ userId: req.user._id }).populate('items.productId');
    if (!cart) {
      return res.status(200).json({ items: [] });
    }

    res.json(cart);
  } catch (error) {
    next(error);
  }
};
