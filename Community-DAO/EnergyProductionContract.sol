pragma solidity ^0.8.0;

contract EnergyProduction {
    struct ProductionSystem {
        uint256 id;
        string systemType;
        uint256 capacity;
        address owner;
        bool isActive;
    }

    struct EnergyRecord {
        uint256 systemId;
        uint256 timestamp;
        uint256 energyProduced;
    }

    address public contractOwner;
    uint256 private systemCounter;
    uint256 private recordCounter;

    mapping(uint256 => ProductionSystem) public productionSystems;
    mapping(uint256 => EnergyRecord) public energyRecords;

    modifier onlyOwner() {
        require(
            msg.sender == contractOwner,
            "Only the contract owner can perform this action."
        );
        _;
    }

    modifier onlySystemOwner(uint256 _systemId) {
        require(
            productionSystems[_systemId].owner == msg.sender,
            "Only the system owner can perform this action."
        );
        _;
    }

    constructor() {
        contractOwner = msg.sender;
        systemCounter = 0;
        recordCounter = 0;
    }

    // Register a new energy production system
    function registerSystem(
        string memory _systemType,
        uint256 _capacity
    ) public returns (uint256) {
        uint256 newSystemId = ++systemCounter;
        productionSystems[newSystemId] = ProductionSystem(
            newSystemId,
            _systemType,
            _capacity,
            msg.sender,
            true
        );
        return newSystemId;
    }

    // Update energy production system status
    function updateSystemStatus(
        uint256 _systemId,
        bool _isActive
    ) public onlySystemOwner(_systemId) {
        productionSystems[_systemId].isActive = _isActive;
    }

    // Record energy production
    function recordEnergyProduction(
        uint256 _systemId,
        uint256 _energyProduced
    ) public onlySystemOwner(_systemId) {
        uint256 newRecordId = ++recordCounter;
        energyRecords[newRecordId] = EnergyRecord(
            _systemId,
            block.timestamp,
            _energyProduced
        );
    }

    // Implement energy allocation, consumption monitoring, and incentives based on your specific requirements
    // You can customize the contract further by integrating it with a token system or other mechanisms
}
