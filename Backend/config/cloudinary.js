const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');

// Configuration
cloudinary.config({
  cloud_name: process.env.CLOUD_NAME,
  api_key: process.env.CLOUD_API_KEY,
  api_secret: process.env.CLOUD_API_SECRET
});

// Storage Logic
const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'cartify_uploads', // Cloudinary pe is naam ka folder apne aap ban jayega
    allowed_formats: ['jpg', 'png', 'jpeg'],
    // Optional: Aap image resize bhi kar sakte ho upload ke waqt hi
    transformation: [{ width: 1000, height: 1000, crop: 'limit' }] 
  },
});

module.exports = { cloudinary, storage };