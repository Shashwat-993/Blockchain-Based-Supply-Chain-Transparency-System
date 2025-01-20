# Blockchain-Based Supply Chain Transparency System

A robust, blockchain-based platform designed to track products throughout their entire supply chain lifecycle, ensuring transparency, traceability, and security in supply chain operations.

![Supply Chain](https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&q=80)

## Features

- **Product Tracking**: Real-time tracking of products from raw material sourcing to final delivery
- **Authenticity Verification**: Blockchain-based verification system to prevent counterfeiting
- **Quality Control**: Comprehensive quality check system with parameter tracking
- **Shipment Management**: End-to-end shipment tracking with transit points
- **Role-Based Access**: Granular access control for different stakeholders
- **Location Tracking**: Real-time location updates with facility information
- **Certification Management**: Track and verify product certifications
- **Product Recall**: Efficient product recall system with reason tracking
- **Audit Trail**: Complete history of product movements and changes

## Technology Stack

- Solidity ^0.8.0
- OpenZeppelin Contracts
- Hardhat/Truffle Development Framework
- Web3.js/Ethers.js
- Node.js

## Smart Contract Architecture

### Core Components

1. **Roles**
   - Admin
   - Manufacturer
   - Distributor
   - Retailer
   - Quality Inspector

2. **Data Structures**
   - Product
   - Shipment
   - Quality Check
   - Location

3. **Key Features**
   - Role-based access control
   - Non-reentrant function protection
   - Pausable contract functionality
   - Event logging
   - Comprehensive error handling

## Installation

1. Clone the repository:
\`\`\`bash
git clone https://github.com/yourusername/supply-chain-transparency.git
cd supply-chain-transparency
\`\`\`

2. Install dependencies:
\`\`\`bash
npm install
\`\`\`

3. Configure environment:
\`\`\`bash
cp .env.example .env
# Edit .env with your configuration
\`\`\`

4. Compile contracts:
\`\`\`bash
npx hardhat compile
\`\`\`

5. Run tests:
\`\`\`bash
npx hardhat test
\`\`\`

## Usage

### Deploying the Contract

1. Deploy to local network:
\`\`\`bash
npx hardhat run scripts/deploy.js --network localhost
\`\`\`

2. Deploy to testnet:
\`\`\`bash
npx hardhat run scripts/deploy.js --network goerli
\`\`\`

### Interacting with the Contract

#### Creating a Product
\`\`\`javascript
const product = await supplyChain.createProduct(
    "Product Name",
    "Product Description",
    ethers.utils.parseEther("1.0"),
    "BATCH001",
    currentTimestamp,
    expiryTimestamp,
    location
);
\`\`\`

#### Creating a Shipment
\`\`\`javascript
const shipment = await supplyChain.createShipment(
    [productId1, productId2],
    receiverAddress,
    originLocation,
    destinationLocation
);
\`\`\`

#### Performing Quality Check
\`\`\`javascript
const qualityCheck = await supplyChain.performQualityCheck(
    productId,
    QualityCheckStatus.Passed,
    "Quality check notes",
    ["temperature", "humidity"],
    ["20°C", "65%"]
);
\`\`\`

## Testing

Run the test suite:
\`\`\`bash
npm test
\`\`\`

### Test Coverage

Generate test coverage report:
\`\`\`bash
npx hardhat coverage
\`\`\`

## Security Considerations

- Role-based access control
- Reentrancy protection
- Input validation
- Hash verification
- Batch number validation
- Price range validation
- Pausable functionality

## Contributing

1. Fork the repository
2. Create your feature branch (\`git checkout -b feature/AmazingFeature\`)
3. Commit your changes (\`git commit -m 'Add some AmazingFeature'\`)
4. Push to the branch (\`git push origin feature/AmazingFeature\`)
5. Open a Pull Request
## Getting Started

### Prerequisites

1. **Development Environment**:
   - Install [Node.js](https://nodejs.org/) (v14+ recommended).
   - Install npm (comes with Node.js).
   - Ethereum node (e.g., [Ganache](https://trufflesuite.com/ganache/)) or a test network.
2. **Tools**:
   - [Truffle](https://trufflesuite.com/) or [Hardhat](https://hardhat.org/) for contract deployment.
   - [Metamask](https://metamask.io/) for interacting with the blockchain.

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/blockchain-supply-chain-transparency.git
   cd blockchain-supply-chain-transparency
   ```

2. **Install Dependencies**
   - Navigate to the backend folder and install required modules:
     ```bash
     cd backend
     npm install
     ```

3. **Deploy Smart Contracts**
   - Compile and deploy contracts:
     - Using Truffle:
       ```bash
       truffle compile
       truffle migrate --network development
       ```
     - Using Hardhat:
       ```bash
       npx hardhat compile
       npx hardhat run scripts/deploy.js
       ```

4. **Start the Backend**
   ```bash
   node app.js
   ```

5. **Run the Frontend**
   - Open `frontend/index.html` in a browser.

### Sample Data Population

Run the script to populate the blockchain with sample data:
```bash
node scripts/populateBlockchain.js
```

## Usage

1. **Add a Product**:
   - Provide product name and description.
   - The blockchain records the product and assigns ownership.

2. **Transfer Ownership**:
   - Transfer product ownership to another stakeholder using their address.

3. **View Product History**:
   - View detailed product history, including all ownership transfers.

## Technologies Used

- **Frontend**: HTML, JavaScript
- **Backend**: Node.js, Express
- **Blockchain**: Solidity, Web3.js
- **Testing**: Ganache or Ethereum test networks

## Roadmap

- [ ] Integrate QR code scanning for product tracking.
- [ ] Add support for multi-chain networks.
- [ ] Develop a mobile-friendly version.
- [ ] Implement IoT device integration for automated data capture.

## License

This project is licensed under the [MIT License](./LICENSE).

## Contributions

We welcome contributions! To contribute:
1. Fork the repository.
2. Create a new branch for your feature/fix.
3. Submit a pull request with a detailed description.

## Contact

For questions or suggestions, feel free to reach out:
- **Email**: shashwatpal32@gmail.com
- **LinkedIn**: [Shashwat Pal](https://www.linkedin.com/in/shashwatpal/)

---

Happy coding!
```
