const express = require('express');
const authController = require('./../Controllers/auth_controller');
const emailSender = require('./../Utils/email');
const avatar = require('./../Controllers/avatar_controller');

const router = express.Router();
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/logout', authController.logout);
router.patch('/reset', authController.resetPassword, authController.protect);
router.delete('/deleteMe', authController.deleteMe);
router.post('/sendEmail', emailSender.emailSend);
router.get('/user/:email', authController.getUser);
router.get('/allUsers', authController.getAllUsers);
router.post('/ava', avatar.uploadAvatar, avatar.createAvatarForUser);

module.exports = router;