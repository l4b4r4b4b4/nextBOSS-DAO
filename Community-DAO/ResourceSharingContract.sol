pragma solidity ^0.8.0;

contract ResourceSharing {
    struct Resource {
        uint256 id;
        string name;
        string description;
        address owner;
        bool isAvailable;
        bool isActive;
    }

    struct Reservation {
        uint256 id;
        uint256 resourceId;
        address reserver;
        uint256 startTime;
        uint256 endTime;
    }

    address public contractOwner;
    uint256 private resourceCounter;
    uint256 private reservationCounter;

    mapping(uint256 => Resource) public resources;
    mapping(uint256 => Reservation) public reservations;

    modifier onlyOwner() {
        require(
            msg.sender == contractOwner,
            "Only the contract owner can perform this action."
        );
        _;
    }

    modifier onlyResourceOwner(uint256 _resourceId) {
        require(
            resources[_resourceId].owner == msg.sender,
            "Only the resource owner can perform this action."
        );
        _;
    }

    constructor() {
        contractOwner = msg.sender;
        resourceCounter = 0;
        reservationCounter = 0;
    }

    // Register a new resource
    function registerResource(
        string memory _name,
        string memory _description
    ) public returns (uint256) {
        uint256 newResourceId = ++resourceCounter;
        resources[newResourceId] = Resource(
            newResourceId,
            _name,
            _description,
            msg.sender,
            true,
            true
        );
        return newResourceId;
    }

    // Update resource availability
    function updateResourceAvailability(
        uint256 _resourceId,
        bool _isAvailable
    ) public onlyResourceOwner(_resourceId) {
        resources[_resourceId].isAvailable = _isAvailable;
    }

    // Update resource status (e.g., maintenance, decommissioning)
    function updateResourceStatus(
        uint256 _resourceId,
        bool _isActive
    ) public onlyResourceOwner(_resourceId) {
        resources[_resourceId].isActive = _isActive;
    }

    // Check if a resource is available for reservation
    function isResourceAvailable(
        uint256 _resourceId,
        uint256 _startTime,
        uint256 _endTime
    ) public view returns (bool) {
        if (
            !resources[_resourceId].isActive ||
            !resources[_resourceId].isAvailable
        ) {
            return false;
        }

        for (uint256 i = 1; i <= reservationCounter; i++) {
            if (reservations[i].resourceId == _resourceId) {
                if (
                    (_startTime >= reservations[i].startTime &&
                        _startTime < reservations[i].endTime) ||
                    (_endTime > reservations[i].startTime &&
                        _endTime <= reservations[i].endTime)
                ) {
                    return false;
                }
            }
        }

        return true;
    }

    // Reserve a resource for a specific time period
    function reserveResource(
        uint256 _resourceId,
        uint256 _startTime,
        uint256 _endTime
    ) public returns (uint256) {
        require(_startTime < _endTime, "Invalid reservation time.");
        require(
            isResourceAvailable(_resourceId, _startTime, _endTime),
            "Resource is not available for the specified time period."
        );

        uint256 newReservationId = ++reservationCounter;
        reservations[newReservationId] = Reservation(
            newReservationId,
            _resourceId,
            msg.sender,
            _startTime,
            _endTime
        );
        return newReservationId;
    }

    // Cancel a reservation before the start time
    function cancelReservation(uint256 _reservationId) public {
        Reservation storage reservation = reservations[_reservationId];
        require(
            msg.sender == reservation.reserver,
            "Only the reserver can cancel the reservation."
        );
        require(
            block.timestamp < reservation.startTime,
            "Cannot cancel a reservation after its start time."
        );
        delete reservations[_reservationId];
    }

    // Implement penalties for misuse or damage of shared resources (to be customized based on your requirements)
    // For example, you could create a function to report misuse or integrate this with a reputation or token system
}
