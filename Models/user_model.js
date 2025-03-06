const mongoose = require('mongoose');
const validator = require('validator');
const crypto = require('crypto');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'Please enter your email.'],
    unique: true,
    lowercase: true,
    validate: [validator.isEmail, 'Please enter a valid email']
},  
avatar:{
type:String,
required:[false],
},
password:{
  type: String,
  required:[true, 'Please enter your password.'],
  minlength: 3,
  select: false
}, confirmPassword:{
  type: String,
  //required:[true, 'confirm your password'],
  validate:{
      validator:function(val){
          return val == this.password;
      },
      message: 'Password & Confirm Password does not match!'
  }
  },
  active:{
      type: Boolean,
      default:true,
      select: false
  },
passwordChangedAt: Date,
        passwordResetToken: String,
        passwordResetTokenExpires: Date
});
UserSchema.methods.comparePasswordInDb = async function(pswd,pswdDB){
  return await bcrypt.compare(pswd, pswdDB);
}

UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();

  // Log password before and after hashing
  console.log("Password before hash: ", this.password);

  this.password = await bcrypt.hash(this.password, 12);

  console.log("Password after hash: ", this.password);  // Ensure it is hashed

  next();
});


const User = mongoose.model('User', UserSchema);

module.exports = User;
