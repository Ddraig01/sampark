// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AStates} from "./abstract/AStates.sol";
import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Government} from "./Government.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Resident} from "./Resident.sol";

contract Proposal is AStates, Ownable, ERC721URIStorage {
    State private immutable i_state;
    Resident private s_residentContract;
    Government private s_governmentContract;
    uint256 s_areResidentAndGovernmentContractSet;

    error ALreadySet();

    constructor(
        State _state,
        string memory _stateName,
        string memory _stateSymbol
    ) ERC721(_stateName, _stateSymbol) Ownable(msg.sender) {
        i_state = _state;
        s_areResidentAndGovernmentContractSet = 2;
    }

    modifier onlyVerifiedResident() {
        _;
    }

    function setResidentContract(address _residentContract) external onlyOwner {
        if (s_areResidentAndGovernmentContractSet == 0) revert ALreadySet();
        s_residentContract = Resident(_residentContract);
        --s_areResidentAndGovernmentContractSet;
    }

    function setGovernmentContract(address _governmentContract) external onlyOwner {
        if (s_areResidentAndGovernmentContractSet == 0) revert ALreadySet();
        s_governmentContract = Government(_governmentContract);
        --s_areResidentAndGovernmentContractSet;
    }

    function getState() external view returns (State) {
        return i_state;
    }

    function getResidentContract() external view returns (Resident) {
        return s_residentContract;
    }

    function getGovernmentContract() external view returns (Government) {
        return s_governmentContract;
    }
}
