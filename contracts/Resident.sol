// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AStates} from "./abstract/AStates.sol";
import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Government} from "./Government.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Utility} from "./abstract/Utility.sol";

contract Resident is AStates, Utility, ERC721URIStorage, Ownable {
    bool private s_isGovernmentContractSet;
    State private immutable i_state;
    Government private s_governmentContract;
    uint256 private s_nextTokenId;
    mapping(address resident => bool isVerified) private s_isVerified;

    error NotVerifiedOfficial(address official);
    error NotOwnerOfTokenId(address resident, uint256 tokenId);
    error GovernmentContractAlreadySet(address governmentContract);
    error ResidentNotVerified(address resident);

    modifier onlyVerifiedOfficial() {
        if (s_governmentContract.isVerifiedOfficial(msg.sender)) revert NotVerifiedOfficial(msg.sender);
        _;
    }

    constructor(
        State _state,
        string memory _stateName,
        string memory _stateSymbol
    ) ERC721(_stateName, _stateSymbol) Ownable(msg.sender) {
        s_isGovernmentContractSet = false;
        i_state = _state;
        s_nextTokenId = 0;
    }

    function setGovernmentContract(address _governmentContract) external onlyOwner {
        if (s_isGovernmentContractSet) revert GovernmentContractAlreadySet(address(s_governmentContract));
        s_governmentContract = Government(_governmentContract);
        s_isGovernmentContractSet = true;
    }

    function registerAsResident(string memory _metadata) external {
        uint256 tokenId = ++s_nextTokenId;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, _metadata);
    }

    function verifyResident(
        address _resident,
        uint256 _tokenId
    ) external onlyVerifiedOfficial notZeroAddress(_resident) notZeroTokenId(_tokenId) {
        if (ownerOf(_tokenId) != _resident) revert NotOwnerOfTokenId(_resident, _tokenId);
        s_isVerified[_resident] = true;
    }

    function getNextTokenId() external view returns (uint256) {
        return s_nextTokenId + 1;
    }

    function isVerifiedResident(address _resident) external view returns (bool) {
        return s_isVerified[_resident];
    }

    function getGovernmentContract() external view returns (Government) {
        return s_governmentContract;
    }
}
