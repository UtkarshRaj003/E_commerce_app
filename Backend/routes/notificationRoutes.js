const express = require('express');
const router = express.Router();
const Notification = require('../models/notification');
const { protect } = require('../middleware/authMiddleware');

// ✅ FIXED: was '/notifications' — but this file is mounted at '/api/notifications'
// so the paths here must be '/' and '/:id', NOT '/notifications' and '/notifications/:id'

// GET /api/notifications
router.get('/', protect, async (req, res) => {
  try {
    const notifs = await Notification.find({ user: req.user._id })
      .sort({ createdAt: -1 });
    res.json(notifs);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// PUT /api/notifications/:id
router.put('/:id', protect, async (req, res) => {
  try {
    await Notification.findOneAndUpdate(
      { _id: req.params.id, user: req.user._id },
      { isRead: true }
    );
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;