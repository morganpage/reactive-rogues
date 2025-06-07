// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../lib/reactive-lib/src/abstract-base/AbstractCallback.sol";
import {IERC1155} from "../lib/openzeppelin-contracts/contracts/token/ERC1155/IERC1155.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

// Define custom interface for external ERC1155 contract (with mint function)
interface IExternalERC1155 is IERC1155 {
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
}

contract MintNFTCallback is AbstractCallback, Ownable {
    IExternalERC1155 public externalERC1155;

    event CallbackReceived(
        address indexed newNFTOwner,
        uint256 indexed tokenId
    );

    constructor(
        address _callback_sender,
        address _externalERC1155Address
    ) payable Ownable(msg.sender) AbstractCallback(_callback_sender) {
        externalERC1155 = IExternalERC1155(_externalERC1155Address);
    }

    function setExternalERC1155(
        address _externalERC1155Address
    ) public onlyOwner {
        externalERC1155 = IExternalERC1155(_externalERC1155Address);
    }

    //event EarnedNFT(address indexed user, uint256 tokenId);
    function callback(
        address sender,
        address newNFTOwner,
        uint256 tokenId
    ) external authorizedSenderOnly rvmIdOnly(sender) {
        emit CallbackReceived(newNFTOwner, tokenId);
        externalERC1155.mint(newNFTOwner, tokenId, 1, "");
    }
}
