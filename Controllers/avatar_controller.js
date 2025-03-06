const multer = require('multer');
const path = require('path');
const User = require('./../Models/user_model'); // Import the User model

// Configure multer to save uploaded files
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, './uploads/avatars'); // Folder where avatars will be stored
  },
  filename: (req, file, cb) => {
    // Use timestamp and original filename to create unique file names
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage });

// Avatar upload logic
const uploadAvatar = upload.single('avatar'); // Expect 'avatar' in form-data

// Controller method to handle avatar upload
const createAvatarForUser = async (req, res) => {
  // Check if the request has a file
  if (!req.file) {
    return res.status(400).json({ message: 'No avatar uploaded' });
  }

  // Path to the saved avatar file
  const avatarPath = `/uploads/avatars/${req.file.filename}`;

  // Get the email from the request body
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'Email is required' });
  }

  try {
    // Find the user by email, create if not exists
    let user = await User.findOne({ email });

    if (!user) {
      // Create a new user if not found (you can customize this part if necessary)
      user = new User({
        email: email,
        avatar: avatarPath, // Add the avatar to the new user's model
      });

      // Save the new user to the database
      await user.save();
    } else {
      // If user exists, just create the avatar field for them
      user.avatar = avatarPath;
      await user.save();
    }

    res.status(200).json({
      message: 'Avatar created and assigned successfully',
      user: {
        email: user.email,
        avatar: user.avatar, // Avatar path assigned to user
      },
    });
  } catch (error) {
    console.error('Error creating avatar for user:', error);
    res.status(500).json({ message: 'Error creating avatar for user' });
  }
};

module.exports = {
  uploadAvatar,
  createAvatarForUser,
};
