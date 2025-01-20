const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AdvancedSupplyChain", function () {
    let AdvancedSupplyChain, advancedSupplyChain, owner, addr1, addr2;

    beforeEach(async function () {
        AdvancedSupplyChain = await ethers.getContractFactory("AdvancedSupplyChain");
        [owner, addr1, addr2, _] = await ethers.getSigners();
        advancedSupplyChain = await AdvancedSupplyChain.deploy();
        await advancedSupplyChain.deployed();

        await advancedSupplyChain.grantRole(await advancedSupplyChain.MANUFACTURER_ROLE(), addr1.address);
        await advancedSupplyChain.grantRole(await advancedSupplyChain.DISTRIBUTOR_ROLE(), addr2.address);
    });

    describe("Product Creation", function () {
        it("Should create a new product", async function () {
            await advancedSupplyChain.connect(addr1).createProduct(
                "Test Product",
                "A test product",
                ethers.utils.parseEther("1")
            );
            const product = await advancedSupplyChain.getProduct(1);
            expect(product.name).to.equal("Test Product");
            expect(product.currentOwner).to.equal(addr1.address);
        });

        it("Should fail if non-manufacturer tries to create a product", async function () {
            await expect(
                advancedSupplyChain.connect(addr2).createProduct(
                    "Test Product",
                    "A test product",
                    ethers.utils.parseEther("1")
                )
            ).to.be.revertedWith("Unauthorized");
        });
    });

    describe("Product Transfer", function () {
        beforeEach(async function () {
            await advancedSupplyChain.connect(addr1).createProduct(
                "Test Product",
                "A test product",
                ethers.utils.parseEther("1")
            );
        });

        it("Should transfer a product", async function () {
            await advancedSupplyChain.connect(addr1).transferProduct(1, addr2.address);
            const product = await advancedSupplyChain.getProduct(1);
            expect(product.currentOwner).to.equal(addr2.address);
        });

        it("Should fail if non-owner tries to transfer a product", async function () {
            await expect(
                advancedSupplyChain.connect(addr2).transferProduct(1, owner.address)
            ).to.be.revertedWith("Unauthorized");
        });
    });

    describe("Product Status Update", function () {
        beforeEach(async function () {
            await advancedSupplyChain.connect(addr1).createProduct(
                "Test Product",
                "A test product",
                ethers.utils.parseEther("1")
            );
        });

        it("Should update product status", async function () {
            await advancedSupplyChain.connect(addr1).updateProductStatus(1, 1); // 1 is InTransit
            const product = await advancedSupplyChain.getProduct(1);
            expect(product.status).to.equal(1);
        });

        it("Should fail if trying to set an invalid status", async function () {
            await expect(
                advancedSupplyChain.connect(addr1).updateProductStatus(1, 0) // 0 is Created, which is the initial status
            ).to.be.revertedWith("InvalidStatus");
        });
    });

    describe("Quality Check", function () {
        beforeEach(async function () {
            await advancedSupplyChain.connect(addr1).createProduct(
                "Test Product",
                "A test product",
                ethers.utils.parseEther("1")
            );
        });

        it("Should perform a quality check", async function () {
            await advancedSupplyChain.performQualityCheck(1, 1, "Quality check passed"); // 1 is Passed
            const checks = await advancedSupplyChain.getQualityChecks(1);
            expect(checks[0].status).to.equal(1);
            expect(checks[0].notes).to.equal("Quality check passed");
        });

        it("Should fail if non-admin tries to perform quality check", async function () {
            await expect(
                advancedSupplyChain.connect(addr1).performQualityCheck(1, 1, "Quality check")
            ).to.be.revertedWith("Unauthorized");
        });
    });

    describe("Admin Functions", function () {
        it("Should pause and unpause the contract", async function () {
            await advancedSupplyChain.pause();
            await expect(
                advancedSupplyChain.connect(addr1).createProduct(
                    "Test Product",
                    "A test product",
                    ethers.utils.parseEther("1")
                )
            ).to.be.revertedWith("Pausable: paused");

            await advancedSupplyChain.unpause();
            await advancedSupplyChain.connect(addr1).createProduct(
                "Test Product",
                "A test product",
                ethers.utils.parseEther("1")
            );
        });
    });
});