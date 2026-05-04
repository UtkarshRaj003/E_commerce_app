const Product = require('../models/Product');
const Category = require('../models/Category');
const sharp = require('sharp');
const path = require('path');
const fs = require('fs');
const User = require('../models/User');
const admin = require('../config/firebase');
const sendNotification = require('../services/notificationService');

const parseVariants = (variants) => {
  if (!variants) return [];
  if (typeof variants === 'string') {
    try {
      return JSON.parse(variants);
    } catch (error) {
      return [];
    }
  }
  return variants;
};

// ✅ BUG 1 + 5 FIX: sharp mein .jpeg() aur .png() dono ek saath nahi lagate.
// Extension ke hisaab se sirf ek format use karo.
// Agar optimize fail ho toh original file use karo — crash mat karo.
const optimizeImages = async (files) => {
  if (!files || files.length === 0) return files;

  const uploadsDir = path.join(__dirname, '..', 'uploads');

  for (const file of files) {
    try {
      const ext = path.extname(file.originalname).toLowerCase();
      const isPng = ext === '.png';
      const optimizedFilename = `optimized-${file.filename}`;
      const optimizedPath = path.join(uploadsDir, optimizedFilename);

      const pipeline = sharp(file.path).resize(800, 800, {
        fit: 'inside',
        withoutEnlargement: true,
      });

      // ✅ Sirf ek format — png ke liye png, baaki ke liye jpeg
      if (isPng) {
        await pipeline.png({ compressionLevel: 8 }).toFile(optimizedPath);
      } else {
        await pipeline.jpeg({ quality: 75 }).toFile(optimizedPath);
      }

      // Original file delete karo sirf tab jab optimized ban jaaye
      if (fs.existsSync(optimizedPath)) {
        fs.unlinkSync(file.path);
        file.filename = optimizedFilename;
        file.path = optimizedPath;
      }
    } catch (error) {
      // ✅ Optimization fail ho toh original file use karo, crash mat karo
      console.error('Image optimization error for', file.filename, ':', error.message);
    }
  }

  return files;
};

exports.createProduct = async (req, res, next) => {
  try {
    const { title, description, price, categoryId, variants } = req.body;
    const parsedPrice = price != null ? Number(price) : null;
    const parsedVariants = parseVariants(variants);

    if (
      !title?.trim() ||
      categoryId == null ||
      parsedPrice == null ||
      Number.isNaN(parsedPrice)
    ) {
      return res
        .status(400)
        .json({ message: 'Title, price and category are required' });
    }

    const category = await Category.findById(categoryId);
    if (!category) {
      return res.status(404).json({ message: 'Category not found' });
    }

    if (req.files && req.files.length > 0) {
      await optimizeImages(req.files);
    }

    const images = req.files
      ? req.files.map((file) => `/uploads/${file.filename}`)
      : [];

    const product = await Product.create({
      title: title.trim(),
      description: description?.trim(),
      price: parsedPrice,
      categoryId,
      images,
      variants: parsedVariants,
    });

    // FCM notification — failure yahan app ko rok na sake
    try {
      const users = await User.find({ fcmToken: { $ne: null } });
      const tokens = users.map((u) => u.fcmToken).filter(Boolean);

      if (tokens.length > 0) {
        const response = await admin.messaging().sendEachForMulticast({
          tokens,
          notification: { title: 'New Product', body: `${product.title} is now available! 🔥` },
          data: { type: 'promo' },
        });
        console.log(`FCM: ${response.successCount} success, ${response.failureCount} failed`);
      }
    } catch (fcmError) {
      // FCM fail ho toh product create toh ho gaya, sirf log karo
      console.error('FCM notification error:', fcmError.message);
    }

    res.status(201).json(product);
  } catch (error) {
    next(error);
  }
};

exports.updateProduct = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { title, description, price, categoryId, variants, existingImages } =
      req.body;

    const product = await Product.findById(id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    // ✅ BUG 2 FIX: pehle wala code mein `else return product.images` tha
    // jo response kabhi nahi bhejta tha — app hang ho jaata tha.
    // Ab: existingImages aaye toh use karo, nahi aaye toh purani images rakho.
    if (existingImages !== undefined && existingImages !== null) {
      product.images =
        typeof existingImages === 'string'
          ? JSON.parse(existingImages)
          : existingImages;
    }
    // agar existingImages nahi aaya — product.images unchanged rehta hai

    if (categoryId) {
      const category = await Category.findById(categoryId);
      if (!category) {
        return res.status(404).json({ message: 'Category not found' });
      }
      product.categoryId = categoryId;
    }

    if (req.files && req.files.length > 0) {
      await optimizeImages(req.files);
      const newImages = req.files.map((file) => `/uploads/${file.filename}`);
      product.images = [...product.images, ...newImages];
    }

    if (title?.trim()) product.title = title.trim();
    if (description != null) product.description = description.trim();

    if (price != null) {
      const parsedPrice = Number(price);
      if (Number.isNaN(parsedPrice)) {
        return res
          .status(400)
          .json({ message: 'Price must be a valid number' });
      }
      product.price = parsedPrice;
    }

    if (variants != null) {
      product.variants = parseVariants(variants);
    }

    const updatedProduct = await product.save();
    res.json(updatedProduct);
  } catch (error) {
    next(error);
  }
};

exports.deleteProduct = async (req, res, next) => {
  try {
    const { id } = req.params;
    const product = await Product.findById(id);

    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    // ✅ Image files delete karo — error aaye toh sirf log karo
    product.images.forEach((img) => {
      try {
        const filePath = path.join(__dirname, '..', img);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      } catch (fileErr) {
        console.error('File delete error:', fileErr.message);
      }
    });

    await Product.deleteOne({ _id: id });
    res.json({ message: 'Product removed successfully' });
  } catch (error) {
    next(error);
  }
};

exports.getAllProducts = async (req, res, next) => {
  try {
    const page = Math.max(1, Number(req.query.page) || 1);
    const limit = Math.min(20, Math.max(1, Number(req.query.limit) || 12));

    const filter = {};

    if (req.query.search) {
      filter.$text = { $search: req.query.search };
    }
    if (req.query.categoryId) {
      filter.categoryId = req.query.categoryId;
    }
    if (req.query.minPrice || req.query.maxPrice) {
      filter.price = {};
      if (req.query.minPrice) filter.price.$gte = Number(req.query.minPrice);
      if (req.query.maxPrice) filter.price.$lte = Number(req.query.maxPrice);
    }
    if (req.query.rating) {
      filter.rating = { $gte: Number(req.query.rating) };
    }

    const count = await Product.countDocuments(filter);

    const products = await Product.find(filter)
      .populate('categoryId', 'name')
      .skip(limit * (page - 1))
      .limit(limit)
      .sort(
        req.query.search ? { score: { $meta: 'textScore' } } : { createdAt: -1 }
      )
      .lean();

    res.json({
      products,
      page,
      pages: Math.ceil(count / limit),
      total: count,
    });
  } catch (error) {
    next(error);
  }
};

exports.getProductById = async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.id).populate(
      'categoryId',
      'name'
    );

    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    res.json(product);
  } catch (error) {
    next(error);
  }
};