const Organization = require('../models/Organization');
const User = require('../models/User');
const Whitelist = require('../models/Whitelist');
const Election = require('../models/Election');
const Vote = require('../models/Vote');

// @desc    Get Admin Dashboard Analytics
// @route   GET /api/analytics/dashboard
// @access  Private (Admin Only)
const getAdminDashboardStats = async (req, res) => {
  try {
    const orgId = req.orgId;

    // 1. Whitelist & Voter metrics
    const totalWhitelisted = await Whitelist.countDocuments({ orgId });
    const registeredVoters = await Whitelist.countDocuments({ orgId, isRegistered: true });
    const pendingVoters = totalWhitelisted - registeredVoters;

    // 2. Election metrics
    const allElections = await Election.find({ orgId }).sort({ createdAt: -1 });

    const now = new Date();
    let activeCount = 0;
    let upcomingCount = 0;
    let completedCount = 0;
    let totalVotesCast = 0;

    allElections.forEach((el) => {
      totalVotesCast += el.totalVotes || 0;
      if (el.isManualClosed || now > el.endTime) {
        completedCount++;
      } else if (now < el.startTime) {
        upcomingCount++;
      } else {
        activeCount++;
      }
    });

    // 3. Organization info
    const org = await Organization.findById(orgId).select('name orgCode address createdAt');

    // 4. Calculate overall turnout
    const turnoutRate = registeredVoters > 0 && allElections.length > 0
      ? Number(((totalVotesCast / (registeredVoters * allElections.length)) * 100).toFixed(1))
      : 0;

    return res.status(200).json({
      success: true,
      data: {
        organization: org,
        voters: {
          totalWhitelisted,
          registeredVoters,
          pendingVoters,
        },
        elections: {
          total: allElections.length,
          active: activeCount,
          upcoming: upcomingCount,
          completed: completedCount,
        },
        voting: {
          totalVotesCast,
          turnoutRate,
        },
        recentElections: allElections.slice(0, 5).map((e) => ({
          id: e._id,
          title: e.title,
          category: e.category,
          totalVotes: e.totalVotes,
          status: e.status,
          endTime: e.endTime,
        })),
      },
    });
  } catch (error) {
    console.error('Analytics Dashboard Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error fetching analytics.',
    });
  }
};

module.exports = {
  getAdminDashboardStats,
};
