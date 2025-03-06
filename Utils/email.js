const nodemailer = require('nodemailer');

exports.emailSend = async (req, res) => {
  try {
    const { email, message } = req.body;  // The email and message from the user

    // Create a transporter (Mailtrap configuration)
    const transporter = nodemailer.createTransport({
      host: 'smtp.mailtrap.io',
      port: 2525,
      auth: {
        user: 'df98fa7359fafc',  // Your Mailtrap username
        pass: '1908b368f0ea29',   // Your Mailtrap password
      },
    });

    // Define the email options
    const emailOptions = {
      from: `${email}`,  // Sender's email (from Mailtrap)
      to: 'support@explore-lithuania.com',  // Recipient's email (the email you want to send the message to)
      subject: 'Help Request',  // Subject of the email
      text: `You received a message from: ${email}\n\nMessage:\n${message}`,  // The body of the email
    };

    // Send the email
    await transporter.sendMail(emailOptions);

    // Send success response
    res.status(200).json({ message: 'Email sent successfully' });
  } catch (error) {
    console.error('Error sending email:', error);
    res.status(500).json({ message: 'Failed to send email. Please try again later.' });
  }
};
