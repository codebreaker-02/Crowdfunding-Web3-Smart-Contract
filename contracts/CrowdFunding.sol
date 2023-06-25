// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 amountCollected;
        uint256 deadline;
        string imageURL;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    function createCampaign(address _owner, string memory _title, string memory _description, uint256 _target, uint256 _deadline, 
                            string memory _imageURL) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        //Require block to check if everything is fine before actually creating the campaign.
        require(_deadline > block.timestamp, "Deadline should be in the future!");

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.amountCollected = 0;
        campaign.deadline = _deadline;
        campaign.imageURL = _imageURL;

        numberOfCampaigns++;

        return numberOfCampaigns-1;
    }

    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        (bool sent, ) = payable(campaign.owner).call{value: amount}("");

        require(sent, "Ether sending unsuccessful!");

        if(sent) {
            campaign.donators.push(msg.sender);
            campaign.donations.push(amount);

            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

    function getDonators(uint256 _id) public view returns (address[] memory, uint256[] memory) {
        Campaign storage campaign = campaigns[_id];

        return (campaign.donators, campaign.donations);
    }

    function getAllCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for(uint256 i=0 ; i<numberOfCampaigns ; i++){
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
}