const express = require('express');
const router = express.Router();
const {
  registerAdmin,
  loginAdmin,
  verifyVoterId,
  registerVoter,
  loginVoter,
  getMe,
} = require('../controllers/authController');
const { protect } = require('../middlewares/authMiddleware');

// Public endpoints
router.post('/admin/register', registerAdmin);
router.post('/admin/login', loginAdmin);
router.post('/voter/verify-id', verifyVoterId);
router.post('/voter/register', registerVoter);
router.post('/voter/login', loginVoter);

// Protected endpoints
router.get('/me', protect, getMe);

module.exports = router;
