pragma solidity 0.8.0;

import "./ForgeBond.sol";
import "./interfaces/ITokenRegistry.sol";
import "./tokens/ForgeBond.sol";
import "./ForgeInstrumentRegistry.sol";

contract ForgeStructuredProductFactory is ForgeBond {
    constructor(address owner) public ForgeBond(owner) {}

    function createStructuredProduct()
        public
        view
        onlyOwner
        returns (string memory)
    {
        return "Expected to fail";
    }
}
