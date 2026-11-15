const Whitelist = require('../models/Whitelist');
const User = require('../models/User');

// @desc    Add a single Company/Employee ID to the whitelist
// @route   POST /api/whitelist/add
// @access  Private (Admin Only)
const addSingleId = async (req, res) => {
  try {
    const { companyId, name, department } = req.body;

    if (!companyId) {
      return res.status(400).json({
        success: false,
        message: 'Company ID is required.',
      });
    }

    const cleanCompanyId = companyId.trim().toUpperCase();

    // Check if ID already whitelisted in this organization
    const existing = await Whitelist.findOne({
      orgId: req.orgId,
      companyId: cleanCompanyId,
    });

    if (existing) {
      return res.status(400).json({
        success: false,
        message: `ID "${cleanCompanyId}" is already on the whitelist for this organization.`,
      });
    }

    const entry = await Whitelist.create({
      orgId: req.orgId,
      companyId: cleanCompanyId,
      name: name ? name.trim() : '',
      department: department ? department.trim() : '',
      addedBy: req.user._id,
    });

    return res.status(201).json({
      success: true,
      message: `ID "${cleanCompanyId}" successfully added to authorized list.`,
      entry,
    });
  } catch (error) {
    console.error('Add Whitelist Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error adding ID to whitelist.',
    });
  }
};

// @desc    Add bulk Company IDs (via array or comma/newline separated string)
// @route   POST /api/whitelist/bulk
// @access  Private (Admin Only)
const addBulkIds = async (req, res) => {
  try {
    const { rawIds, items } = req.body;
    let entriesToProcess = [];

    if (Array.isArray(items) && items.length > 0) {
      entriesToProcess = items.map((it) => ({
        companyId: String(it.companyId || it).trim().toUpperCase(),
        name: it.name ? String(it.name).trim() : '',
        department: it.department ? String(it.department).trim() : '',
      }));
    } else if (rawIds && typeof rawIds === 'string') {
      // Split by comma, newline, or semicolon
      const tokens = rawIds.split(/[\r\n,;]+/).map((t) => t.trim().toUpperCase()).filter(Boolean);
      entriesToProcess = tokens.map((id) => ({
        companyId: id,
        name: '',
        department: '',
      }));
    }

    if (entriesToProcess.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Please provide valid IDs in items array or rawIds text.',
      });
    }

    // Deduplicate within the payload
    const uniqueMap = new Map();
    for (const item of entriesToProcess) {
      if (!uniqueMap.has(item.companyId)) {
        uniqueMap.set(item.companyId, item);
      }
    }
    const cleanList = Array.from(uniqueMap.values());

    // Filter out already existing IDs in this organization
    const existingList = await Whitelist.find({
      orgId: req.orgId,
      companyId: { $in: cleanList.map((x) => x.companyId) },
    }).select('companyId');

    const existingSet = new Set(existingList.map((x) => x.companyId));
    const newDocs = cleanList
      .filter((x) => !existingSet.has(x.companyId))
      .map((x) => ({
        orgId: req.orgId,
        companyId: x.companyId,
        name: x.name,
        department: x.department,
        addedBy: req.user._id,
      }));

    if (newDocs.length > 0) {
      await Whitelist.insertMany(newDocs);
    }

    return res.status(200).json({
      success: true,
      message: `Bulk processing complete! Added: ${newDocs.length}, Skipped duplicates: ${cleanList.length - newDocs.length}.`,
      addedCount: newDocs.length,
      skippedCount: cleanList.length - newDocs.length,
    });
  } catch (error) {
    console.error('Bulk Whitelist Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error processing bulk IDs.',
    });
  }
};

// @desc    Get all whitelisted IDs for this organization
// @route   GET /api/whitelist
// @access  Private (Admin Only)
const getWhitelist = async (req, res) => {
  try {
    const { search, status } = req.query;
    const filter = { orgId: req.orgId };

    if (search) {
      const searchRegex = new RegExp(search.trim(), 'i');
      filter.$or = [{ companyId: searchRegex }, { name: searchRegex }, { department: searchRegex }];
    }

    if (status === 'registered') {
      filter.isRegistered = true;
    } else if (status === 'pending') {
      filter.isRegistered = false;
    }

    const list = await Whitelist.find(filter)
      .sort({ createdAt: -1 })
      .populate('registeredUserId', 'name email createdAt');

    const totalCount = await Whitelist.countDocuments({ orgId: req.orgId });
    const registeredCount = await Whitelist.countDocuments({ orgId: req.orgId, isRegistered: true });
    const pendingCount = totalCount - registeredCount;

    return res.status(200).json({
      success: true,
      stats: {
        totalAuthorized: totalCount,
        registeredVoters: registeredCount,
        pendingRegistration: pendingCount,
      },
      data: list,
    });
  } catch (error) {
    console.error('Get Whitelist Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Delete ID from whitelist
// @route   DELETE /api/whitelist/:id
// @access  Private (Admin Only)
const deleteWhitelistId = async (req, res) => {
  try {
    const entry = await Whitelist.findOne({ _id: req.params.id, orgId: req.orgId });
    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Whitelist entry not found in your organization.',
      });
    }

    if (entry.isRegistered) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete an ID that has already registered an active voter account.',
      });
    }

    await Whitelist.deleteOne({ _id: entry._id });

    return res.status(200).json({
      success: true,
      message: `ID "${entry.companyId}" removed from authorized list.`,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  addSingleId,
  addBulkIds,
  getWhitelist,
  deleteWhitelistId,
};
