const User = require('../Models/user_model');
const jwt = require('jsonwebtoken');
const CustomError = require('./../Utils/custom_error');
const util = require('util');
const sendEmail = require('./../Utils/email');
const crypto = require('crypto');
const async_error_handler = require('./../Utils/assync_error_handler');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
dotenv.config({path: './../.env'});

const signToken = id => {
    return jwt.sign({ id }, process.env.SECRET_JWT, {
        expiresIn: 86400000
    });
};

const createSendResponse = (user, statusCode, res) => {
    const token = jwt.sign({ id: user.id }, 'asg7-hnkenf-53jje7-63hnkk-72ggdjjd', {
        expiresIn: 86400000 // Token expires in 1 hour
    });
    const options = {
        maxAge: 86400000,
        httpOnly: true
    };

    if (process.env.NODE_ENV === 'production') {
        options.secure = true;
    }

    res.cookie('jwt', token, options);
    user.password = undefined;

    res.status(statusCode).json({
        status: "success",
        token,
        data: {
            user
        }
    });
};

exports.register = async_error_handler(async (req, res, next) => {
    const { email, password, confirmPassword} = req.body;
    if (password !== confirmPassword) {
        console.log('Password and confirmPassword do not match');
        req.flash('error_msg', 'Password and confirmPassword do not match');
    }
    try {
        // Check if user already exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            // If user exists, send a conflict response
            return res.status(409).json({ error: 'Account with this email already exists!' });
        }

        // Create new user in the database
        const newUser = await User.create({ email, password });

        console.log('User created successfully:', newUser);
        // Return success response to the client
        res.status(201).json({ message: 'Registration successful!' });
    } catch (err) {
        console.error('Error during signup:', err);
        // Return an error response if something went wrong
        res.status(500).json({ error: 'Something went wrong' });
    }
});


/*exports.signup = async_error_handler(async (req, res) => {
    try {
        const { name, email, password, confirmPassword} = req.body;

        if (password !== confirmPassword) {
            return res.status(400).json({ error: 'Password and confirmPassword do not match' });
        }

        // Create new user in the database
        const newUser = await User.create({ name, email, password});

        // Send success response
        res.status(201).json({ message: 'User created successfully', user: newUser });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Internal server error' });
    }
});*/


