const requireAdmin = (req, res, next) => {
  if (req.user && req.user.role === 'ADMIN') {
    return next();
  }
  return res.status(403).json({
    success: false,
    message: 'Access denied: Admin privilege required.',
  });
};

const requireVoter = (req, res, next) => {
  if (req.user && req.user.role === 'VOTER') {
    return next();
  }
  return res.status(403).json({
    success: false,
    message: 'Access denied: Voter privilege required.',
  });
};

module.exports = { requireAdmin, requireVoter };
