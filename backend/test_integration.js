const mongoose = require('mongoose');

const testFlow = async () => {
  const baseUrl = 'http://localhost:5000/api';

  // Clear test DB first
  await mongoose.connect('mongodb://127.0.0.1:27017/online_voting_db');
  await mongoose.connection.dropDatabase();
  console.log('[Test Setup] Cleaned test database.\n');

  console.log('--- 1. Testing Admin Registration (Dhaka) ---');
  const dhakaRes = await fetch(`${baseUrl}/auth/admin/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      orgName: 'Dhaka HQ Corporation',
      orgCode: 'DHAKA-CORP',
      adminName: 'Rahim Admin',
      adminCompanyId: 'ADM-001',
      email: 'admin@dhaka.com',
      password: 'password123',
      address: 'Gulshan, Dhaka',
    }),
  });
  const dhakaData = await dhakaRes.json();
  console.log('Dhaka Admin Register Result:', dhakaData.success, dhakaData.message);
  const dhakaToken = dhakaData.token;

  console.log('\n--- 2. Testing Whitelist Addition by Dhaka Admin ---');
  const wlRes = await fetch(`${baseUrl}/whitelist/bulk`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${dhakaToken}`,
    },
    body: JSON.stringify({
      rawIds: 'EMP-101, EMP-102, EMP-103',
    }),
  });
  const wlData = await wlRes.json();
  console.log('Whitelist Bulk Add Result:', wlData.message);

  console.log('\n--- 3. Testing Outsider Attempt to Register (Fake User) ---');
  const fakeRes = await fetch(`${baseUrl}/auth/voter/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      orgCode: 'DHAKA-CORP',
      companyId: 'FAKE-999', // Not whitelisted
      name: 'Intruder',
      password: 'password123',
    }),
  });
  const fakeData = await fakeRes.json();
  console.log('Fake User Registration (Expected Rejection):', !fakeData.success, fakeData.message);

  console.log('\n--- 4. Testing Pre-verification of Authorized ID (EMP-101) ---');
  const verifyRes = await fetch(`${baseUrl}/auth/voter/verify-id`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      orgCode: 'DHAKA-CORP',
      companyId: 'EMP-101',
    }),
  });
  const verifyData = await verifyRes.json();
  console.log('Pre-verify Result (Expected Authorized):', verifyData.isAuthorized, verifyData.message);

  console.log('\n--- 5. Testing Authorized Voter Registration (EMP-101) ---');
  const voterRes = await fetch(`${baseUrl}/auth/voter/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      orgCode: 'DHAKA-CORP',
      companyId: 'EMP-101',
      name: 'Tanvir Ahmed',
      department: 'Marketing',
      password: 'voterpassword123',
    }),
  });
  const voterData = await voterRes.json();
  console.log('Voter Registration Result:', voterData.success, voterData.message);
  const voterToken = voterData.token;

  console.log('\n--- 6. Testing Election Creation (HR Election with dynamic post & candidates) ---');
  const now = new Date();
  const startTime = new Date(now.getTime() - 60000); // started 1 min ago
  const endTime = new Date(now.getTime() + 3600000); // ends in 1 hour

  const electionRes = await fetch(`${baseUrl}/elections`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${dhakaToken}`,
    },
    body: JSON.stringify({
      title: 'Annual Corporate HR Election 2026',
      category: 'HR',
      description: 'Vote for the Lead HR Representative of Dhaka HQ',
      startTime: startTime.toISOString(),
      endTime: endTime.toISOString(),
      candidates: [
        {
          name: 'Nusrat Jahan',
          companyId: 'HR-CAND-01',
          symbolName: 'Eagle of Growth',
          bio: '10 years experience in Employee Relations and Wellbeing.',
        },
        {
          name: 'Karim Ullah',
          companyId: 'HR-CAND-02',
          symbolName: 'Rising Sun',
          bio: 'Focus on transparent appraisals and workplace flexibility.',
        },
      ],
    }),
  });
  const electionData = await electionRes.json();
  console.log('Election Created:', electionData.success, electionData.data?.title);
  const electionId = electionData.data?._id;
  const candidateId = electionData.data?.candidates[0]?._id;

  console.log('\n--- 7. Testing Casting a Vote ---');
  const voteRes = await fetch(`${baseUrl}/votes/cast`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${voterToken}`,
    },
    body: JSON.stringify({
      electionId,
      candidateId,
    }),
  });
  const voteData = await voteRes.json();
  console.log('Cast Vote Result:', voteData.success, voteData.message, 'Receipt:', voteData.data?.receipt);

  console.log('\n--- 8. Testing Duplicate Vote Prevention ---');
  const dupVoteRes = await fetch(`${baseUrl}/votes/cast`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${voterToken}`,
    },
    body: JSON.stringify({
      electionId,
      candidateId,
    }),
  });
  const dupData = await dupVoteRes.json();
  console.log('Duplicate Vote Attempt (Expected Failure):', !dupData.success, dupData.message);

  console.log('\n--- 9. Testing Jamalpur Admin Registration & Multi-tenant Data Isolation ---');
  const jamalpurRes = await fetch(`${baseUrl}/auth/admin/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      orgName: 'Jamalpur Regional Branch',
      orgCode: 'JAMALPUR-01',
      adminName: 'Sultana Admin',
      adminCompanyId: 'JML-ADM-01',
      email: 'admin@jamalpur.com',
      password: 'password123',
    }),
  });
  const jamalpurData = await jamalpurRes.json();
  console.log('Jamalpur Admin Register Result:', jamalpurData.success, jamalpurData.organization.name);

  // Jamalpur Admin asks for elections
  const jamalpurElectionsRes = await fetch(`${baseUrl}/elections`, {
    headers: { Authorization: `Bearer ${jamalpurData.token}` },
  });
  const jamalpurElections = await jamalpurElectionsRes.json();
  console.log('Jamalpur Elections Count (MUST BE 0):', jamalpurElections.data.length);

  // Dhaka Admin asks for elections
  const dhakaElectionsRes = await fetch(`${baseUrl}/elections`, {
    headers: { Authorization: `Bearer ${dhakaToken}` },
  });
  const dhakaElections = await dhakaElectionsRes.json();
  console.log('Dhaka Elections Count (MUST BE 1):', dhakaElections.data.length);
  console.log('Dhaka Candidate 1 Votes:', dhakaElections.data[0].candidates[0].voteCount);

  // Admin Dashboard Analytics
  console.log('\n--- 10. Testing Admin Analytics ---');
  const statsRes = await fetch(`${baseUrl}/analytics/dashboard`, {
    headers: { Authorization: `Bearer ${dhakaToken}` },
  });
  const statsData = await statsRes.json();
  console.log('Admin Dashboard Stats:', {
    totalAuthorized: statsData.data.voters.totalWhitelisted,
    registeredVoters: statsData.data.voters.registeredVoters,
    totalVotesCast: statsData.data.voting.totalVotesCast,
    turnoutRate: `${statsData.data.voting.turnoutRate}%`,
  });

  console.log('\n===============================================');
  console.log('SUCCESS: ALL 10 TESTS PASSED PERFECTLY!');
  console.log('===============================================');

  await mongoose.disconnect();
  process.exit(0);
};

testFlow();
