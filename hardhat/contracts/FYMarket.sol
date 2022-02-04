pragma solidity >=0.6.0 <0.8.4;


// responsible for the following -  oracle work,reusable superfluid code

import "hardhat/console.sol";
import {ISuperfluid, ISuperToken , SuperAppDefinitions } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import {SuperAppBase} from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperAppBase.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IConstantFlowAgreementV1} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";
import {IInstantDistributionAgreementV1} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IInstantDistributionAgreementV1.sol";




abstract contract FYMarket is SuperAppBase,Ownable {

    struct ShareholderUpdate {
      address shareholder;
      int96 previousFlowRate;
      int96 currentFlowRate;
      ISuperToken token;
    }

    // oracle struct made
    struct OracleInfo {
        uint256 requestId;
        uint256 usdPrice;
        uint256 lastUpdatedAt;
    }

    // output pool to be wriiten
    struct OutputPool {
        ISuperToken token;
        uint256 emissionRate;
    }

    // MARKET TO BE WRITTEN
    struct Market {
        ISuperToken inputToken;
        uint256 lastDistributionAt; // The last time a distribution was made
        uint256 rateTolerance; // The percentage to deviate from the oracle scaled to 1e6
        uint128 feeRate;
        address owner; // The owner of the market (reciever of fees)
        mapping(ISuperToken => OracleInfo) oracles; // Maps tokens to their oracle info
        mapping(uint32 => OutputPool) outputPools; // Maps IDA indexes to their distributed Supertokens
        mapping(ISuperToken => uint32) outputPoolIndicies; // Maps tokens to their IDA indexes in OutputPools
        uint8 numOutputPools; // Indexes outputPools and outputPoolFees

    }


    ISuperfluid internal host; // Superfluid host contract
    IConstantFlowAgreementV1 internal cfa; // The stored constant flow agreement class address
    IInstantDistributionAgreementV1 internal ida; // The stored instant dist. agreement class address
    // chainlink oracle to be made
    Market internal market;

    uint32 internal constant PRIMARY_OUTPUT_INDEX = 0;
    uint8 internal constant MAX_OUTPUT_POOLS = 5;



    // Setters

    /// @dev Set rate tolerance
    /// @param _rate This is the new rate we need to set to
    function setRateTolerance(uint256 _rate) external onlyOwner {
        market.rateTolerance = _rate;
    }

    /// @dev Sets fee rate for a output pool/token
    /// @param _index IDA index for the output pool/token
    /// @param _feeRate Fee rate for the ouput pool/token
    function setFeeRate(uint32 _index, uint128 _feeRate) external onlyOwner {
        market.outputPools[_index].feeRate = _feeRate;
    }

    /// @dev Sets emission rate for a output pool/token
    /// @param _index IDA index for the output pool/token
    /// @param _emissionRate Emission rate for the ouput pool/token
    function setEmissionRate(uint32 _index, uint128 _emissionRate)
        external
        onlyOwner
    {
        market.outputPools[_index].emissionRate = _emissionRate;
    }


    constructor(
        address _owner,
        ISuperfluid _host,
        IConstantFlowAgreementV1 _cfa,
        IInstantDistributionAgreementV1 _ida,
        string memory _registrationKey
    ) {
        host = _host;
        cfa = _cfa;
        ida = _ida;

        transferOwnership(_owner);

        uint256 _configWord = SuperAppDefinitions.APP_LEVEL_FINAL;

        if (bytes(_registrationKey).length > 0) {
            host.registerAppWithKey(_configWord, _registrationKey);
        } else {
            host.registerApp(_configWord);
        }
    }


    

}