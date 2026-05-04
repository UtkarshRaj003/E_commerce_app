const User = require('../models/User');


exports.getProfile = async (req, res) => {
    const user = await User.findById(req.user._id).select('-password');
    res.json(user);
};


exports.updateProfile = async (req, res) => {
    const { name, phone } = req.body;

    const user = await User.findById(req.user._id);

    if (!user) return res.status(404).json({ message: 'User not found' });

    user.name = name || user.name;
    user.phone = phone || user.phone;

    await user.save();

    res.json(user);
};


exports.updateAvatar = async (req, res) => {
    const user = await User.findById(req.user._id);

    if (req.file) {
        user.avatar = `/uploads/${req.file.filename}`;
    }

    await user.save();

    res.json(user);
};


exports.addAddress = async (req, res) => {
    const user = await User.findById(req.user._id);

    if (user.addresses.length >= 3) {
        return res.status(400).json({ message: 'Max 3 addresses allowed' });
    }

    user.addresses.push(req.body);
    await user.save();

    res.json(user.addresses);
};


exports.updateAddress = async (req, res) => {
    const { addressId } = req.params;

    const user = await User.findById(req.user._id);

    const address = user.addresses.id(addressId);

    if (!address) return res.status(404).json({ message: 'Address not found' });

    Object.assign(address, req.body);

    await user.save();

    res.json(user.addresses);
};


exports.deleteAddress = async (req, res) => {
    const { addressId } = req.params;

    const user = await User.findById(req.user._id);

    user.addresses = user.addresses.filter(
        (addr) => addr._id.toString() !== addressId
    );

    await user.save();

    res.json(user.addresses);
};


exports.saveToken = async (req, res) => {
    const { token } = req.body;

    if (!token) {
        return res.status(400).json({ message: "Token required" });
    }

    req.user.fcmToken = token;
    await req.user.save();

    res.json({ success: true });
};


// ✅ ADMIN: Get All Users with Pagination
exports.getUsers = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const skip = (page - 1) * limit;

        const users = await User.find({})
            .select('-password') // Password nahi bhejna hai
            .skip(skip)
            .limit(limit)
            .sort({ createdAt: -1 });

        const total = await User.countDocuments({});

        res.json({
            users,
            page,
            pages: Math.ceil(total / limit),
            total
        });
    } catch (error) {
        res.status(500).json({ message: 'Server Error fetching users' });
    }
};