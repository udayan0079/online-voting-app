const Organization = require('../models/Organization');
const User = require('../models/User');
const Whitelist = require('../models/Whitelist');
const generateToken = require('../utils/tokenGenerator');

// @desc    Register a new Organization and its Root Admin
// @route   POST /api/auth/admin/register
// @access  Public
const registerAdmin = async (req, res) => {
  try {
    const { orgName, orgCode, adminName, adminCompanyId, email, password, address, description } = req.body;

    if (!orgName || !orgCode || !adminName || !adminCompanyId || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields: orgName, orgCode, adminName, adminCompanyId, password.',
      });
    }

    const cleanOrgCode = orgCode.trim().toUpperCase();
    const cleanCompanyId = adminCompanyId.trim().toUpperCase();

    // Check if organization code already taken
    const existingOrg = await Organization.findOne({ orgCode: cleanOrgCode });
    if (existingOrg) {
      return res.status(400).json({
        success: false,
        message: `Organization code "${cleanOrgCode}" is already registered. Please choose another unique code.`,
      });
    }

    // 1. Create Organization
    const organization = await Organization.create({
      name: orgName.trim(),
      orgCode: cleanOrgCode,
      address: address ? address.trim() : '',
      description: description ? description.trim() : '',
    });

    // 2. Create Admin User
    const adminUser = await User.create({
      name: adminName.trim(),
      companyId: cleanCompanyId,
      email: email ? email.trim().toLowerCase() : '',
      password,
      role: 'ADMIN',
      orgId: organization._id,
      department: 'Administration',
    });

    // 3. Link Admin to Org
    organization.admin = adminUser._id;
    await organization.save();

    // 4. Auto-whitelist Admin's Company ID
    await Whitelist.create({
      orgId: organization._id,
      companyId: cleanCompanyId,
      name: adminName.trim(),
      department: 'Administration',
      isRegistered: true,
      registeredUserId: adminUser._id,
      addedBy: adminUser._id,
    });

    const token = generateToken(adminUser);

    return res.status(201).json({
      success: true,
      message: 'Organization and Admin registered successfully!',
      token,
      user: {
        id: adminUser._id,
        name: adminUser.name,
        companyId: adminUser.companyId,
        email: adminUser.email,
        role: adminUser.role,
        department: adminUser.department,
      },
      organization: {
        id: organization._id,
        name: organization.name,
        orgCode: organization.orgCode,
        address: organization.address,
      },
    });
  } catch (error) {
    console.error('Admin Register Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while registering admin.',
    });
  }
};

// @desc    Admin Login
// @route   POST /api/auth/admin/login
// @access  Public
const loginAdmin = async (req, res) => {
  try {
    const { orgCode, identifier, password } = req.body; // identifier can be companyId or email

    if (!orgCode || !identifier || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide orgCode, companyId/email, and password.',
      });
    }

    const cleanOrgCode = orgCode.trim().toUpperCase();
    const cleanIdentifier = identifier.trim();

    // Verify Organization
    const organization = await Organization.findOne({ orgCode: cleanOrgCode });
    if (!organization) {
      return res.status(404).json({
        success: false,
        message: `No organization found with code "${cleanOrgCode}".`,
      });
    }

    // Find Admin User by companyId (uppercase) or email
    const adminUser = await User.findOne({
      orgId: organization._id,
      role: 'ADMIN',
      $or: [
        { companyId: cleanIdentifier.toUpperCase() },
        { email: cleanIdentifier.toLowerCase() },
      ],
    });

    if (!adminUser) {
      return res.status(401).json({
        success: false,
        message: 'Invalid Admin credentials for this organization.',
      });
    }

    const isMatch = await adminUser.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid Admin credentials for this organization.',
      });
    }

    const token = generateToken(adminUser);

    return res.status(200).json({
      success: true,
      message: 'Admin login successful!',
      token,
      user: {
        id: adminUser._id,
        name: adminUser.name,
        companyId: adminUser.companyId,
        email: adminUser.email,
        role: adminUser.role,
        department: adminUser.department,
      },
      organization: {
        id: organization._id,
        name: organization.name,
        orgCode: organization.orgCode,
        address: organization.address,
      },
    });
  } catch (error) {
    console.error('Admin Login Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while logging in admin.',
    });
  }
};

// @desc    Pre-verify Voter Company ID against Organization Whitelist
// @route   POST /api/auth/voter/verify-id
// @access  Public
const verifyVoterId = async (req, res) => {
  try {
    const { orgCode, companyId } = req.body;

    if (!orgCode || !companyId) {
      return res.status(400).json({
        success: false,
        message: 'Please enter Organization Code and your Company/Employee ID.',
      });
    }

    const cleanOrgCode = orgCode.trim().toUpperCase();
    const cleanCompanyId = companyId.trim().toUpperCase();

    const organization = await Organization.findOne({ orgCode: cleanOrgCode });
    if (!organization) {
      return res.status(404).json({
        success: false,
        message: `Organization code "${cleanOrgCode}" does not exist.`,
      });
    }

    // Check Whitelist
    const whitelisted = await Whitelist.findOne({
      orgId: organization._id,
      companyId: cleanCompanyId,
    });

    if (!whitelisted) {
      return res.status(403).json({
        success: false,
        isAuthorized: false,
        message: `Employee ID "${cleanCompanyId}" is NOT pre-authorized by ${organization.name} admin. Outsiders are strictly not permitted.`,
      });
    }

    if (whitelisted.isRegistered) {
      return res.status(400).json({
        success: false,
        isRegistered: true,
        message: `Employee ID "${cleanCompanyId}" is already registered. Please login with your password.`,
      });
    }

    return res.status(200).json({
      success: true,
      isAuthorized: true,
      isRegistered: false,
      message: `Verified! ID "${cleanCompanyId}" is authorized for registration.`,
      organization: {
        id: organization._id,
        name: organization.name,
        orgCode: organization.orgCode,
      },
      prefilled: {
        companyId: whitelisted.companyId,
        name: whitelisted.name,
        department: whitelisted.department,
      },
    });
  } catch (error) {
    console.error('Verify Voter ID Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while checking employee ID.',
    });
  }
};

