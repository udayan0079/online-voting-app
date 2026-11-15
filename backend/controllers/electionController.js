const Election = require('../models/Election');
const Vote = require('../models/Vote');

// Helper to calculate winner & percentages
const computeElectionResults = (election) => {
  const electionObj = election.toObject({ virtuals: true });
  const totalVotes = electionObj.totalVotes || 0;

  let maxVotes = -1;
  let winner = null;
  let isTie = false;

  const enrichedCandidates = (electionObj.candidates || []).map((cand) => {
    const votes = cand.voteCount || 0;
    const percentage = totalVotes > 0 ? Number(((votes / totalVotes) * 100).toFixed(1)) : 0;

    if (votes > maxVotes) {
      maxVotes = votes;
      winner = cand;
      isTie = false;
    } else if (votes === maxVotes && maxVotes > 0) {
      isTie = true;
    }

    return {
      ...cand,
      votePercentage: percentage,
    };
  });

  return {
    ...electionObj,
    candidates: enrichedCandidates,
    resultSummary: {
      totalVotes,
      winner: totalVotes > 0 && !isTie ? winner : null,
      isTie: totalVotes > 0 ? isTie : false,
      isConcluded: electionObj.status === 'COMPLETED',
    },
  };
};

// @desc    Create a new Election / Voting Portal
// @route   POST /api/elections
// @access  Private (Admin Only)
const createElection = async (req, res) => {
  try {
    const { title, category, description, startTime, endTime, candidates } = req.body;

    if (!title || !category || !startTime || !endTime) {
      return res.status(400).json({
        success: false,
        message: 'Title, category/designation, startTime, and endTime are required.',
      });
    }

    const startDate = new Date(startTime);
    const endDate = new Date(endTime);

    if (isNaN(startDate.getTime()) || isNaN(endDate.getTime())) {
      return res.status(400).json({
        success: false,
        message: 'Invalid start or end date format.',
      });
    }

    if (endDate <= startDate) {
      return res.status(400).json({
        success: false,
        message: 'Election end time must be after the start time.',
      });
    }

    if (!Array.isArray(candidates) || candidates.length < 2) {
      return res.status(400).json({
        success: false,
        message: 'An election must have at least 2 candidates.',
      });
    }

    // Format candidates
    const formattedCandidates = candidates.map((c) => ({
      name: (c.name || '').trim(),
      companyId: (c.companyId || '').trim().toUpperCase(),
      photoUrl: c.photoUrl || '',
      logoUrl: c.logoUrl || '',
      symbolName: (c.symbolName || '').trim(),
      bio: (c.bio || '').trim(),
      voteCount: 0,
    }));

    // Verify all candidates have name & companyId
    for (const c of formattedCandidates) {
      if (!c.name || !c.companyId) {
        return res.status(400).json({
          success: false,
          message: 'Each candidate must have a valid Name and Company ID.',
        });
      }
    }

    const election = await Election.create({
      orgId: req.orgId,
      title: title.trim(),
      category: category.trim(),
      description: description ? description.trim() : '',
      startTime: startDate,
      endTime: endDate,
      candidates: formattedCandidates,
      createdBy: req.user._id,
    });

    return res.status(201).json({
      success: true,
      message: 'Voting portal successfully created!',
      data: election.toObject({ virtuals: true }),
    });
  } catch (error) {
    console.error('Create Election Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error creating election.',
    });
  }
};

// @desc    Update Election / Candidate details
// @route   PUT /api/elections/:id
// @access  Private (Admin Only)
const updateElection = async (req, res) => {
  try {
    const election = await Election.findOne({ _id: req.params.id, orgId: req.orgId });
    if (!election) {
      return res.status(404).json({
        success: false,
        message: 'Election not found in your organization.',
      });
    }

    const { title, category, description, startTime, endTime, candidates } = req.body;

    if (title) election.title = title.trim();
    if (category) election.category = category.trim();
    if (description !== undefined) election.description = description.trim();

    if (startTime) election.startTime = new Date(startTime);
    if (endTime) election.endTime = new Date(endTime);

    if (Array.isArray(candidates) && candidates.length >= 2) {
      // Preserve existing vote counts if candidate id matches
      const existingVoteMap = new Map();
      election.candidates.forEach((cand) => {
        existingVoteMap.set(cand._id.toString(), cand.voteCount);
      });

      election.candidates = candidates.map((c) => ({
        _id: c._id || undefined,
        name: (c.name || '').trim(),
        companyId: (c.companyId || '').trim().toUpperCase(),
        photoUrl: c.photoUrl || '',
        logoUrl: c.logoUrl || '',
        symbolName: (c.symbolName || '').trim(),
        bio: (c.bio || '').trim(),
        voteCount: c._id && existingVoteMap.has(c._id.toString()) ? existingVoteMap.get(c._id.toString()) : 0,
      }));
    }

    await election.save();

    return res.status(200).json({
      success: true,
      message: 'Election details updated successfully.',
      data: election.toObject({ virtuals: true }),
    });
  } catch (error) {
    console.error('Update Election Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error updating election.',
    });
  }
};