/*exports.login = async_error_handler(async (req, res, next) => {
    const { email, password } = req.body;

    // Check if email and password are provided
    if (!email || !password) {
        return next(new CustomError('Please provide email and password', 400));
    }

    // Check if user exists and password is correct
    const user = await User.findOne({ email }).select('+password');
    if (!user || !(await user.comparePasswordInDb(password, user.password))) {
        return next(new CustomError('Incorrect email or password', 401));
    }

    // Create token
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRES_IN,
    });

    // Send token in response
    res.status(200).json({
        status: 'success',
        token,
    });
});*/
exports.login = async_error_handler(async (req, res, next) => {
    const { email, password } = req.body;

    console.log('Login request received:', { email, password });

    // Find user with email
    const user = await User.findOne({ email }).select('+password +active');
    console.log('User retrieved:', user);

    if (!user) {
        console.log('User not found with email:', email);
        return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Check if the user is explicitly inactive
    if (user.active === false) {
        console.log('User is inactive:', user);
        return res.status(403).json({ error: 'Your account is inactive. Please contact support.' });
    }

    // Verify the password
    const isMatch = await bcrypt.compare(password, user.password);
    console.log('Password match:', isMatch);

    if (!isMatch) {
        return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Create token
    const token = signToken(user._id);
    console.log('Token created:', token);

    // Set token in cookie
    res.cookie('jwt', token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        maxAge: 86400000,
    });

    res.status(200).json({ message: 'Logged in successfully!', token });
});





/*exports.protect = async_error_handler(async (req, res, next) => {
    const testToken = req.headers.authorization;
    console.log('Authorization Header:', testToken);
    let token;
    if (testToken && testToken.startsWith('Bearer')) {
        token = testToken.split(' ')[1];
    }
    if (!token) {
        return next(new CustomError('You are not logged in!', 401));
    }
    console.log('Extracted Token:', token);
    try {
        const decodedToken = await util.promisify(jwt.verify)(token, process.env.SECRET_STR);
        const user = await User.findById(decodedToken.id);

        if (!user) {
            return next(new CustomError('The user with given token does not exist', 401));
        }

        const isPasswordChanged = await user.isPasswordChanged(decodedToken.iat);

        if (isPasswordChanged) {
            return next(new CustomError('The password has been changed recently. Please log in again', 401));
        }

        req.user = user;
        next();
    } catch (error) {
        return next(new CustomError('Invalid token. Please log in again', 401));
    }
});*/
exports.protect = async_error_handler(async (req, res, next) => {
    const token = req.cookies.jwt; // Extract token from cookie

    if (!token) {
        return next(new CustomError('You are not logged in!', 401));
    }

    try {
        const decodedToken = await util.promisify(jwt.verify)(token,'asg7-hnkenf-53jje7-63hnkk-72ggdjjd' );
        const user = await User.findById(decodedToken.id);
        req.user = user;
        if (!user) {
            return next(new CustomError('The user with given token does not exist', 401));
        }

        const isPasswordChanged = await user.isPasswordChanged(decodedToken.iat);

        if (isPasswordChanged) {
            return next(new CustomError('The password has been changed recently. Please log in again', 401));
        }

        req.user = user;
        next();
    } catch (error) {
        return next(new CustomError('Invalid token. Please log in again', 401));
    }
});


exports.restrict = (role) => {
    return (req, res, next) => {
        if (req.user.role !== role) {
            const error = new CustomError('You do not have permission to perform this action', 403);
            return next(error);
        }
        next();
    };
};

exports.logout = (req, res) => {
    req.session.destroy((err) => {
      if (err) {
        return res.status(500).json({ status: 'fail', message: 'Logout failed' });
      }
      res.status(200).json({ status: 'success', message: 'Logged out successfully' });
    });
  };
  
exports.forgotPassword = async_error_handler(async (req, res, next) => {
    try {
        const user = await User.findOne({ email: req.body.email });

        if (!user) {
            const error = new CustomError('We could not find the user with the given email', 404);
            return next(error);
        }

        const resetToken = user.createResetPasswordToken();
        const resetUrl = `${req.protocol}://${req.get('host')}/api/v1/users/resetPassword/${resetToken}`;
        const message = `We have received a password reset request. Please use the below link to reset your password\n\n${resetUrl}\n\nThis reset password link will be valid only for 10 minutes`;

        try {
            await sendEmail({
                email: user.email,
                subject: 'Password change request received',
                message: message
            });

            res.status(200).json({
                status: "success",
                message: "password reset link sent to the user email"
            });
        } catch (err) {
            console.error('Error sending email:', err);
            throw new CustomError('There was an error sending the password reset email. Please try again later', 500);
        }
    } catch (error) {
        next(error);
    }
});

exports.resetPassword = async_error_handler(async (req, res, next) => {
    // Extract token from the Authorization header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return next(new CustomError('Authorization header is missing or invalid', 401));
    }
    const token = authHeader.split(' ')[1]; // Extract token after "Bearer"

    try {
        // Decode the token and verify its authenticity
        const decodedToken = jwt.verify(token, 'asg7-hnkenf-53jje7-63hnkk-72ggdjjd');
        const userId = decodedToken.id; // Use the `id` field from the JWT payload

        // Fetch user from the database
        const user = await User.findById(userId).select('+password');
        if (!user) {
            return next(new CustomError('User not found', 404));
        }

        // Proceed with the password reset logic
        const { currentPassword, password, confirmPassword } = req.body;

        if (!currentPassword || !password || !confirmPassword) {
            return next(new CustomError('Please provide all required fields: currentPassword, password, confirmPassword', 400));
        }

        // Check if the currentPassword matches the user's existing password
        const isPasswordCorrect = await bcrypt.compare(currentPassword, user.password);
        if (!isPasswordCorrect) {
            return next(new CustomError('Current password is incorrect', 400));
        }

        // Check if the new password and confirmPassword match
        if (password !== confirmPassword) {
            return next(new CustomError('New password and confirm password do not match', 400));
        }

        // Update the user's password
        user.password = password; // Assumes hashing is handled by a pre-save hook in the model
        user.passwordChangedAt = Date.now();
        await user.save();

        // Respond with success
        res.status(200).json({
            status: 'success',
            message: 'Password updated successfully!',
        });
    } catch (error) {
        // Handle token errors or other issues
        return next(new CustomError('Invalid or expired token', 401));
    }
});

exports.deleteMe = async_error_handler(async (req, res, next) => {
    const email = req.query.email; // Retrieve email from query params

    if (!email) {
        return res.status(400).json({ message: "Email is required" });
    }

    await User.findOneAndUpdate(
        { email },
        { active: false },
        { new: true }
    );

    console.log("Deletion called");
    res.status(204).json({
        status: "success",
        data: null,
    });
});
exports.getAllUsers = async_error_handler(async (req, res) => {
    try {
      const users = await User.find();  // Find all users in the database
      
      if (!users || users.length === 0) {
        return res.status(404).json({ message: 'No users found' });
      }
  
      // Map over the users to include the avatar URL
      const usersWithAvatar = users.map(user => ({
        email: user.email,
        avatar: user.avatar ? `http://127.0.0.1:3000${user.avatar}` : null
      }));
  
      res.status(200).json({ users: usersWithAvatar });
    } catch (error) {
      console.error('Error fetching users:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  });
  

exports.getUser =  async_error_handler(async (req, res) => {
    try {
      const { email } = req.params;
      const user = await User.findOne({ email });
  
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      const avatarUrl = user.avatar ? `http://127.0.0.1:3000${user.avatar}` : null;
      // Send back user data including the avatar URL
      res.status(200).json({ user: { email: user.email, avatar: user.avatar || null } });
    } catch (error) {
      console.error('Error fetching user:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  });
