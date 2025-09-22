const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Name is required"],
      trim: true,
      minlength: [2, "Name must be at least 2 characters long"],
      maxlength: [50, "Name cannot exceed 50 characters"],
    },
    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      lowercase: true,
      trim: true,
      match: [
        /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/,
        "Please enter a valid email",
      ],
    },
    age: {
      type: Number,
      min: [1, "Age must be at least 1"],
      max: [150, "Age cannot exceed 150"],
    },
    city: {
      type: String,
      trim: true,
      maxlength: [100, "City name cannot exceed 100 characters"],
    },
    phone: {
      type: String,
      trim: true,
      match: [/^[0-9-+\s()]+$/, "Please enter a valid phone number"],
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("User", userSchema);
