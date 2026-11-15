const jwt = require('jsonwebtoken');

const generateToken = (user) => {
  return jwt.sign(
    {
      id: user._id,
      role: user.role,
      orgId: user.orgId,
      companyId: user.companyId,
      name: user.name,
    },
    process.env.JWT_SECRET || 'corporate_online_voting_super_secret_key_2026',
    {
      expiresIn: process.env.JWT_EXPIRE || '7d',
    }
  );
};

module.exports = generateToken;
