const express = require('express');
const { protect, admin } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

const {
  getProfile,
  updateProfile,
  updateAvatar,
  addAddress,
  updateAddress,
  deleteAddress,
  saveToken,
  getUsers
} = require('../controllers/userController');

const router = express.Router();

router.use(protect);

router.get('/', admin, getUsers);
router.get('/profile', getProfile);
router.put('/profile', updateProfile);
router.put('/avatar', upload.single('avatar'), updateAvatar);
router.post('/save-token', saveToken);

router.post('/address', addAddress);
router.put('/address/:addressId', updateAddress);
router.delete('/address/:addressId', deleteAddress);
router.get('/users', admin, getUsers);
module.exports = router; 