const express = require('express');
const router = express.Router();
const {
  addSingleId,
  addBulkIds,
  getWhitelist,
  deleteWhitelistId,
} = require('../controllers/whitelistController');
const { protect } = require('../middlewares/authMiddleware');
const { requireAdmin } = require('../middlewares/roleMiddleware');

// All whitelist routes require authenticated Admin in their organization
router.use(protect, requireAdmin);

router.post('/add', addSingleId);
router.post('/bulk', addBulkIds);
router.get('/', getWhitelist);
router.delete('/:id', deleteWhitelistId);

module.exports = router;
