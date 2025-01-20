// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title AdvancedSupplyChain
 * @dev A supply chain management system using blockchain
 */
contract AdvancedSupplyChain is AccessControl, ReentrancyGuard, Pausable {
    // Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANUFACTURER_ROLE = keccak256("MANUFACTURER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant RETAILER_ROLE = keccak256("RETAILER_ROLE");
    bytes32 public constant QUALITY_INSPECTOR_ROLE = keccak256("QUALITY_INSPECTOR_ROLE");

    // Enums
    enum ProductStatus { Created, InTransit, Stored, Delivered, Recalled }
    enum QualityCheckStatus { Pending, Passed, Failed }
    enum ShipmentStatus { Pending, InTransit, Delivered, Delayed, Cancelled }

    // Structs
    struct Product {
        string name;
        string description;
        uint256 price;
        address currentOwner;
        ProductStatus status;
        uint256 createdAt;
        uint256 updatedAt;
        QualityCheckStatus qualityStatus;
        string[] history;
        bytes32 productHash;
        string batchNumber;
        uint256 manufacturingDate;
        uint256 expiryDate;
        string[] certifications;
        Location currentLocation;
        bool isActive;
    }

    struct QualityCheck {
        uint256 productId;
        address inspector;
        QualityCheckStatus status;
        string notes;
        uint256 timestamp;
        mapping(string => string) parameters;
        bytes32 checkHash;
    }

    struct Location {
        string facility;
        string country;
        string region;
        int256 latitude;
        int256 longitude;
        uint256 timestamp;
    }

    struct Shipment {
        uint256 shipmentId;
        uint256[] productIds;
        address sender;
        address receiver;
        ShipmentStatus status;
        uint256 createdAt;
        uint256 deliveredAt;
        Location origin;
        Location destination;
        mapping(uint256 => Location) transitPoints;
        uint256 transitPointCount;
        bytes32 shipmentHash;
        bool isActive;
    }

    // State variables
    uint256 private _productIdCounter;
    uint256 private _shipmentIdCounter;
    mapping(uint256 => Product) private _products;
    mapping(uint256 => Shipment) private _shipments;
    mapping(uint256 => QualityCheck[]) private _qualityChecks;
    mapping(address => uint256[]) private _ownedProducts;
    mapping(bytes32 => bool) private _usedHashes;
    mapping(string => bool) private _usedBatchNumbers;

    // Constants
    uint256 private constant MAX_BATCH_SIZE = 1000;
    uint256 private constant MIN_PRICE = 0.001 ether;
    uint256 private constant MAX_PRICE = 1000000 ether;

    // Events
    event ProductCreated(uint256 indexed productId, string name, address owner, bytes32 productHash);
    event ProductTransferred(uint256 indexed productId, address indexed from, address indexed to);
    event ProductStatusUpdated(uint256 indexed productId, ProductStatus status);
    event QualityCheckPerformed(uint256 indexed productId, address inspector, QualityCheckStatus status, bytes32 checkHash);
    event PriceUpdated(uint256 indexed productId, uint256 newPrice);
    event ShipmentCreated(uint256 indexed shipmentId, address sender, address receiver, bytes32 shipmentHash);
    event ShipmentStatusUpdated(uint256 indexed shipmentId, ShipmentStatus status);
    event LocationUpdated(uint256 indexed productId, string facility, int256 latitude, int256 longitude);
    event ProductRecalled(uint256 indexed productId, string reason);
    event CertificationAdded(uint256 indexed productId, string certification);

    // Errors
    error Unauthorized();
    error ProductNotFound();
    error InvalidStatus();
    error InvalidPrice();
    error TransferToZeroAddress();
    error InvalidBatchNumber();
    error DuplicateHash();
    error InvalidLocation();
    error ShipmentNotFound();
    error ProductNotActive();
    error MaxBatchSizeExceeded();
    error InvalidTimeRange();
    error InvalidParameter();

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    // Modifiers
    modifier onlyProductOwner(uint256 productId) {
        if (_products[productId].currentOwner != msg.sender) {
            revert Unauthorized();
        }
        _;
    }

    modifier validProductId(uint256 productId) {
        if (productId == 0 || productId > _productIdCounter) {
            revert ProductNotFound();
        }
        if (!_products[productId].isActive) {
            revert ProductNotActive();
        }
        _;
    }

    modifier validShipmentId(uint256 shipmentId) {
        if (shipmentId == 0 || shipmentId > _shipmentIdCounter) {
            revert ShipmentNotFound();
        }
        if (!_shipments[shipmentId].isActive) {
            revert ProductNotActive();
        }
        _;
    }

    modifier validPrice(uint256 price) {
        if (price < MIN_PRICE || price > MAX_PRICE) {
            revert InvalidPrice();
        }
        _;
    }

    // Product Management Functions
    function createProduct(
        string memory name,
        string memory description,
        uint256 price,
        string memory batchNumber,
        uint256 manufacturingDate,
        uint256 expiryDate,
        Location memory location
    ) external whenNotPaused nonReentrant validPrice(price) {
        if (!hasRole(MANUFACTURER_ROLE, msg.sender)) {
            revert Unauthorized();
        }
        if (bytes(batchNumber).length == 0 || _usedBatchNumbers[batchNumber]) {
            revert InvalidBatchNumber();
        }
        if (manufacturingDate >= expiryDate || manufacturingDate < block.timestamp) {
            revert InvalidTimeRange();
        }

        _productIdCounter++;
        uint256 productId = _productIdCounter;

        bytes32 productHash = keccak256(abi.encodePacked(
            productId,
            name,
            batchNumber,
            manufacturingDate,
            msg.sender,
            block.timestamp
        ));

        if (_usedHashes[productHash]) {
            revert DuplicateHash();
        }

        Product storage newProduct = _products[productId];
        newProduct.name = name;
        newProduct.description = description;
        newProduct.price = price;
        newProduct.currentOwner = msg.sender;
        newProduct.status = ProductStatus.Created;
        newProduct.createdAt = block.timestamp;
        newProduct.updatedAt = block.timestamp;
        newProduct.qualityStatus = QualityCheckStatus.Pending;
        newProduct.productHash = productHash;
        newProduct.batchNumber = batchNumber;
        newProduct.manufacturingDate = manufacturingDate;
        newProduct.expiryDate = expiryDate;
        newProduct.currentLocation = location;
        newProduct.isActive = true;
        
        string[] memory initialHistory = new string[](1);
        initialHistory[0] = string(abi.encodePacked("Created by ", addressToString(msg.sender)));
        newProduct.history = initialHistory;

        _ownedProducts[msg.sender].push(productId);
        _usedHashes[productHash] = true;
        _usedBatchNumbers[batchNumber] = true;

        emit ProductCreated(productId, name, msg.sender, productHash);
        emit LocationUpdated(productId, location.facility, location.latitude, location.longitude);
    }

    function createShipment(
        uint256[] memory productIds,
        address receiver,
        Location memory origin,
        Location memory destination
    ) external whenNotPaused nonReentrant {
        if (!hasRole(DISTRIBUTOR_ROLE, msg.sender) && !hasRole(MANUFACTURER_ROLE, msg.sender)) {
            revert Unauthorized();
        }
        if (productIds.length == 0 || productIds.length > MAX_BATCH_SIZE) {
            revert MaxBatchSizeExceeded();
        }
        if (receiver == address(0)) {
            revert TransferToZeroAddress();
        }

        _shipmentIdCounter++;
        uint256 shipmentId = _shipmentIdCounter;

        bytes32 shipmentHash = keccak256(abi.encodePacked(
            shipmentId,
            productIds,
            msg.sender,
            receiver,
            block.timestamp
        ));

        if (_usedHashes[shipmentHash]) {
            revert DuplicateHash();
        }

        Shipment storage newShipment = _shipments[shipmentId];
        newShipment.shipmentId = shipmentId;
        newShipment.productIds = productIds;
        newShipment.sender = msg.sender;
        newShipment.receiver = receiver;
        newShipment.status = ShipmentStatus.Pending;
        newShipment.createdAt = block.timestamp;
        newShipment.origin = origin;
        newShipment.destination = destination;
        newShipment.shipmentHash = shipmentHash;
        newShipment.isActive = true;

        _usedHashes[shipmentHash] = true;

        emit ShipmentCreated(shipmentId, msg.sender, receiver, shipmentHash);
    }

    function updateShipmentStatus(
        uint256 shipmentId,
        ShipmentStatus status,
        Location memory currentLocation
    ) external whenNotPaused nonReentrant validShipmentId(shipmentId) {
        Shipment storage shipment = _shipments[shipmentId];
        
        if (msg.sender != shipment.sender && msg.sender != shipment.receiver) {
            revert Unauthorized();
        }

        shipment.status = status;
        if (status == ShipmentStatus.Delivered) {
            shipment.deliveredAt = block.timestamp;
        }

        shipment.transitPoints[shipment.transitPointCount++] = currentLocation;

        emit ShipmentStatusUpdated(shipmentId, status);
    }

    function performQualityCheck(
        uint256 productId,
        QualityCheckStatus status,
        string memory notes,
        string[] memory parameterNames,
        string[] memory parameterValues
    )
        external
        whenNotPaused
        nonReentrant
        validProductId(productId)
    {
        if (!hasRole(QUALITY_INSPECTOR_ROLE, msg.sender)) {
            revert Unauthorized();
        }
        if (parameterNames.length != parameterValues.length) {
            revert InvalidParameter();
        }

        bytes32 checkHash = keccak256(abi.encodePacked(
            productId,
            status,
            notes,
            msg.sender,
            block.timestamp
        ));

        QualityCheck memory check = QualityCheck({
            productId: productId,
            inspector: msg.sender,
            status: status,
            notes: notes,
            timestamp: block.timestamp,
            checkHash: checkHash
        });

        for (uint256 i = 0; i < parameterNames.length; i++) {
            check.parameters[parameterNames[i]] = parameterValues[i];
        }

        _qualityChecks[productId].push(check);
        _products[productId].qualityStatus = status;
        _products[productId].history.push(string(abi.encodePacked("Quality check performed by ", addressToString(msg.sender))));

        emit QualityCheckPerformed(productId, msg.sender, status, checkHash);
    }

    function recallProduct(
        uint256 productId,
        string memory reason
    )
        external
        whenNotPaused
        nonReentrant
        validProductId(productId)
    {
        if (!hasRole(ADMIN_ROLE, msg.sender) && !hasRole(MANUFACTURER_ROLE, msg.sender)) {
            revert Unauthorized();
        }

        Product storage product = _products[productId];
        product.status = ProductStatus.Recalled;
        product.history.push(string(abi.encodePacked("Recalled: ", reason)));

        emit ProductRecalled(productId, reason);
    }

    function addCertification(
        uint256 productId,
        string memory certification
    )
        external
        whenNotPaused
        nonReentrant
        validProductId(productId)
    {
        if (!hasRole(ADMIN_ROLE, msg.sender)) {
            revert Unauthorized();
        }

        Product storage product = _products[productId];
        product.certifications.push(certification);

        emit CertificationAdded(productId, certification);
    }

    // View Functions
    function getProduct(uint256 productId) 
        external 
        view 
        validProductId(productId) 
        returns (
            string memory name,
            string memory description,
            uint256 price,
            address currentOwner,
            ProductStatus status,
            uint256 createdAt,
            uint256 updatedAt,
            QualityCheckStatus qualityStatus,
            string[] memory history,
            bytes32 productHash,
            string memory batchNumber,
            uint256 manufacturingDate,
            uint256 expiryDate,
            string[] memory certifications,
            Location memory currentLocation
        ) 
    {
        Product storage product = _products[productId];
        return (
            product.name,
            product.description,
            product.price,
            product.currentOwner,
            product.status,
            product.createdAt,
            product.updatedAt,
            product.qualityStatus,
            product.history,
            product.productHash,
            product.batchNumber,
            product.manufacturingDate,
            product.expiryDate,
            product.certifications,
            product.currentLocation
        );
    }

    function getShipment(uint256 shipmentId)
        external
        view
        validShipmentId(shipmentId)
        returns (
            uint256[] memory productIds,
            address sender,
            address receiver,
            ShipmentStatus status,
            uint256 createdAt,
            uint256 deliveredAt,
            Location memory origin,
            Location memory destination,
            bytes32 shipmentHash
        )
    {
        Shipment storage shipment = _shipments[shipmentId];
        return (
            shipment.productIds,
            shipment.sender,
            shipment.receiver,
            shipment.status,
            shipment.createdAt,
            shipment.deliveredAt,
            shipment.origin,
            shipment.destination,
            shipment.shipmentHash
        );
    }

    function getShipmentTransitPoints(uint256 shipmentId)
        external
        view
        validShipmentId(shipmentId)
        returns (Location[] memory)
    {
        Shipment storage shipment = _shipments[shipmentId];
        Location[] memory transitPoints = new Location[](shipment.transitPointCount);
        
        for (uint256 i = 0; i < shipment.transitPointCount; i++) {
            transitPoints[i] = shipment.transitPoints[i];
        }
        
        return transitPoints;
    }

    // Internal Functions
    function removeFromOwnedProducts(address owner, uint256 productId) internal {
        uint256[] storage products = _ownedProducts[owner];
        for (uint256 i = 0; i < products.length; i++) {
            if (products[i] == productId) {
                products[i] = products[products.length - 1];
                products.pop();
                break;
            }
        }
    }

    // Utility Functions
    function addressToString(address _addr) internal pure returns (string memory) {
        bytes memory data = abi.encodePacked(_addr);
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(data[i] >> 4)];
            str[3+i*2] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }

    // Admin Functions
    function pause() external {
        if (!hasRole(ADMIN_ROLE, msg.sender)) {
            revert Unauthorized();
        }
        _pause();
    }

    function unpause() external {
        if (!hasRole(ADMIN_ROLE, msg.sender)) {
            revert Unauthorized();
        }
        _unpause();
    }
}