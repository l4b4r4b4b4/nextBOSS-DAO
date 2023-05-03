pragma solidity ^0.8.0;

contract UrbanPlanningAI {
    struct UrbanPlan {
        uint256 id;
        string name;
        string description;
        string dataURI;
        uint256 timestamp;
    }

    address public owner;
    uint256 private planCounter;
    mapping(uint256 => UrbanPlan) public urbanPlans;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
        planCounter = 0;
    }

    function createUrbanPlan(
        string memory _name,
        string memory _description,
        string memory _dataURI
    ) public onlyOwner returns (uint256) {
        uint256 newPlanId = ++planCounter;
        UrbanPlan memory newPlan = UrbanPlan(
            newPlanId,
            _name,
            _description,
            _dataURI,
            block.timestamp
        );
        urbanPlans[newPlanId] = newPlan;

        return newPlanId;
    }

    function updateUrbanPlan(
        uint256 _planId,
        string memory _name,
        string memory _description,
        string memory _dataURI
    ) public onlyOwner {
        require(urbanPlans[_planId].id != 0, "Urban plan does not exist.");
        urbanPlans[_planId].name = _name;
        urbanPlans[_planId].description = _description;
        urbanPlans[_planId].dataURI = _dataURI;
        urbanPlans[_planId].timestamp = block.timestamp;
    }

    function getUrbanPlan(
        uint256 _planId
    ) public view returns (UrbanPlan memory) {
        require(urbanPlans[_planId].id != 0, "Urban plan does not exist.");
        return urbanPlans[_planId];
    }
}
