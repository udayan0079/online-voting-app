const express = require('express');
const router = express.Router();
const { getAdminDashboardStats } = require('../controllers/analyticsController');
const { protect } = require('../middlewares/authMiddleware');
const { requireAdmin } = require('../middlewares/roleMiddleware');

router.use(protect, requireAdmin);

router.get('/dashboard', getAdminDashboardStats);

module.exports = router;
