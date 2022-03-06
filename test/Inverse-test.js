

const TokenContract = artifacts.require("TokenContract");

contract("TokenContract", async accounts => {
    const account_one = accounts[0];
    const account_two = accounts[1];
    const amount = 10;
    /*it("multiple mint 100", async () =>{//IMPOSSIBLE VISIBLEMENT
        let instance = await  AuctionContract.deployed();
        await instance.multipleMint(100,"",{from:account_one})
    });*/
})

const AuctionContract = artifacts.require("AuctionContract");

contract("AuctionContract", async accounts => {
    const account_one = accounts[0];
    const account_two = accounts[1];
    const amount = 10;
    /*it("should put 10000 MetaCoin in the first account", () =>
        AuctionContract.deployed()
        .then(instance => instance.getBalance.call(accounts[0]))
        .then(balance => {
            assert.equal(
            balance.valueOf(),
            10000,
            "10000 wasn't in the first account"
            );
        })
    );*/

    /*it("multiple mint 10", async () =>{//1 ça passe, 10 c'est long , 100 c'est impossible
        let instance = await  AuctionContract.deployed();
        await instance.multipleMint(10,"",{from:account_one})
    });*/

    it("set royalties address count two by count one", async () =>{
        let instance = await  AuctionContract.deployed();
        await instance.setRoyaltiesAdress(account_two,{from:account_one})
    });

    it("bidding on auction before start auction with account 1", async () =>{
        let instance = await  AuctionContract.deployed();
        let bid = await instance.bidding({from:account_one,value:110000000000000000})
    });

    it("start auction with account two", async () =>{
        let instance = await  AuctionContract.deployed();
        await instance.startAuction({from:account_two})
    });

    it("start auction with account one", async () =>{
        let instance = await  AuctionContract.deployed();
        await instance.startAuction({from:account_one})
    });

    it("bidding on auction after start auction with account 1 with 0.05 eth", async () =>{
        let instance = await  AuctionContract.deployed();
        let bid = await instance.bidding({from:account_one,value:50000000000000000})
    });

    it("bidding on auction after start auction with account 1 with 0.11", async () =>{
        let instance = await  AuctionContract.deployed();
        let bid = await instance.bidding({from:account_one,value:110000000000000000})
    });

    it("bidding on auction after start auction with account 1 with 0.10", async () =>{
        let instance = await  AuctionContract.deployed();
        let bid = await instance.bidding({from:account_one,value:100000000000000000})
    });

    it("bidding on auction after start auction with account 1 with 0.12", async () =>{
        let instance = await  AuctionContract.deployed();
        let bid = await instance.bidding({from:account_one,value:120000000000000000})
    });

    it("end auction with account two", async () =>{
        let instance = await  AuctionContract.deployed();
        await instance.endAuction({from:account_two})
    });

    it("end auction with account one", async () =>{
        let instance = await  AuctionContract.deployed();
        await instance.endAuction({from:account_one})
    });

    it("change time to 0", async () =>{
        let instance = await  AuctionContract.deployed();
        await instance.setParamsContract("timeAuction",0,{from:account_one})
    });

    it("end auction with account two", async () =>{
        let instance = await  AuctionContract.deployed();
        await instance.endAuction({from:account_two})
    });

    it("end auction with account one", async () =>{
        let instance = await  AuctionContract.deployed();
        await instance.endAuction({from:account_one})
    });

    

    

    


});
