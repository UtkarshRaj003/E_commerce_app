const express = require('express');
const { storage } = require('../config/cloudinary');
const multer = require('multer');
const upload = multer({ storage: storage });
const { protect, admin } = require('../middleware/authMiddleware');
const {
  createProduct,
  updateProduct,
  deleteProduct,
  getAllProducts,
  getProductById,
} = require('../controllers/productController');

const router = express.Router();

router.route('/')
  .get(getAllProducts)
  .post(protect, admin, upload.array('images', 5), createProduct);

router.route('/:id')
  .get(getProductById)
  .put(protect, admin, upload.array('images', 5), updateProduct)
  .delete(protect, admin, deleteProduct);

module.exports = router;
