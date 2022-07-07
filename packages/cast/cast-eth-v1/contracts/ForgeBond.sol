pragma solidity 0.8.0;

import "./ForgeInstrumentRegistry.sol";
import "erc-3475/contracts/IERC3475.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

 contract ForgeBond is IERC3475 , Ownable {

    address issuer;

        /**
    * @notice this Struct is representing the Nonce properties as an object
    *         and can be retrieve by the nonceId (within a class)
    */
    struct Nonce {
        // id
        uint256 id;
        // already created.
        bool exists;
        uint256 _activeSupply;
        uint256 _burnedSupply;
        uint256 _redeemedSupply;
        mapping(uint256 => IERC3475.Values) values;
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
    }
    struct Class {
        mapping(uint256 => IERC3475.Values) _value;

        mapping(uint256 => IERC3475.Metadata) _nonceMetadata;
        mapping(uint256 => Nonce) nonces;

    }

    mapping(address => mapping(address => bool)) operatorApprovals;
    // from classId given
    mapping(uint256 => Class) internal classes;
    mapping(uint256 => IERC3475.Metadata) _classMetadata;






    constructor() {
        /**
        TODO: refactor the parameters according to instantiation from the forgeBond.ts
    export const OPERATION_TYPE_SUBSCRIPTION_VALUE = '1';
    export const OPERATION_TYPE_SUBSCRIPTION = 'Subscription';
    export const OPERATION_TYPE_REDEMPTION_VALUE = '2';
    export const OPERATION_TYPE_REDEMPTION = 'Redemption';
    export const OPERATION_TYPE_TRADE_VALUE = '3';
    export const OPERATION_TYPE_TRADE = 'Trade';
         */




    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the factory owner");
        _;
    }

    event InstrumentCreated();
}
