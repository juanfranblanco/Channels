pragma solidity ^0.6.1;

contract SignatureChecker
{
    address owner = msg.sender;

    mapping(uint256 => bool) usedNonces;

    constructor() public payable {}

    function getSignerAddressFromFixedMessageAndSignature(bytes memory signature) public pure returns (address)
    {
        // this recreates the message that was signed on the client
        bytes32 messageAsClient = prefixed(keccak256(abi.encodePacked("test message 1234567890")));

        return recoverSigner(messageAsClient, signature);
    }
    
    function getSignerAddressFromMessageAndSignature(string memory message, bytes memory signature) public pure returns (address)
    {
        // this recreates the message that was signed on the client
        bytes32 messageAsClient = prefixed(keccak256(abi.encodePacked(message)));

        return recoverSigner(messageAsClient, signature);
    }

    // signature methods
    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);
        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig) public pure returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    // builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32)
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}