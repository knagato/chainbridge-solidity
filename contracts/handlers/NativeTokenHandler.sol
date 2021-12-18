// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./HandlerHelpers.sol";

/**
    @title Handles NativeToken deposits and deposit executions.
    @author knagato
    @notice This contract is intended to be used with the Bridge contract.
 */
contract NativeTokenHandler {
    address public immutable _bridgeAddress;

    event  Deposit(address indexed dst, uint wad);
    event  Transfer(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    modifier onlyBridge() {
        _onlyBridge();
        _;
    }

    function _onlyBridge() private view {
        require(msg.sender == _bridgeAddress, "sender must be bridge contract");
    }
    /**
        @param bridgeAddress Contract address of previously deployed Bridge.
     */
    constructor(
        address          bridgeAddress
    ) public {
        _bridgeAddress = bridgeAddress;
    }

    /**
        @notice A deposit is initiatied by making a deposit in the Bridge contract.
        @param depositer Address of account making the deposit in the Bridge contract.
        @return an empty data.
     */
    function deposit(
        address depositer
    ) external onlyBridge payable returns (bytes memory) {
        emit Deposit(depositer, msg.value);
    }

    /**
        @notice Proposal execution should be initiated when a proposal is finalized in the Bridge contract.
        by a relayer on the deposit's destination chain.
        @param data Consists of {recipient}, and {amount} all padded to 32 bytes.
        @notice Data passed into the function should be constructed as follows:
        recipient                              address     bytes  0 - 32
        amount                                 uint        bytes  32 - 64
     */
    function executeProposal(bytes calldata data) external onlyBridge {
        address payable recipient;
        uint amount;

        (recipient, amount) = abi.decode(data, (address, uint));

        recipient.transfer(amount);

        emit Transfer(recipient, amount);
    }

    /**
        @notice Used to manually release tokens.
        @param data Consists of {recipient}, and {amount} all padded to 32 bytes.
        @notice Data passed into the function should be constructed as follows:
        recipient                              address     bytes  0 - 32
        amount                                 uint        bytes  32 - 64
     */
    function withdraw(bytes memory data) external onlyBridge {
        address payable recipient;
        uint amount;

        (recipient, amount) = abi.decode(data, (address, uint));

        recipient.transfer(amount);

        emit Withdrawal(recipient, amount);
    }
}
