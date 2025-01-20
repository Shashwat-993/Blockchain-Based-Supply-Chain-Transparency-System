const Web3 = require('web3');
const fs = require('fs');

// Connect to local Ethereum node
const web3 = new Web3('http://localhost:8545');

// Load contract ABI and address
const contractABI = require('../build/contracts/SupplyChain.json').abi;
const contractAddress = 'YOUR_CONTRACT_ADDRESS'; // Replace with actual deployed contract address

// Load sample data
const products = require('../sample-data/products.json').products;
const stakeholders = require('../sample-data/stakeholders.json').stakeholders;
const transactions = require('../sample-data/transactions.json').transactions;
const qualityChecks = require('../sample-data/quality_checks.json').qualityChecks;

// Initialize contract
const supplyChainContract = new web3.eth.Contract(contractABI, contractAddress);

async function loadSampleData() {
    try {
        const accounts = await web3.eth.getAccounts();
        const adminAccount = accounts[0];

        console.log('Loading sample data...');

        // Add stakeholders
        for (const stakeholder of stakeholders) {
            await supplyChainContract.methods.addStakeholder(
                stakeholder.id,
                stakeholder.name,
                stakeholder.type,
                stakeholder.ethereumAddress
            ).send({ from: adminAccount });
            console.log(`Added stakeholder: ${stakeholder.name}`);
        }

        // Add products
        for (const product of products) {
            await supplyChainContract.methods.addProduct(
                product.id,
                product.name,
                product.description,
                product.manufacturer,
                product.price
            ).send({ from: adminAccount });
            console.log(`Added product: ${product.name}`);
        }

        // Process transactions
        for (const transaction of transactions) {
            await supplyChainContract.methods.recordTransaction(
                transaction.id,
                transaction.productId,
                transaction.fromStakeholder,
                transaction.toStakeholder,
                transaction.quantity,
                transaction.price
            ).send({ from: adminAccount });
            console.log(`Recorded transaction: ${transaction.id}`);
        }

        // Record quality checks
        for (const check of qualityChecks) {
            await supplyChainContract.methods.recordQualityCheck(
                check.id,
                check.productId,
                check.status,
                check.parameters.quality_grade,
                check.notes
            ).send({ from: adminAccount });
            console.log(`Recorded quality check: ${check.id}`);
        }

        console.log('Sample data loaded successfully!');
    } catch (error) {
        console.error('Error loading sample data:', error);
    }
}

// Execute the loading function
loadSampleData();