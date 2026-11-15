const mongoose = require('mongoose');
const crypto = require('crypto');

const voteSchema = new mongoose.Schema(
  {
    orgId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Organization',
      required: [true, 'Organization is required'],
    },
    electionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Election',
      required: [true, 'Election is required'],
    },
    voterId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Voter ID is required'],
    },
    voterCompanyId: {
      type: String,
      required: true,
      uppercase: true,
    },
    candidateId: {
      type: mongoose.Schema.Types.ObjectId,
      required: [true, 'Candidate selection is required'],
    },
    voteReceiptHash: {
      type: String,
    },
    votedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

// One voter can vote ONLY ONCE per election!
voteSchema.index({ electionId: 1, voterId: 1 }, { unique: true });
voteSchema.index({ orgId: 1, electionId: 1 });

// Generate a cryptographic audit receipt hash before saving
voteSchema.pre('save', function () {
  if (!this.voteReceiptHash) {
    const raw = `${this.orgId}-${this.electionId}-${this.voterId}-${this.candidateId}-${Date.now()}`;
    this.voteReceiptHash = 'VOTE-' + crypto.createHash('sha256').update(raw).digest('hex').substring(0, 16).toUpperCase();
  }
});

module.exports = mongoose.model('Vote', voteSchema);
