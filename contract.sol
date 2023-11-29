// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
contract FishShop {
    struct Shops {
        uint id;
        string town;
        uint rating;
    }
 
    struct SellersWorking {
        address seller;
        address shopAddress;
    }
 
    SellersWorking[] allSellersWorking;
 
    struct Users {
        uint id;
        bytes32 username;
        bytes32 password;
        uint role;
    }
 
    struct Review {
        uint id;
        address shopAddress;
        string textContent;
        uint rating;
        int userRating;
    }

    struct Comments {
        uint id;
        uint reviewId;
        string textContent;
        bool approve;
    }
 
    // 0 - created, 1 - applyed, 2 - denied
    struct Applications {
        uint id;
        address whoSent;
        uint statusChange;
        uint answerStatus;
    }

    struct UserArray {
        address userAddress;
    }

    struct ShopArray {
        address shopAddress;
    }
 
    // 0 - admin, 1 - seller, 2 - customer
 
    mapping (address => Users) public allUsers;
    mapping (address => Shops) public allShops;

    UserArray[] public ALLUsers;
    ShopArray[] public ALLShops;

    Applications[] public ALLApplications;
 
    Review[] public allReviews;
    Comments[] public allComments;
 
    constructor() {
        allShops[0xce7e985293363CF29e2fF8784b7E1857CDb6678B] = (Shops(0, "Kaluga", 7));
        allShops[0x2e957D690baDB7801BD0db977d86Ba4657bc7907] = (Shops(1, "Moscow", 9));
        
        ALLShops.push(ShopArray(0xce7e985293363CF29e2fF8784b7E1857CDb6678B));
        ALLShops.push(ShopArray(0x2e957D690baDB7801BD0db977d86Ba4657bc7907));

        allUsers[0x99F9b8cE23e0FF59868cDF3823F296222327C0a9] = (Users(0, "admin", "123", 0));
        ALLUsers.push(UserArray(0x99F9b8cE23e0FF59868cDF3823F296222327C0a9));

        allUsers[0xEA75d9F9361B1aD5C9Fc5525a1D2d133E0698e76] = (Users(1, "seller", "123", 1));
        ALLUsers.push(UserArray(0xEA75d9F9361B1aD5C9Fc5525a1D2d133E0698e76));
        allSellersWorking.push(SellersWorking(0xEA75d9F9361B1aD5C9Fc5525a1D2d133E0698e76, 0x2e957D690baDB7801BD0db977d86Ba4657bc7907));

        allUsers[0x40135D0b5660C6ad96cC285e5Df2ef08B4cDa4Cc] = (Users(1, "im nothing like yall", "123", 1));
        ALLUsers.push(UserArray(0x40135D0b5660C6ad96cC285e5Df2ef08B4cDa4Cc));       
        allSellersWorking.push(SellersWorking(0x40135D0b5660C6ad96cC285e5Df2ef08B4cDa4Cc, 0xce7e985293363CF29e2fF8784b7E1857CDb6678B));

        allUsers[0x2ae9E2C5637aCbDAE152CAAd00711E13a6c84Cf2] = (Users(2, "customer", "123", 2));
        ALLUsers.push(UserArray(0x2ae9E2C5637aCbDAE152CAAd00711E13a6c84Cf2)); 
    }
    
    function getAllUsers() public view returns (UserArray[] memory) {
        return ALLUsers;
    }

    function getAllShops() public view returns (ShopArray[] memory) {
        return ALLShops;
    }

    function getAllSellers() public view returns (SellersWorking[] memory) {
        return allSellersWorking;
    }

    function getAllReviews() public view returns (Review[] memory) {
        return allReviews;
    }

    function getAllComments() public view returns (Comments[] memory) {
        return allComments;
    }

    function getAllApplications() public view returns (Applications[] memory) {
        return ALLApplications;
    }

    function getUserData(address userAddress) public view returns(Users memory) {
        return allUsers[userAddress];
    }

    function getShopData(address shopAddress) public view returns(Shops memory) {
        return allShops[shopAddress];
    }

    function Registration(address objectAddress, string memory username, string memory password, uint role) public {
        require(keccak256(abi.encodePacked(username)) == keccak256(abi.encodePacked("")), "U already registered");
        allUsers[objectAddress] = (Users(ALLUsers.length, keccak256(abi.encodePacked(username)), keccak256(abi.encodePacked(password)), role));
        ALLUsers.push(UserArray(objectAddress));
    }

    function Login(string memory username, string memory password) public view returns (bool) {
        require(keccak256(abi.encodePacked(username)) == keccak256(abi.encodePacked(allUsers[msg.sender].username)), "Provided data is not valid");
        require(keccak256(abi.encodePacked(password)) == keccak256(abi.encodePacked(allUsers[msg.sender].password)), "Provided data is not valid");
        return true;
    }
    // 1 - down, 0 - up
    function changeStatus(address userManipulated, uint statusChange) public {
        require(allUsers[msg.sender].role == 0, "U are not an administrator");
        // require(allUsers[userManipulated].role == 2 && statusChange == 0, "You can't modify current user role, cause of it's role is already lowest");
        // require(allUsers[userManipulated].role == 0 && statusChange == 1, "You can't modify current user role, cause of it's role is already highest");
        if (statusChange == 0) {
            allUsers[userManipulated].role -= 1;
        } else if (statusChange == 1) {
            allUsers[userManipulated].role += 1;
        }     
    }
 
    // 1 - down, 0 - up
    function modifyApplication(uint statusChange) public {
        // require(allUsers[msg.sender].role == 2 && statusChange == 0, "You can't modify current user role, cause of it's role is already lowest");
        // require(allUsers[msg.sender].role == 0 && statusChange == 1, "You can't modify current user role, cause of it's role is already highest");  
        ALLApplications.push(Applications(ALLApplications.length, msg.sender, statusChange, 0));
    }
 
    function answerApplication(uint id, bool answer) public {
        require(allUsers[msg.sender].role == 0, "U are not an administrator");
        for (uint i = 0; i < ALLApplications.length; i++) {
            if (ALLApplications[i].id == id) {
                require(ALLApplications[i].answerStatus == 0, "This application has been already seen");
            }
        }
        for (uint i = 0; i < ALLApplications.length; i++) {
            if (ALLApplications[i].id == id) {
                if (answer == false) {
                    ALLApplications[i].answerStatus = 2;
                } else if (answer) {
                    if (ALLApplications[i].statusChange == 0) {
                        ALLApplications[i].answerStatus = 1;
                        allUsers[ALLApplications[i].whoSent].role -= 1;
                    } else if (ALLApplications[i].statusChange == 1) {
                        ALLApplications[i].answerStatus = 1;
                        allUsers[ALLApplications[i].whoSent].role += 1;
                    }
                } 
            }
        }
    }
 
    uint[11] public ratingInner = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
 
    function reviewAdd(address shopAddress, string memory textContent, uint rating) public {
        require(allUsers[msg.sender].role == 2, "U role can't post review");
        // bytes memory byteContent = bytes(textContent); 
        // require(byteContent.length > 10, "Review length doesn't consistent with requirements");
        // bool flagConsist = false;
        // for (uint i = 0; i < ratingInner.length; i++) {
        //     if (i == rating) {
        //         flagConsist = true;
        //     }
        // }
        // require(flagConsist, "Rating is not valid");
        allReviews.push(Review(allReviews.length, shopAddress, textContent, rating, 0));
    }

    function commentAdd(uint reviewId, string memory textContent, bool approve) public {
        allComments.push(Comments(allComments.length, reviewId, textContent, approve));
        for (uint i = 0; i < allReviews.length; i++) {
            if (allReviews[i].id == reviewId) {
                if (approve) {
                allReviews[i].userRating += 1;
                } else {
                    allReviews[i].userRating -= 1;
                } 
            }
        }
    }

    function shopAdd(address shopAddress, string memory town) public {
        require(allUsers[msg.sender].role == 0, "U are not an administrator");
        allShops[shopAddress] = (Shops(ALLShops.length, town, 0));
        ALLShops.push(ShopArray(shopAddress));
    }
 
    function shopDel(address shopAD) public {
        require(allUsers[msg.sender].role == 0, "U are not an administrator");
        for (uint i = 0; i < allSellersWorking.length; i++) {
            if (allSellersWorking[i].shopAddress == shopAD) {
                allUsers[allSellersWorking[i].seller].role == 2;
                delete allSellersWorking[i];
            }
        }
        for (uint i = 0; i < ALLShops.length; i++) {
            if (ALLShops[i].shopAddress == shopAD) {
                delete ALLShops[i];
            }
        }
        delete allShops[shopAD];
    }
 
    function addSellers(address sellerAddress, address shop) public {
        require(allUsers[msg.sender].role == 0, "U are not an administrator");
        allSellersWorking.push(SellersWorking(sellerAddress, shop));
    }
}