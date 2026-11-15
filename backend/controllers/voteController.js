const Election = require('../models/Election');
const Vote = require('../models/Vote');
const User = require('../models/User');

// @desc    Cast a Vote for a candidate in an active election
// @route   POST /api/votes/cast
// @access  Private (Voter Only)
const castVote = async (req, res) => {
  try {
    const { electionId, candidateId } = req.body;

    if (!electionId || !candidateId) {
      return res.status(400).json({
        success: false,
        message: 'Election ID and Candidate ID are required to cast a vote.',
      });
    }

    // 1. Fetch Election
    const election = await Election.findOne({ _id: electionId, orgId: req.orgId });
    if (!election) {
      return res.status(404).json({
        success: false,
        message: 'Election does not exist in your organization.',
      });
    }

    // 2. Check Time Validity
    const now = new Date();
    if (election.isManualClosed || now > election.endTime) {
      return res.status(400).json({
        success: false,
        message: 'Voting period has ended for this election. No more votes can be accepted.',
      });
    }

    if (now < election.startTime) {
      return res.status(400).json({
        success: false,
        message: `Voting has not started yet. Starts at: ${election.startTime.toLocaleString()}`,
      });
    }

    // 3. Check if Candidate exists in this election
    const candidate = election.candidates.id(candidateId);
    if (!candidate) {
      return res.status(404).json({
        success: false,
        message: 'Selected candidate not found in this election ballot.',
      });
    }

    // 4. Ensure single-vote per voter per election
    const alreadyVoted = await Vote.findOne({
      electionId: election._id,
      voterId: req.user._id,
    });

    if (alreadyVoted) {
      return res.status(400).json({
        success: false,
        message: `You have already cast your vote in this election on ${alreadyVoted.votedAt.toLocaleString()}. Receipt: ${alreadyVoted.voteReceiptHash}`,
        receipt: alreadyVoted.voteReceiptHash,
      });
    }

    // 5. Create Vote Record
    const vote = new Vote({
      orgId: req.orgId,
      electionId: election._id,
      voterId: req.user._id,
      voterCompanyId: req.user.companyId,
      candidateId: candidate._id,
    });
    await vote.save();

    // 6. Increment candidate vote count and election total
    candidate.voteCount = (candidate.voteCount || 0) + 1;
    election.totalVotes = (election.totalVotes || 0) + 1;
    await election.save();

    return res.status(201).json({
      success: true,
      message: `Vote successfully cast for ${candidate.name}!`,
      data: {
        receipt: vote.voteReceiptHash,
        candidateName: candidate.name,
        candidateCompanyId: candidate.companyId,
        votedAt: vote.votedAt,
        electionTitle: election.title,
      },
    });
  } catch (error) {
    console.error('Cast Vote Error:', error);
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'Duplicate vote detected! You have already voted in this election.',
      });
    }
    return res.status(500).json({
      success: false,
      message: error.message || 'Error recording your vote.',
    });
  }
};

// @desc    Get Current Voter's Voting History
// @route   GET /api/votes/my-history
// @access  Private (Voter & Admin)
const getMyVotingHistory = async (req, res) => {
  try {
    const votes = await Vote.find({
      orgId: req.orgId,
      voterId: req.user._id,
    })
      .populate('electionId', 'title category startTime endTime isManualClosed')
      .sort({ votedAt: -1 });

    return res.status(200).json({
      success: true,
      count: votes.length,
      data: votes,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Verify Vote Receipt
// @route   GET /api/votes/verify/:receipt
// @access  Private
const verifyReceipt = async (req, res) => {
  try {
    const vote = await Vote.findOne({
      orgId: req.orgId,
      voteReceiptHash: req.params.receipt.trim().toUpperCase(),
    }).populate('electionId', 'title category');

    if (!vote) {
      return res.status(404).json({
        success: false,
        message: 'No matching vote receipt found in this organization.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Vote receipt is authentic and securely registered.',
      data: {
        receipt: vote.voteReceiptHash,
        votedAt: vote.votedAt,
        electionTitle: vote.electionId ? vote.electionId.title : 'N/A',
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  castVote,
  getMyVotingHistory,
  verifyReceipt,
};
