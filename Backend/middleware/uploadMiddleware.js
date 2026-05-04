const multer = require('multer');
const path = require('path');
const sharp = require('sharp');
const fs = require('fs');

const uploadsDir = path.join(__dirname, '..', 'uploads');

// Ensure uploads directory exists
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination(req, file, cb) {
    cb(null, uploadsDir);
  },
  filename(req, file, cb) {
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    const extension = path.extname(file.originalname);
    cb(null, `${file.fieldname}-${uniqueSuffix}${extension}`);
  },
});

const fileFilter = (req, file, cb) => {
  const allowed = ['.jpg', '.jpeg', '.png', '.webp'];
  const ext = path.extname(file.originalname).toLowerCase();

  if (allowed.includes(ext)) {
    cb(null, true);
  } else {
    cb(new Error('Only images allowed'), false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
});

// Image optimization middleware
const optimizeImage = async (req, res, next) => {
  if (!req.files || req.files.length === 0) {
    return next();
  }

  try {
    for (const file of req.files) {
      const filePath = file.path;
      const optimizedFilename = `optimized-${file.filename}`;
      const optimizedPath = path.join(uploadsDir, optimizedFilename);

      await sharp(filePath)
        .resize(800, 800, {
          fit: 'inside',
          withoutEnlargement: true,
        })
        .jpeg({ quality: 70 })
        .png({ compressionLevel: 9 })
        .toFile(optimizedPath);

      fs.unlinkSync(filePath);
      file.filename = optimizedFilename;
      file.path = optimizedPath;
    }

    next();
  } catch (error) {
    console.error('Image optimization error:', error);
    next(error);
  }
};

module.exports = upload;
