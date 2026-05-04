const mongoose = require('mongoose');

const addressSchema = new mongoose.Schema({
  addressLine: String,
  city: String,
  state: String,
  pincode: String,
  isDefault: {
    type: Boolean,
    default: false,
  },
}, { _id: true });

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    phone: {
      type: String,
      trim: true,
    },
    password: {
      type: String,
      required: function () {
        return !this.googleId;
      },
    },
    googleId: {
      type: String,
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user',
    },
    // ✅ PROFILE IMAGE
    avatar: {
      type: String,
      default: '',
    },
    fcmToken: {
      type: String,
      default: null
    },

    // ✅ MULTIPLE ADDRESSES (max 3)
    addresses: {
      type: [addressSchema],
      default: [],
      validate: {
        validator: function (val) {
          return val.length <= 3;
        },
        message: 'Max 3 addresses allowed',
      },
    },
    wishlist: {
      type: [
        {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'Product',
        },
      ],
      default: [],
      validate: {
        validator: function (value) {
          if (!Array.isArray(value)) {
            return false;
          }
          const uniqueValues = new Set(value.map((id) => id.toString()));
          return uniqueValues.size === value.length;
        },
        message: 'Wishlist cannot contain duplicate products',
      },
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);
