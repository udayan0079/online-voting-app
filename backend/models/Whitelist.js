const mongoose = require('mongoose');

const whitelistSchema = new mongoose.Schema(
  {
    orgId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Organization',
      required: [true, 'Organization is required'],
    },
    companyId: {
      type: String,
      required: [true, 'Company/Employee ID is required'],
      uppercase: true,
      trim: true,
    },
    name: {
      type: String,
      default: '',
      trim: true,
    },
    department: {
      type: String,
      default: '',
      trim: true,
    },
    isRegistered: {
      type: Boolean,
      default: false,
    },
    registeredUserId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    addedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
  },
  {
    timestamps: true,
  }
);

// In each organization, a company ID must be uniquely whitelisted
whitelistSchema.index({ orgId: 1, companyId: 1 }, { unique: true });

module.exports = mongoose.model('Whitelist', whitelistSchema);
