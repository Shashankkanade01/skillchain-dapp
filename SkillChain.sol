// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ============================================================
//  SkillChain — Decentralized Professional Portfolio Registry
//  Author: Your Name
//  Network: Sepolia Testnet
//  Description: Register projects on-chain, mint NFT badges,
//               earn reputation, and gate premium content.
// ============================================================

contract SkillChain {

    // ─────────────────────────────────────────────
    //  STATE VARIABLES
    //  These are permanently stored on the blockchain
    // ─────────────────────────────────────────────

    address public owner;           // The person who deployed this contract (admin)
    uint256 public projectCount;    // Total number of projects registered
    uint256 public badgeCount;      // Total number of NFT badges minted

    // ─────────────────────────────────────────────
    //  DATA STRUCTURES
    //  Structs = custom data types (like objects)
    // ─────────────────────────────────────────────

    struct Project {
        uint256 id;             // Unique project ID (auto-incremented)
        address owner;          // Wallet address of creator
        string ipfsHash;        // IPFS CID — points to actual file stored off-chain
        string title;           // Project title
        string category;        // e.g. "Machine Learning", "Web3", "Research"
        uint256 timestamp;      // Block timestamp — when it was registered
        bool isPremium;         // If true, others must pay to access
        uint256 accessPrice;    // Price in wei to access (if premium)
        bool isVerified;        // Admin-endorsed flag
    }

    struct SkillBadge {
        uint256 tokenId;        // Unique badge ID
        address recipient;      // Who received this badge
        string category;        // Skill category the badge represents
        uint256 issuedAt;       // When it was minted
    }

    struct UserProfile {
        bool exists;            // Has this wallet ever registered?
        uint256 reputationScore; // Increases with every project + endorsement
        uint256 projectsCount;   // How many projects this user has registered
        uint256 badgesEarned;    // How many NFT badges this user has
    }

    // ─────────────────────────────────────────────
    //  MAPPINGS
    //  Mappings = key-value stores (like dictionaries)
    // ─────────────────────────────────────────────

    mapping(uint256 => Project)       public projects;          // projectId => Project
    mapping(address => uint256[])     public userProjects;      // wallet => list of their project IDs
    mapping(address => UserProfile)   public userProfiles;      // wallet => their profile
    mapping(uint256 => SkillBadge)    public badges;            // badgeId => Badge
    mapping(address => uint256[])     public userBadges;        // wallet => list of their badge IDs
    mapping(address => mapping(uint256 => bool)) public hasAccess; // wallet => projectId => paid access?

    // ─────────────────────────────────────────────
    //  EVENTS
    //  Events = logs emitted to the blockchain
    //  They don't cost much gas and are indexed
    // ─────────────────────────────────────────────

    event ProjectRegistered(
        uint256 indexed projectId,
        address indexed owner,
        string title,
        string ipfsHash,
        uint256 timestamp
    );

    event SkillBadgeMinted(
        uint256 indexed tokenId,
        address indexed recipient,
        string category,
        uint256 issuedAt
    );

    event ProjectEndorsed(
        uint256 indexed projectId,
        address indexed endorsedBy,
        uint256 newReputation
    );

    event PremiumAccessGranted(
        address indexed user,
        uint256 indexed projectId,
        uint256 amountPaid
    );

    event ReputationUpdated(
        address indexed user,
        uint256 newScore
    );

    event ContractPaused(address by);
    event ContractUnpaused(address by);

    // ─────────────────────────────────────────────
    //  MODIFIERS
    //  Modifiers = reusable conditions/guards
    //  They run BEFORE the function executes
    // ─────────────────────────────────────────────

    bool public paused = false;

    // Only the contract deployer (admin) can call this function
    modifier onlyOwner() {
        require(msg.sender == owner, "SkillChain: You are not the admin");
        _;  // <-- this means "now run the actual function"
    }

    // Block all transactions if contract is paused
    modifier whenNotPaused() {
        require(!paused, "SkillChain: Contract is currently paused");
        _;
    }

    // Make sure project exists
    modifier projectExists(uint256 _id) {
        require(_id > 0 && _id <= projectCount, "SkillChain: Project does not exist");
        _;
    }

    // ─────────────────────────────────────────────
    //  CONSTRUCTOR
    //  Runs ONCE when contract is deployed
    // ─────────────────────────────────────────────

    constructor() {
        owner = msg.sender;   // Whoever deploys = admin
        projectCount = 0;
        badgeCount = 0;
    }

    // ============================================================
    //  SECTION 1 — USER REGISTRATION & PROFILE
    // ============================================================

    // Creates a profile for new users automatically
    // Called internally — not directly by users
    function _createProfileIfNew(address _user) internal {
        if (!userProfiles[_user].exists) {
            userProfiles[_user] = UserProfile({
                exists: true,
                reputationScore: 0,
                projectsCount: 0,
                badgesEarned: 0
            });
        }
    }

    // ============================================================
    //  SECTION 2 — REGISTER A PROJECT
    //  This is the main function users will call
    // ============================================================

    function registerProject(
        string memory _ipfsHash,    // IPFS hash of your uploaded file
        string memory _title,       // Name of your project
        string memory _category,    // e.g. "Web3", "ML", "Research"
        bool _isPremium,            // Is it behind a paywall?
        uint256 _accessPrice        // Price in wei (0 if not premium)
    ) external whenNotPaused {

        // Input validation — all requires must pass or transaction fails
        require(bytes(_ipfsHash).length > 0,  "SkillChain: IPFS hash cannot be empty");
        require(bytes(_title).length > 0,     "SkillChain: Title cannot be empty");
        require(bytes(_category).length > 0,  "SkillChain: Category cannot be empty");
        if (_isPremium) {
            require(_accessPrice > 0, "SkillChain: Premium project must have a price");
        }

        // Auto-create profile if first time
        _createProfileIfNew(msg.sender);

        // Increment project counter and assign new ID
        projectCount++;
        uint256 newId = projectCount;

        // Store the project on-chain
        projects[newId] = Project({
            id:          newId,
            owner:       msg.sender,
            ipfsHash:    _ipfsHash,
            title:       _title,
            category:    _category,
            timestamp:   block.timestamp,   // Current block time
            isPremium:   _isPremium,
            accessPrice: _accessPrice,
            isVerified:  false              // Not verified yet — admin must endorse
        });

        // Link project to the user's list
        userProjects[msg.sender].push(newId);

        // Update user profile stats
        userProfiles[msg.sender].projectsCount++;
        userProfiles[msg.sender].reputationScore += 10; // +10 rep per project

        // Emit event (logged on blockchain forever)
        emit ProjectRegistered(newId, msg.sender, _title, _ipfsHash, block.timestamp);
        emit ReputationUpdated(msg.sender, userProfiles[msg.sender].reputationScore);

        // Auto-mint a skill badge for this contribution
        _mintSkillBadge(msg.sender, _category);
    }

    // ============================================================
    //  SECTION 3 — MINT NFT SKILL BADGE
    //  Called automatically after registerProject
    //  Internal = only this contract can call it
    // ============================================================

    function _mintSkillBadge(address _recipient, string memory _category) internal {

        badgeCount++;
        uint256 newTokenId = badgeCount;

        // Store badge on-chain
        badges[newTokenId] = SkillBadge({
            tokenId:   newTokenId,
            recipient: _recipient,
            category:  _category,
            issuedAt:  block.timestamp
        });

        // Link badge to user
        userBadges[_recipient].push(newTokenId);

        // Update profile
        userProfiles[_recipient].badgesEarned++;

        // Emit event
        emit SkillBadgeMinted(newTokenId, _recipient, _category, block.timestamp);
    }

    // ============================================================
    //  SECTION 4 — PREMIUM ACCESS
    //  Pay ETH to unlock a premium project
    // ============================================================

    function accessPremiumProject(uint256 _projectId)
        external
        payable
        whenNotPaused
        projectExists(_projectId)
    {
        Project storage p = projects[_projectId];

        // Must be a premium project
        require(p.isPremium, "SkillChain: This project is free - no payment needed");

        // You can't pay to access your own project
        require(p.owner != msg.sender, "SkillChain: You already own this project");

        // Must not have already paid
        require(!hasAccess[msg.sender][_projectId], "SkillChain: You already have access");

        // Must send exact price
        require(msg.value == p.accessPrice, "SkillChain: Incorrect payment amount");

        // ── CHECK-EFFECTS-INTERACTION PATTERN ──
        // 1. CHECK:   All requires above
        // 2. EFFECTS: Update state BEFORE sending money (prevents reentrancy attacks)
        hasAccess[msg.sender][_projectId] = true;

        // 3. INTERACT: Now send ETH to project owner
        (bool sent, ) = payable(p.owner).call{value: msg.value}("");
        require(sent, "SkillChain: ETH transfer failed");

        // Give the buyer some reputation too
        _createProfileIfNew(msg.sender);
        userProfiles[msg.sender].reputationScore += 2; // +2 rep for accessing content

        emit PremiumAccessGranted(msg.sender, _projectId, msg.value);
    }

    // ============================================================
    //  SECTION 5 — ADMIN: ENDORSE A PROJECT
    //  Only the contract owner (admin) can verify projects
    // ============================================================

    function endorseProject(uint256 _projectId)
        external
        onlyOwner
        projectExists(_projectId)
    {
        Project storage p = projects[_projectId];

        // Can't endorse the same project twice
        require(!p.isVerified, "SkillChain: Project is already verified");

        // Mark as verified
        p.isVerified = true;

        // Big reputation boost for getting endorsed
        userProfiles[p.owner].reputationScore += 50; // +50 rep for endorsement

        emit ProjectEndorsed(_projectId, msg.sender, userProfiles[p.owner].reputationScore);
        emit ReputationUpdated(p.owner, userProfiles[p.owner].reputationScore);
    }

    // ============================================================
    //  SECTION 6 — VIEW FUNCTIONS
    //  These are FREE to call — no gas needed
    //  "view" means they only READ, never WRITE
    // ============================================================

    // Get all project IDs for a wallet address
    function getUserPortfolio(address _user)
        external
        view
        returns (uint256[] memory)
    {
        return userProjects[_user];
    }

    // Get reputation score of any wallet
    function getReputation(address _user)
        external
        view
        returns (uint256)
    {
        return userProfiles[_user].reputationScore;
    }

    // Get full details of a project by ID
    function getProject(uint256 _projectId)
        external
        view
        projectExists(_projectId)
        returns (
            uint256 id,
            address projectOwner,
            string memory title,
            string memory category,
            string memory ipfsHash,
            uint256 timestamp,
            bool isPremium,
            uint256 accessPrice,
            bool isVerified
        )
    {
        Project storage p = projects[_projectId];

        // If premium and caller hasn't paid and isn't the owner — hide IPFS hash
        string memory hashToReturn = p.ipfsHash;
        if (p.isPremium && p.owner != msg.sender && !hasAccess[msg.sender][_projectId]) {
            hashToReturn = "PREMIUM_LOCKED";
        }

        return (
            p.id,
            p.owner,
            p.title,
            p.category,
            hashToReturn,
            p.timestamp,
            p.isPremium,
            p.accessPrice,
            p.isVerified
        );
    }

    // Get all badges of a user
    function getUserBadges(address _user)
        external
        view
        returns (uint256[] memory)
    {
        return userBadges[_user];
    }

    // Get full profile of a user
    function getUserProfile(address _user)
        external
        view
        returns (
            uint256 reputationScore,
            uint256 projectsCount,
            uint256 badgesEarned
        )
    {
        UserProfile storage profile = userProfiles[_user];
        return (
            profile.reputationScore,
            profile.projectsCount,
            profile.badgesEarned
        );
    }

    // Get total platform stats
    function getPlatformStats()
        external
        view
        returns (uint256 totalProjects, uint256 totalBadges)
    {
        return (projectCount, badgeCount);
    }

    // ============================================================
    //  SECTION 7 — ADMIN: EMERGENCY CONTROLS
    // ============================================================

    function pauseContract() external onlyOwner {
        require(!paused, "SkillChain: Already paused");
        paused = true;
        emit ContractPaused(msg.sender);
    }

    function unpauseContract() external onlyOwner {
        require(paused, "SkillChain: Not paused");
        paused = false;
        emit ContractUnpaused(msg.sender);
    }

    // Prevent accidental ETH sends directly to contract
    receive() external payable {
        revert("SkillChain: Direct ETH not accepted");
    }
}