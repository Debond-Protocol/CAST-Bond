// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import "./ForgeInstrumentRegistry.sol";
import "./interfaces/IERC3475.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./libraries/BasicTokenLibrary.sol";
import "./libraries/SecurityTokensBalancesLibrary.sol";
import "./libraries/SettlementWorkflowLibrary.sol";

// different bond types. 
enum BondType {SOFT_BULLET,COUPON_BOND,CALLABLE_BOND}

 contract ForgeBond is IERC3475 , Ownable {
    //error
    error ZeroAddress(string funcName);
    error CallerNotApproved(string message);
    address issuer;

    // defining the alias objects to define the specific data vars.
    using BasicBondNonceInfo for BasicTokenLibrary.BasicToken;
    using BasicBondClassInfo for BasicTokenLibrary.BasicTokenInput;
    using BasicBondInfo for BasicTokenLibrary.Bond;
    using SettlementRepositoryLibrary for *;
    using SettlementWorkflowLibrary for *;
    /**
    * @notice this Struct is representing the Nonce properties as an object
    *         and can be retrieve by the nonceId (within a class).
    */
    struct Nonce {
        // defining the state 
        BasicBondClassInfo.state _currentState;        
        // defining the supplies
        BasicBondNonceInfo.initialSupply  _initialSupply;
        BasicBondClassInfo.currentSupply  _currentSupply;
        // bonds that are redeemed.
        uint256 _redeemedSupply; 
        
        // stores the other parameters (owner,  startDate,isinNumber initialMaturityDate, address of settler and registerar address,  firstCouponDate (if coupon bond), termsheetUrl).
        mapping(uint256 => IERC3475.Values) values; 

        SecurityTokenBalancesLibrary.SecurityTokenBalances securityTokenBalances; 

        mapping(address => securityTokenBalances) balances;
        // registerar => settlar => tokens Allotted.
        mapping(address => mapping(address => uint256)) allowances;
    }
    struct Class {

        // stores the details concerning the bond identifiers and properties (name,symbol,BondType,denomination,divisor,couponFrequencyInMonths(if coupon bond), interestRateInBips, underlying_currency_address. )
        mapping(uint256 => IERC3475.Values) _value;
        // defining the metadata about the above properties.
        mapping(uint256 => IERC3475.Metadata) _nonceMetadata; 
        // storing the details of the nonces.
        mapping(uint256 => Nonce) nonces;

    }
    // approvals for transfering from registerar to the settler
    mapping(address => mapping(address => bool)) operatorApprovals;
    // from classId given, indexing the classes and their metadata.
    mapping(uint256 => Class) internal classes;
    mapping(uint256 => IERC3475.Metadata) _classMetadata;

    constructor() {
        /**  defining some example classes and metadata and bonds.
         * here we consider two class of bonds :-> softBullet and coupon bonds.
         * Bullet bonds pay their entire principal value in its entierity(as the fixed rate bonds)
         * whereas coupon bonds will pay in the partial payments amortized during the maturity time of the given bond.
         * also most of the classMetadata will remmain same in the longer term.
         */

        // defining the following parameter details
        //(name,symbol,BondType,denomination,divisor,couponFrequencyInMonths(if coupon bond), interestRateInBips,callable, underlying_currency_address. )
        _classMetadata[0][0].title = "symbol";
        _classMetadata[0][0]._type = "string";
        _classMetadata[0][0].description = "name of class";
       
        _classMetadata[0][1].title = "symbol";
        _classMetadata[0][1]._type = "string";
        _classMetadata[0][1].description = "symbol of the class";
        

        _classMetadata[0][2].title = "BondType";
        _classMetadata[0][2]._type = "uint";
        _classMetadata[0][2].description = "bond type";


        _classMetadata[0][3].title = "denomination";
        _classMetadata[0][3]._type = "number";
        _classMetadata[0][3].description = "mathematical denomination";


        _classMetadata[0][4].title = "coupon-frequency";
        _classMetadata[0][4]._type = "number";
        _classMetadata[0][4].description = "payment of coupon bond (in months)";

        _classMetadata[0][5].title = "interest rate";
        _classMetadata[0][5]._type = "number";
        _classMetadata[0][5].description = "interest rate in basis points";


        _classMetadata[0][6].title = "underlying currency";
        _classMetadata[0][6]._type = "string";
        _classMetadata[0][6].description = "underlying currency ticker";

        // now defining the parameters corresponding to the each classes 
        _classes[0]._values[0].stringValue = "CAST bond Coupon 6M";
        _classes[0]._values[1].stringValue = "CAST-1";
        _classes[0]._values[2].stringValue = BondType.COUPON_BOND;
        _classes[0]._values[3].uintValue = 10**18;
        _classes[0]._values[4].uintValue = 2;
        _classes[0]._values[5].uintValue = 50; // 50bps
        _classes[0]._values[6].stringValue = "USDC";

        _classes[1]._values[0].stringValue = "CAST bond  callable 3M";
        _classes[1]._values[1].stringValue = "CAST-2";
        _classes[1]._values[2].stringValue = BondType.COUPON_BOND;
        _classes[1]._values[3].uintValue = 10**18;
        _classes[1]._values[4].uintValue = 0;
        _classes[1]._values[5].uintValue = 50; // 50bps
        _classes[1]._values[6].stringValue = "BNB";

        // and defining already instantiated bonds for the tests 



    }

    /// writable functions 
    /// @notice transfering bonds between the different registerars  (following the standards defined in SettlementRepository and Settlement workflow library)
    /// @dev only possible if the destination address has the allowance, along with the transfer is done within the registerar addresss.

        function transferFrom(
        address _from,  // or _delieverSenderAccountAddress.
        address _to,    // or _delieverReceiverAccountAddress.
        Transaction[] calldata _transactions
    ) public virtual override {
        if(_from == address(0)) { revert ZeroAddress("transferFrom:_from-not-address-zero");}
        else if(_to == address(0)) {revert ZeroAddress("transferFrom:destination-address-not-address-zero");}
        else if(msg.sender == _from || isApprovedFor(_from, msg.sender)) {revert CallerNotApproved("transfer")}

     uint256 len = _transactions.length;
        // now transferring all of the bonds between the entities: 
        for (uint256 i = 0; i < len; i++) {
            _transferFrom(_from, _to, _transactions[i]);
        }
        emit Transafer(msg.sender,_from,_to,_transactions[i]);
    }


        function transferAllowanceFrom(
        address _from,
        address _to,
        Transaction[] calldata _transactions
    ) public virtual override {
    if(_from == address(0)) { revert ZeroAddress("transferFrom:no-zero-account-address-transfet");}
    if(_from == address(0)) { revert ZeroAddress("transferFrom:use_Bond");}

     uint256 len = _transactions.length;
        for (uint256 i = 0; i < len; i++) {
            require(
                _transactions[i].amount <= allowance(_from, msg.sender, _transactions[i].classId, _transactions[i].nonceId),
                "ERC3475:caller-not-owner-or-approved"
            );
            _transferAllowanceFrom(msg.sender, _from, _to, _transactions[i]);
        }
    }

    // allows the creation of the 
    function issue(address _to, Transaction[] calldata _transactions)
    external
    virtual
    override
    { 
        // here first we will be instantiating the subscription for each type of bonds .
    SettlementWorkflowLibrary.SettlementTransactionRepository settlementTransactionRepository;
    BasicBondNonceInfo  token;    
    SettlementRepositoryLibrary.PartialSettlementTransaction _partialSettlementTransaction;

    uint len = _transactions.length;

    /**
     * for the bonds : 
     *         address owner;
        uint256 initialSupply;
        uint256 currentSupply;
        string name;
        string symbol;
        string isinCode;
        address settler;
        address registrar;

     * 
     */


   
    // for each of the transactionId .
    for(uint i = 0; i < len; i++)

    {
    settlementTransactionRepository.settlementTransactionById[i].txid = _transactions[i].txid;
    settlementTransactionRepository.settlementTransactionById[i].operationId = _transactions[i].operationId;
    settlementTransactionRepository.settlementTransactionById[i].deliverySenderAccountNumber = _transactions[i].deliverySenderAccountNumber;
    settlementTransactionRepository.settlementTransactionById[i].delieveryRecceiverAccountNumber = _transactions[i].delieveryRecceiverAccountNumber;
    settlementTransactionRepository.settlementTransactionById[i].deliveryQuantity = _transactions[i].deliveryQuantity;
    settlementTransactionRepository.settlementTransactionById[i].status = _transactions[i].status;
    settlementTransactionRepository.settlementTransactionById[i].txhash = _transactions[i].txhash;

    //TODO: the below implementation is wrong, there needs ot be refactoring in the codebase to store the partial transaction status seperately.
    _partialSettlementTransaction.settlementTransactionById[i].txid = _transactions[i].txid;
    _partialSettlementTransaction.settlementTransactionById[i].operationId = _transactions[i].operationId;
    _partialSettlementTransaction.settlementTransactionById[i].deliverySenderAccountNumber = _transactions[i].deliverySenderAccountNumber;
    _partialSettlementTransaction.settlementTransactionById[i].delieveryRecceiverAccountNumber = _transactions[i].delieveryRecceiverAccountNumber;
    _partialSettlementTransaction.settlementTransactionById[i].deliveryQuantity = _transactions[i].deliveryQuantity;
    _partialSettlementTransaction.settlementTransactionById[i].txhash = _transactions[i].txhash;

    token.owner = _to;
    token.initialSupply = _transaction[i].amount;
    token.currentSupply = _transaction[i].amount;
    token.name = _classes[_transaction[i].classId]._values[0].stringValue;
    token.symbol = _classes[_transaction[i].classId]._values[1].stringValue;
    token.isinCode = _transaction[i].isinCode;
    token.settler = _transaction[i].settler;
    token.registrar = _transaction[i].registrar;
    // locking the tokens now and initiating the subscription to the bond.
    SettlementWorkflowLibrary.initiateSubscription(settlementTransactionRepository,token,_partialSettlementTransaction);
    }







    }




















// internal functions





}