// @desc    Voter Registration (Strict Whitelist Enforcement)
// @route   POST /api/auth/voter/register
// @access  Public
const registerVoter = async (req, res) => {
  try {
    const { orgCode, companyId, name, password, department, email } = req.body;

    if (!orgCode || !companyId || !name || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide orgCode, companyId, name, and password.',
      });
    }

    const cleanOrgCode = orgCode.trim().toUpperCase();
    const cleanCompanyId = companyId.trim().toUpperCase();

    const organization = await Organization.findOne({ orgCode: cleanOrgCode });
    if (!organization) {
      return res.status(404).json({
        success: false,
        message: `Organization code "${cleanOrgCode}" not found.`,
      });
    }

    // 1. Check if ID exists in organization whitelist
    const whitelistEntry = await Whitelist.findOne({
      orgId: organization._id,
      companyId: cleanCompanyId,
    });

    if (!whitelistEntry) {
      return res.status(403).json({
        success: false,
        message: `Access Denied! ID "${cleanCompanyId}" is not whitelisted by the company admin. Only authorized personnel can register.`,
      });
    }

    if (whitelistEntry.isRegistered) {
      return res.status(400).json({
        success: false,
        message: `This Company ID (${cleanCompanyId}) is already registered! Please login instead.`,
      });
    }

    // 2. Check if user already exists
    const existingUser = await User.findOne({
      orgId: organization._id,
      companyId: cleanCompanyId,
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: `An account already exists for ID "${cleanCompanyId}".`,
      });
    }

    // 3. Create Voter Account
    const voter = await User.create({
      name: name.trim(),
      companyId: cleanCompanyId,
      email: email ? email.trim().toLowerCase() : '',
      password,
      role: 'VOTER',
      orgId: organization._id,
      department: (department || whitelistEntry.department || '').trim(),
    });

    // 4. Mark Whitelist as registered
    whitelistEntry.isRegistered = true;
    whitelistEntry.registeredUserId = voter._id;
    if (!whitelistEntry.name && name) {
      whitelistEntry.name = name.trim();
    }
    await whitelistEntry.save();

    const token = generateToken(voter);

    return res.status(201).json({
      success: true,
      message: 'Voter registered successfully! You can now participate in elections.',
      token,
      user: {
        id: voter._id,
        name: voter.name,
        companyId: voter.companyId,
        email: voter.email,
        role: voter.role,
        department: voter.department,
      },
      organization: {
        id: organization._id,
        name: organization.name,
        orgCode: organization.orgCode,
      },
    });
  } catch (error) {
    console.error('Voter Register Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while registering voter.',
    });
  }
};

// @desc    Voter Login
// @route   POST /api/auth/voter/login
// @access  Public
const loginVoter = async (req, res) => {
  try {
    const { orgCode, companyId, password } = req.body;

    if (!orgCode || !companyId || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide Organization Code, Company ID, and Password.',
      });
    }

    const cleanOrgCode = orgCode.trim().toUpperCase();
    const cleanCompanyId = companyId.trim().toUpperCase();

    const organization = await Organization.findOne({ orgCode: cleanOrgCode });
    if (!organization) {
      return res.status(404).json({
        success: false,
        message: `Organization "${cleanOrgCode}" not found.`,
      });
    }

    const voter = await User.findOne({
      orgId: organization._id,
      companyId: cleanCompanyId,
      role: 'VOTER',
    });

    if (!voter) {
      return res.status(401).json({
        success: false,
        message: `No voter account found for ID "${cleanCompanyId}" in ${organization.name}. Make sure you registered first.`,
      });
    }

    const isMatch = await voter.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid Company ID or Password.',
      });
    }

    const token = generateToken(voter);

    return res.status(200).json({
      success: true,
      message: 'Login successful!',
      token,
      user: {
        id: voter._id,
        name: voter.name,
        companyId: voter.companyId,
        email: voter.email,
        role: voter.role,
        department: voter.department,
      },
      organization: {
        id: organization._id,
        name: organization.name,
        orgCode: organization.orgCode,
      },
    });
  } catch (error) {
    console.error('Voter Login Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error while logging in.',
    });
  }
};

// @desc    Get Current Logged in User Profile
// @route   GET /api/auth/me
// @access  Private
const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-password');
    const organization = await Organization.findById(req.orgId);

    return res.status(200).json({
      success: true,
      user,
      organization,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  registerAdmin,
  loginAdmin,
  verifyVoterId,
  registerVoter,
  loginVoter,
  getMe,
};
