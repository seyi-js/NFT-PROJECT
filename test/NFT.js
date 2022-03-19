let NFT = artifacts.require("./NFT.sol");
let NFTMartket = artifacts.require("./Marketplace.sol");
let Web3 = require("web3");

const web3 = new Web3();
contract("Marketplace", function (accounts) {
  let martketInstance;
  let NFTInstance;

  beforeEach(async function () {
    martketInstance = await NFTMartket.deployed();
    NFTInstance = await NFT.deployed();
  });

  describe("NFTMarket", () => {
    it("should create market sales", async () => {
      try {
        let listing_price = await martketInstance.getListingPrice();
        listing_price = listing_price.toString();
        const market_address = martketInstance.address;
        const nft_address = NFTInstance.address;

        await NFTInstance.setMarketPlaceAddress(market_address);

        const auctionPrice = "10000"; //web3.utils.fromWei("25000000000000000", "ether");

        await NFTInstance.createToken("https://creditsync.com.ng");
        await NFTInstance.createToken("https://creditsync.com.ng");

        //Create Market Item
        await martketInstance.createMarketItem(nft_address, 1, auctionPrice, {
          value: listing_price,
        });

        await martketInstance.createMarketItem(nft_address, 2, auctionPrice, {
          value: listing_price,
        });

        //Create Market sales

        await martketInstance.createMarketSale(nft_address, 1, {
          value: auctionPrice,
          from: accounts[1],
        });

        const items = await martketInstance.fetchMarketItems();
        console.log("items", items);
      } catch (error) {
        console.log(error.message);
        throw error;
      }
    });
  });
});
