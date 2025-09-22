const express = require("express");
const router = express.Router();
const User = require("../models/User");

// CREATE - Add a new user
router.post("/", async (req, res) => {
  try {
    const { name, email, age, city, phone } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res
        .status(400)
        .json({ error: "User with this email already exists" });
    }

    const user = new User({
      name,
      email,
      age,
      city,
      phone,
    });

    const savedUser = await user.save();
    res.status(201).json({
      message: "User created successfully",
      user: savedUser,
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// READ - Get all users
router.get("/", async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const users = await User.find()
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    const total = await User.countDocuments();

    res.json({
      users,
      currentPage: page,
      totalPages: Math.ceil(total / limit),
      totalUsers: total,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// READ - Get a single user by ID
router.get("/:id", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// UPDATE - Update a user
router.put("/:id", async (req, res) => {
  try {
    const { name, email, age, city, phone } = req.body;

    // Check if email is being changed and if it already exists
    if (email) {
      const existingUser = await User.findOne({
        email,
        _id: { $ne: req.params.id },
      });
      if (existingUser) {
        return res
          .status(400)
          .json({ error: "User with this email already exists" });
      }
    }

    const user = await User.findByIdAndUpdate(
      req.params.id,
      {
        name,
        email,
        age,
        city,
        phone,
      },
      {
        new: true,
        runValidators: true,
      }
    );

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json({
      message: "User updated successfully",
      user,
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// DELETE - Delete a user
router.delete("/:id", async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }
    res.json({
      message: "User deleted successfully",
      user,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// SEARCH - Search users by name or email
router.get("/search/:query", async (req, res) => {
  try {
    const query = req.params.query;
    const users = await User.find({
      $or: [
        { name: { $regex: query, $options: "i" } },
        { email: { $regex: query, $options: "i" } },
      ],
    }).sort({ createdAt: -1 });

    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
