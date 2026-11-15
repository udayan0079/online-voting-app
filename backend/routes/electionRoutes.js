const express = require('express');
const router = express.Router();
const {
  createElection,
  updateElection,
  getElections,
  getElectionById,
  closeElection,
  deleteElection,
} = require('../controllers/electionController');
const { protect } = require('../middlewares/authMiddleware');
const { requireAdmin } = require('../middlewares/roleMiddleware');

// All election routes require authentication
router.use(protect);

// Shared by Admin and Voter
router.get('/', getElections);
router.get('/:id', getElectionById);

// Admin-only operations
router.post('/', requireAdmin, createElection);
router.put('/:id', requireAdmin, updateElection);
router.patch('/:id/close', requireAdmin, closeElection);
router.delete('/:id', requireAdmin, deleteElection);

module.exports = router;
