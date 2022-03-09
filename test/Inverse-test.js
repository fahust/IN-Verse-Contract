

const TokenContract = artifacts.require("TokenContract");
const AuctionController = artifacts.require("AuctionController");
const AccountContract = artifacts.require("AccountContract");

var addressToken;

contract("TokenContract", async accounts => {
    const account_one = accounts[0];
    const account_two = accounts[1];
    const amount = 10;
    /*it("multiple mint 100", async () =>{
        let instance = await  TokenContract.deployed();
        await instance.multipleMint(100,{from:account_one,gasPrice: 0, gas:3000000})
        //await instance.multipleMint(100,{from:account_one,gasPrice: 0, gas:3000000})
    });*/
    it("multiple mint 10", async () =>{
        let instance = await  TokenContract.deployed();
        await instance.multipleMint(1000,{from:account_one,gasPrice: 0, gas:3000000})
    })
    //eth.getBlock('latest')
    it("balance token of", async () =>{
        let instance = await  TokenContract.deployed();
        await instance.balanceOf(account_one,{from:account_one})
        addressToken = instance.address;



                        

            contract("AccountContract", async accounts => {
                const account_one = accounts[0];
                const account_two = accounts[1];
                const amount = 10;
                /*it("should put 10000 MetaCoin in the first account", () =>
                    AuctionController.deployed()
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
                    let instance = await  AuctionController.deployed();
                    await instance.multipleMint(10,"",{from:account_one})
                });*/



                /*it("create auction", async () => {
                    let instance = await  AuctionController.deployed();
                    await instance.createAuction({from:account_one})
                    let inst = await instance.getAuctionContract(0,{from:account_one})
                    auctionContract = new web3.eth.Contract(AuctionContract.abi, inst);
                });*/

                console.log('addr token : ',addressToken)

                it("create account", async () => {
                    let instance = await  AccountContract.deployed();
                    await instance.createAccount({from:account_one})
                });

                it("create auction", async () => {
                    let instance = await  AccountContract.deployed();
                    await instance.addAuction({from:account_one})
                });

                it("add collection", async () => {
                    let instance = await  AccountContract.deployed();
                    await instance.addCollection(account_one,{from:addressToken})
                });
                

                it("set royalties address count two by count one", async () =>{
                    let instance = await  AccountContract.deployed();
                    await instance.setRoyaltiesAdress(0,account_two,{from:account_one})
                });

                it("first bidding auction on first auction", async () =>{
                    let instance = await  AccountContract.deployed();
                    let bid = await instance.bidding(0,{from:account_one,value:110000000000000000})
                });

                it("get time start", async () =>{
                    let instance = await  AccountContract.deployed();
                    let bid = await instance.getParamsContract(0,"startAuction",{from:account_one})
                });

                it("start auction with account two", async () =>{
                    let instance = await  AccountContract.deployed();
                    await instance.startAuction(0,{from:account_two})
                });

                it("start auction with account one", async () =>{
                    let instance = await  AccountContract.deployed();
                    await instance.startAuction(0,{from:account_one})
                });

                it("bidding on auction after start auction with account 1 with 0.05 eth", async () =>{
                    let instance = await  AccountContract.deployed();
                    await instance.bidding(0,{from:account_one,value:50000000000000000})
                });

                it("bidding on auction after start auction with account 1 with 0.11", async () =>{
                    let instance = await  AccountContract.deployed();
                    await instance.bidding(0,{from:account_one,value:110000000000000000})
                });

                it("bidding on auction after start auction with account 1 with 0.10", async () =>{
                    let instance = await  AccountContract.deployed();
                    await instance.bidding(0,{from:account_one,value:100000000000000000})
                });

                it("bidding on auction after start auction with account 1 with 0.12", async () =>{
                    let instance = await  AccountContract.deployed();
                    await instance.bidding(0,{from:account_one,value:120000000000000000})
                });

                it("end auction with account two", async () =>{
                    let instance = await  AccountContract.deployed();
                    await instance.endAuction(0,{from:account_two})
                });

                it("end auction with account one", async () =>{
                    let instance = await  AccountContract.deployed();
                    await instance.endAuction(0,{from:account_one})
                });

                it("change time to 0", async () =>{
                    let instance = await  AccountContract.deployed();
                    await instance.setParamsContract(0,"timeAuction",0,{from:account_one})
                });

                it("end auction with account two", async () =>{
                    let instance = await  AccountContract.deployed();
                    await instance.endAuction(0,{from:account_two})
                });

                it("end auction with account one", async () =>{
                    let instance = await  AccountContract.deployed();
                    await instance.endAuction(0,{from:account_one})
                });

                

                

                


            });




    });
    let actualBalance = await web3.eth.getBalance(account_one);
    console.log("My current balance WEI : ",actualBalance)
    //console.log(web3.utils.toWei)
    console.log("My current balance ETH : ",web3.utils.fromWei(actualBalance, 'ether'))
    
})


