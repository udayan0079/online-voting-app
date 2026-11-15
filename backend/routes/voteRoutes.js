const express = require('express');
const router = express.Router();
const {
  castVote,
  getMyVotingHistory,
  verifyReceipt,
} = require('../controllers/voteController');
const { protect } = require('../middlewares/authMiddleware');
const { requireVoter } = require('../middlewares/roleMiddleware');

// All vote routes require authentication
router.use(protect);

router.post('/cast', requireVoter, castVote);
router.get('/my-history', getMyVotingHistory);
router.get('/verify/:receipt', verifyReceipt);

module.exports = router;
