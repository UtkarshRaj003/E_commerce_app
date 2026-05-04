const Category = require('../models/Category');

const escapeRegExp = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

exports.createCategory = async (req, res, next) => {
  try {
    const { name } = req.body;
    const image = req.file ? `/uploads/${req.file.filename}` : req.body.image;

    if (!name || !name.trim()) {
      return res.status(400).json({ message: 'Category name is required' });
    }

    const normalizedName = name.trim();
    const existing = await Category.findOne({
      name: { $regex: `^${escapeRegExp(normalizedName)}$`, $options: 'i' },
    });

    if (existing) {
      return res.status(400).json({ message: 'Category already exists' });
    }

    const category = await Category.create({ name: normalizedName, image });
    res.status(201).json(category);
  } catch (error) {
    next(error);
  }
};

exports.getCategories = async (req, res, next) => {
  try {
    const categories = await Category.find().sort({ createdAt: -1 });
    res.json(categories);
  } catch (error) {
    next(error);
  }
};



// ✅ UPDATE CATEGORY (Admin)
exports.updateCategory = async (req, res, next) => {
  try {
    const { name } = req.body;
    let category = await Category.findById(req.params.id);

    if (!category) {
      return res.status(404).json({ message: 'Category not found' });
    }

    if (name) {
      const normalizedName = name.trim();
      // Check agar kisi aur category ka same naam toh nahi hai
      const existing = await Category.findOne({
        name: { $regex: `^${escapeRegExp(normalizedName)}$`, $options: 'i' },
        _id: { $ne: category._id }
      });

      if (existing) {
        return res.status(400).json({ message: 'Category name already exists' });
      }
      category.name = normalizedName;
    }

    if (req.file) {
      category.image = `/uploads/${req.file.filename}`;
    } else if (req.body.image) {
      category.image = req.body.image; // Keep existing image if URL passed
    }

    const updatedCategory = await category.save();
    res.json(updatedCategory);
  } catch (error) {
    next(error);
  }
};

// ✅ DELETE CATEGORY (Admin)
exports.deleteCategory = async (req, res, next) => {
  try {
    const category = await Category.findById(req.params.id);

    if (!category) {
      return res.status(404).json({ message: 'Category not found' });
    }

    // Optional: Yahan aap check kar sakte ho ki agar is category ke products hain, 
    // toh pehle unhe delete karo ya error do.

    await category.deleteOne();
    res.json({ message: 'Category deleted successfully' });
  } catch (error) {
    next(error);
  }
};
