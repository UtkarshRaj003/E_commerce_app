const User = require('../models/User');
const sendNotification = require('../services/notificationService');

exports.toggleWishlist = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const { productId } = req.body;
    if (!productId) {
      return res.status(400).json({ message: 'Product ID is required' });
    }

    const index = user.wishlist.findIndex((id) => id.equals(productId));

    if (index >= 0) {
      // ❌ REMOVE CASE
      user.wishlist.splice(index, 1);
    } else {
      // ✅ ADD CASE
      user.wishlist.push(productId);

      await sendNotification(
        user,
        "Wishlist",
        "Item added to wishlist ❤️",
        "wishlist"
      );
    }

    await user.save();

    const updatedUser = await User.findById(user._id).populate('wishlist');

    res.json({ wishlist: updatedUser.wishlist });

  } catch (error) {
    next(error);
  }
};

exports.getWishlist = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).populate('wishlist');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ wishlist: user.wishlist });
  } catch (error) {
    next(error);
  }
};
