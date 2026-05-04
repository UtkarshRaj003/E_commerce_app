const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    comment: {
      type: String,
      trim: true,
    },
  },
  { timestamps: true }
);

const productSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    price: {
      type: Number,
      required: true,
      min: 0,
    },
    categoryId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Category',
      required: true,
    },
    images: {
      type: [String],
      default: [],
    },
    variants: {
      type: [mongoose.Schema.Types.Mixed],
      default: [],
    },
    countInStock: {
      type: Number,
      default: 0,
      min: 0,
    },
    rating: {
      type: Number,
      default: 1,
      min: 1,
      max: 5,
    },
    numReviews: {
      type: Number,
      default: 0,
      min: 0,
    },
    reviews: {
      type: [reviewSchema],
      default: [],
    },
  },
  { timestamps: true }
);

// Indexes for query optimization
productSchema.index({ categoryId: 1 });
productSchema.index({ price: 1 });
productSchema.index({ title: 'text', description: 'text' });
productSchema.index({ rating: -1 });

module.exports = mongoose.models.Product || mongoose.model('Product', productSchema);
