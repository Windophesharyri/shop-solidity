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
        allShops[0x657F0382605003cdB25bbcAF0bf6410c5350dA37] = (Shops(0, "Kaluga", 7));
        allShops[0xA5d207BBAa080EDFa1E25fe60B67A008cC6980da] = (Shops(1, "Moscow", 9));
        
        ALLShops.push(ShopArray(0x657F0382605003cdB25bbcAF0bf6410c5350dA37));
        ALLShops.push(ShopArray(0xA5d207BBAa080EDFa1E25fe60B67A008cC6980da));

        allUsers[0xf3c3083032e6999eEfb3dfCABA17Aea61d46a03B] = (Users(0, "admin", "123", 0));
        ALLUsers.push(UserArray(0xf3c3083032e6999eEfb3dfCABA17Aea61d46a03B));

        allUsers[0xe3B4c59aC5e96eab7A8682d79147693C8B23Fe16] = (Users(1, "seller", "123", 1));
        ALLUsers.push(UserArray(0xe3B4c59aC5e96eab7A8682d79147693C8B23Fe16));
        allSellersWorking.push(SellersWorking(0xe3B4c59aC5e96eab7A8682d79147693C8B23Fe16, 0xA5d207BBAa080EDFa1E25fe60B67A008cC6980da));

        allUsers[0x884966af1ae4315E8421F52F214eab554Ab1a83a] = (Users(1, "im nothing like yall", "123", 1));
        ALLUsers.push(UserArray(0x884966af1ae4315E8421F52F214eab554Ab1a83a));       
        allSellersWorking.push(SellersWorking(0x884966af1ae4315E8421F52F214eab554Ab1a83a, 0x657F0382605003cdB25bbcAF0bf6410c5350dA37));

        allUsers[0x511652e1f02C182e739aa3550819CafF41370d00] = (Users(2, "customer", "123", 2));
        ALLUsers.push(UserArray(0x511652e1f02C182e739aa3550819CafF41370d00)); 
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
    function modifyApplication(uint statusChange) public { 
        if (statusChange == 1) {
            require(allUsers[msg.sender].role != 2, "You can't downgrade from customer");
        }
        if (statusChange == 0) {
            require(allUsers[msg.sender].role != 1, "You can't upgrade from seller");
        }
        ALLApplications.push(Applications(ALLApplications.length, msg.sender, statusChange, 0));
    }
 
    function answerApplicationCustomer(uint id, bool answer) public {
        require(allUsers[msg.sender].role == 0, "U are not an administrator");
        for (uint i = 0; i < ALLApplications.length; i++) {
            if (ALLApplications[i].id == id) {
                require(allUsers[ALLApplications[i].whoSent].role == 2, "This application attach seller");
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
                    }
                }
            } 
        }
    }
    
    function modifyApplicationSeller(uint id, bool answer) public {
        require(allUsers[msg.sender].role == 0, "U are not an administrator");
        for (uint i = 0; i < ALLApplications.length; i++) {
            if (ALLApplications[i].id == id) {
                require(allUsers[ALLApplications[i].whoSent].role == 1, "This application attach customer");
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
        for (uint i = 0; i < ALLShops.length; i++) {
            require(ALLShops[i].shopAddress != shopAddress, "This shop already exist");
        }
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
        for (uint i = 0; i < allSellersWorking.length; i++) {
            require(allSellersWorking[i].seller != sellerAddress, "This seller already exists");
        }
        allSellersWorking.push(SellersWorking(sellerAddress, shop));
    }
}