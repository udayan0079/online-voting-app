const mongoose = require('mongoose');

const candidateSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Candidate name is required'],
      trim: true,
    },
    companyId: {
      type: String,
      required: [true, 'Candidate company ID is required'],
      uppercase: true,
      trim: true,
    },
    photoUrl: {
      type: String,
      default: '',
    },
    logoUrl: {
      type: String,
      default: '',
    },
    symbolName: {
      type: String,
      default: '',
      trim: true,
    },
    bio: {
      type: String,
      default: '',
      trim: true,
    },
    voteCount: {
      type: Number,
      default: 0,
      min: 0,
    },
  },
  {
    timestamps: true,
  }
);

const electionSchema = new mongoose.Schema(
  {
    orgId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Organization',
      required: [true, 'Organization ID is required'],
    },
    title: {
      type: String,
      required: [true, 'Election title is required'],
      trim: true,
    },
    category: {
      type: String,
      required: [true, 'Designation / Post / Category is required (e.g., HR, CR, President, MP)'],
      trim: true,
    },
    description: {
      type: String,
      default: '',
      trim: true,
    },
    startTime: {
      type: Date,
      required: [true, 'Voting start time is required'],
    },
    endTime: {
      type: Date,
      required: [true, 'Voting end time is required'],
    },
    candidates: [candidateSchema],
    totalVotes: {
      type: Number,
      default: 0,
      min: 0,
    },
    isManualClosed: {
      type: Boolean,
      default: false,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Virtual for real-time status determination
electionSchema.virtual('status').get(function () {
  if (this.isManualClosed) return 'COMPLETED';
  const now = new Date();
  if (now < this.startTime) return 'UPCOMING';
  if (now >= this.startTime && now <= this.endTime) return 'ACTIVE';
  return 'COMPLETED';
});

// Index by organization to ensure fast multi-tenant isolation
electionSchema.index({ orgId: 1, createdAt: -1 });

module.exports = mongoose.model('Election', electionSchema);
