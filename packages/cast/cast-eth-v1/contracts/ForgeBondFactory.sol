pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;


/** this will work as bank, issuing the bonds based on  */

import "./ForgeBond.sol";
import "./tokens/ForgeBond.sol";
import "./ForgeInstrumentRegistry.sol";

contract ForgeBondFactory is ForgeBond {
    constructor(address owner) public ForgeBond(owner) {}

    function issueForgeBond(
        address registryAddress,
        BasicTokenLibrary.BasicTokenInput memory basicTokenInput
    ) public onlyOwner returns (address) {
        require(
            msg.sender == basicTokenInput.registrar,
            "Calling address should match registrar agent"
        );

        address result = address(new ForgeBond(basicTokenInput));

        ForgeInstrumentRegistry forgeInstrumentRegistry = ForgeInstrumentRegistry(
                registryAddress
            );

        forgeInstrumentRegistry.listInstrument(
            string(basicTokenInput.name),
            string(basicTokenInput.isinCode),
            result
        );

        emit InstrumentListed(result);

        return result;
    }

    event InstrumentListed(address _instrumentAddress);
}
