# Explore Lithuania Backend

Backend API for the **Explore Lithuania** tourism application.  
Built with Node.js, Express, and MongoDB.

## Features

- User authentication
- Event creation and management
- Avatar upload support
- Email sending functionality
- MongoDB database integration
- REST API architecture
- Rate limiting and security middleware

---

# Technologies Used

- Node.js
- Express.js
- MongoDB
- Mongoose
- JWT Authentication
- Multer
- Nodemailer
- Express Session
- CORS

---

# Project Structure

```bash
Controllers/     # Application controllers
Models/          # MongoDB models
routes/          # API routes
Utils/           # Utility functions
uploads/         # Uploaded images/files
index.js         # Main server file
```

---

# Controllers

## Auth Controller

Handles:

- User registration
- User login
- Logout
- Password reset
- User deletion
- Getting user data

Routes:

```http
POST /api/register
POST /api/login
POST /api/logout
PATCH /api/reset
DELETE /api/deleteMe
GET /api/user/:email
GET /api/allUsers
```

---

## Event Controller

Handles:

- Create event
- Edit event
- Delete event
- Get event by ID
- Filter events

Routes:

```http
POST /api/events/create
PUT /api/events/edit/:id
DELETE /api/events/delete/:id
GET /api/events/get/:id
GET /api/events/today
GET /api/events/bydate
GET /api/events/byplace
GET /api/events/placedate
GET /api/events/category
```

---

---

## Avatar Controller

Handles avatar uploads and assigns uploaded avatars to users.

### Features

- Upload user avatars using Multer
- Store uploaded images in `/uploads/avatars`
- Automatically generate unique filenames
- Save avatar path to MongoDB
- Create a new user if the email does not exist
- Update existing user's avatar

### Route

```http
POST /api/ava
```

### Request Type

```http
multipart/form-data
```

### Form Data

| Field  | Type | Description |
|--------|------|-------------|
| avatar | File | User avatar image |
| email  | Text | User email |

### Example Response

```json
{
  "message": "Avatar created and assigned successfully",
  "user": {
    "email": "user@example.com",
    "avatar": "/uploads/avatars/173712312-avatar.png"
  }
}
```

### Upload Location

```bash
/uploads/avatars
```

---

# Installation

## 1. Clone Repository

```bash
git clone https://github.com/kateryna051/Coursework.git
cd Coursework
```

---

## 2. Install Dependencies

```bash
npm install
```

---

## 3. Configure Environment Variables

Create a `.env` file in the root directory.

Example:

```env
PORT=3000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_secret_key
LOGIN_EXPIRES=86400000(example)
```

---

## 4. Start Server

```bash
node index.js
```

Server will run on:

```bash
http://localhost:3000
```

---

# API Base URL

```bash
http://localhost:3000/api
```

---

# Notes

- MongoDB must be running locally or connected through MongoDB Atlas.
- Uploaded files are stored in the `/uploads` directory.
- CORS is enabled for API requests.

---

# Author

Kateryna Patsui
kate160203@gmail.com
