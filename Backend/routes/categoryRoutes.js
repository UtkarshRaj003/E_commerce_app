const express = require('express');
const { protect, admin } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');
const { createCategory, getCategories, updateCategory, deleteCategory } = require('../controllers/categoryController');

const router = express.Router();

router.route('/').get(getCategories).post(protect, admin, upload.single('image'), createCategory);

router.route('/:id')
    .put(protect, admin, upload.single('image'), updateCategory)
    .delete(protect, admin, deleteCategory);

module.exports = router;
