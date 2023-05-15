// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;


uint constant THRESHOLD = 10;

interface IGetRandomNumber{
    function getRandomNumber() external view returns (uint8);
}

/** 
    @notice The contract allows to vote on open disputes. If the dispute is resolved in favor of the buyer,
    the seller have to refund the buyer. If the dispute is resolved in favor of the seller, the sale is closed.
    @dev Security review is pending... should we deploy this?
    @custom:ctf This contract is part of the exercises at https://github.com/jcr-security/solidity-security-teaching-resources
*/
contract VulnerableDAO {

    /** 
        @notice A Dispute includes the itemId, the reasoning of the buyer and the seller on the claim,
        and the number of votes for and against the dispute.
        @dev A Dispute is always written from the POV of the buyer
            - FOR is in favor of the buyer claim
            - AGAINST is in favor of the seller claim
     */
    struct Dispute {
        uint itemId;
        string buyerReasoning;
        string sellerReasoning;
        uint votesFor;
        uint votesAgainst;
        uint totalVoters;
    }

    // Current disputes, indexed by disputeID
    mapping(uint => Dispute) public disputes;
    // Password to access the key functions
    //string password;

    address owner;
    
    address randomNumberContract;


    /************************************** Events and modifiers *****************************************************/

    event AwardNFT(address user);

    modifier isAuthorized() {
        require( msg.sender == owner,
            "Unauthorized");
        _;
    }

    /************************************** External  ****************************************************************/ 

    constructor(address VRF_contract) {
        owner = msg.sender;
        randomNumberContract = VRF_contract; // este contrato utiliza VRF de chainlink para obtener un numero random.
    }


    /**
        @notice Update the contract's configuration details
        @param newOwner The new owner address
     */
    function updateConfig(address newOwner
    ) external isAuthorized {
        owner = newOwner;
        /*
        * DAO configuration logic goes here
        */
    }


    /**
        @notice Cast a vote on a dispute
        @param disputeId The ID of the target dispute
        @param vote The vote, true for FOR, false for AGAINST
     */
    function castVote(uint disputeId, bool vote) external {      
        /*
        * DAO vote casting logic goes here
        */
    }


    /**
        @notice Open a dispute
        @param itemId The ID of the item involved in the dispute
        @param buyerReasoning The reasoning of the buyer in favor of the claim
        @param sellerReasoning The reasoning of the seller against the claim
     */
    function newDispute( 
        uint itemId, 
        string calldata buyerReasoning, 
        string calldata sellerReasoning
    ) external isAuthorized returns (uint) {       
        /*
        * DAO dispute logic goes here
        */
    }    


    /**
        @notice Resolve a dispute if enough users have voted and remove it from the storage
        @param disputeId The ID of the target dispute
     */
    function endDispute(uint disputeId) external {       
        /*
        * DAO dispute logic goes here
        */
    }    

    /**
        @notice Randomly award an NFT to a user if they voten for the winning side
        @param disputeID The ID of the target dispute
     */
    function checkLottery(uint disputeID) external {     
          
        /*
        * DAO lottery award logic goes here
        */

        lotteryNFT(msg.sender);

    }      


    /************************************** Internal *****************************************************************/

    /**
        @notice Run a PRNG to award NFT to a user
        @param user The address of the elegible user
     */
    function lotteryNFT(address user) internal {
        uint randomNumber = IGetRandomNumber(randomNumberContract).getRandomNumber();

        if (randomNumber < THRESHOLD   ) {
            /*
            * Award NFT logic goes here
            */
            emit AwardNFT(user);
        }

        
    }


    /************************************** Views ********************************************************************/

    /**
        @notice Query the details of a dispute
        @param disputeId The ID of the target dispute
     */
	function query_dispute(uint disputeId) public view returns (Dispute memory) {
		return disputes[disputeId];
	}

}