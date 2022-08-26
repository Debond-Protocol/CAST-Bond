pragma solidity 0.8.0;

import "./SecurityTokenBalancesLibrary.sol";

library BasicTokenLibrary {
   /** we will consider this as underlying DebondToken information. 
   */
    struct BasicToken {
        address owner;
        uint256 initialSupply;
        uint256 currentSupply;
        string name;
        string symbol;
        string isinCode;
        address settler;
        address registrar;
        SecurityTokenBalancesLibrary.SecurityTokenBalances securityTokenBalances;
    }
    event Dummy(); // Needed otherwise typechain has no output

    struct BasicTokenInput {
        uint256 initialSupply;
        string isinCode;
        string name;
        string symbol;
        uint256 denomination;
        uint256 divisor;
        uint256 startDate;
        uint256 initialMaturityDate;
        uint256 firstCouponDate;
        uint256 couponFrequencyInMonths;
        uint256 interestRateInBips;
        bool callable;
        bool isSoftBullet;
        uint256 softBulletPeriodInMonths;
        string currency;
        address registrar;
        address settler;
        address owner;
    }
    /** we
    this will be replaced 
    */
    struct Bond {
        uint256 denomination;
        uint256 divisor;
        uint256 startDate;
        uint256 maturityDate; // the initial date (fixed for fixed rate bond).
        uint256 currentMaturityDate; // for the floating rate bonds, the predicted value based on the redemption conditions defined
        uint256 firstCouponDate;
        uint256 couponFrequencyInMonths;
        uint256 interestRateInBips;
        bool callable;
        bool isSoftBullet;
        uint256 softBulletPeriodInMonths;
        string termsheetUrl;
        string currency;
        mapping(address => uint256) tokensToBurn;
        uint256 state;
    }
}
