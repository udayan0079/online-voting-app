const express = require('express');
const router = express.Router();
const { chatWithAi } = require('../controllers/aiController');

// POST /api/ai/chat - Live AI assistant for admins & general queries
router.post('/chat', chatWithAi);

module.exports = router;
