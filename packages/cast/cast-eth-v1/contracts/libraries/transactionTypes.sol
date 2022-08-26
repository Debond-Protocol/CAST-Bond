pragma solidity ^0.8.9;

    struct SettlementTransactionRepository {
        mapping(uint256 => SettlementTransaction) settlementTransactionById; // mapping ( settlementtransactionId => settlementtransaction)
        mapping(uint256 => uint256) operationTypeByOperationId; // operationId -> operationType
    }

    struct SettlementTransaction {
        uint256 txId;
        uint256 operationId;
        address deliverySenderAccountNumber;
        address deliveryReceiverAccountNumber;
        uint256 deliveryQuantity;
        uint256 status;
        string txHash;
    }

    struct PartialSettlementTransaction {
        uint256 txId;
        uint256 operationId;
        address deliverySenderAccountNumber; // redemption investor - subscription issuer
        address deliveryReceiverAccountNumber; // redemption issuer - subscription investor
        uint256 deliveryQuantity;
        string txHash;
    }