// @desc    Get all Elections for current organization
// @route   GET /api/elections
// @access  Private (Admin & Voter)
const getElections = async (req, res) => {
  try {
    const { status, category } = req.query;
    const filter = { orgId: req.orgId };

    if (category) {
      filter.category = new RegExp(category.trim(), 'i');
    }

    const elections = await Election.find(filter).sort({ createdAt: -1 });

    // Check voting history of current user
    const userVotes = await Vote.find({
      orgId: req.orgId,
      voterId: req.user._id,
    }).select('electionId candidateId voteReceiptHash votedAt');

    const voteMap = new Map();
    userVotes.forEach((v) => {
      voteMap.set(v.electionId.toString(), {
        candidateId: v.candidateId,
        receipt: v.voteReceiptHash,
        votedAt: v.votedAt,
      });
    });

    const enrichedList = elections.map((el) => {
      const computed = computeElectionResults(el);
      const userVote = voteMap.get(el._id.toString());
      return {
        ...computed,
        hasVoted: Boolean(userVote),
        userVoteRecord: userVote || null,
      };
    });

    // Optional status filter in-memory since status is a virtual property
    let finalResult = enrichedList;
    if (status) {
      const upperStatus = status.toUpperCase();
      finalResult = enrichedList.filter((e) => e.status === upperStatus);
    }

    return res.status(200).json({
      success: true,
      count: finalResult.length,
      data: finalResult,
    });
  } catch (error) {
    console.error('Get Elections Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get Single Election Details
// @route   GET /api/elections/:id
// @access  Private (Admin & Voter)
const getElectionById = async (req, res) => {
  try {
    const election = await Election.findOne({ _id: req.params.id, orgId: req.orgId });
    if (!election) {
      return res.status(404).json({
        success: false,
        message: 'Election not found in your organization.',
      });
    }

    const userVote = await Vote.findOne({
      orgId: req.orgId,
      electionId: election._id,
      voterId: req.user._id,
    });

    const computed = computeElectionResults(election);

    return res.status(200).json({
      success: true,
      data: {
        ...computed,
        hasVoted: Boolean(userVote),
        userVoteRecord: userVote
          ? {
              candidateId: userVote.candidateId,
              receipt: userVote.voteReceiptHash,
              votedAt: userVote.votedAt,
            }
          : null,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Manual Close / Conclude Election early
// @route   PATCH /api/elections/:id/close
// @access  Private (Admin Only)
const closeElection = async (req, res) => {
  try {
    const election = await Election.findOne({ _id: req.params.id, orgId: req.orgId });
    if (!election) {
      return res.status(404).json({
        success: false,
        message: 'Election not found in your organization.',
      });
    }

    election.isManualClosed = true;
    election.endTime = new Date();
    await election.save();

    return res.status(200).json({
      success: true,
      message: 'Election manually closed. Final results published!',
      data: computeElectionResults(election),
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Delete Election and associated votes
// @route   DELETE /api/elections/:id
// @access  Private (Admin Only)
const deleteElection = async (req, res) => {
  try {
    const election = await Election.findOne({ _id: req.params.id, orgId: req.orgId });
    if (!election) {
      return res.status(404).json({
        success: false,
        message: 'Election not found in your organization.',
      });
    }

    await Election.deleteOne({ _id: election._id });
    await Vote.deleteMany({ electionId: election._id, orgId: req.orgId });

    return res.status(200).json({
      success: true,
      message: 'Election and its vote records deleted permanently.',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  createElection,
  updateElection,
  getElections,
  getElectionById,
  closeElection,
  deleteElection,
};
