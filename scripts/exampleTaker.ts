//WSS event listener on contract
//Create list of open orders
//Instantiate WSS price checker for all token pairs
//Service Order when price is right

import { Contract, ethers } from "ethers";
import LimitOrderMarketAbi from "../abi/LimitOrderMarketAbi.json";

const DAI_ADDRESS = ""
const priceUrl = "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd"
const desiredReward = 100;


async function listenToOrders() {}

async function main() {
  
  const limitOrderMarket = new ethers.Contract(
    process.env.LOM_ADDRESS as string,
    LimitOrderMarketAbi
  ) as Contract;

  const orderCreatedFilter = limitOrderMarket.filters.OrderCreated(null);
  const createdOrders = await limitOrderMarket.queryFilter(
    orderCreatedFilter,
    0,
    "latest"
  );

  const orderDeletedFilter = limitOrderMarket.filters.OrderDeleted(null);
  const deletedOrders = await limitOrderMarket.queryFilter(
    orderDeletedFilter,
    0,
    "latest"
  );

  const OrderChangedFilter = limitOrderMarket.filters.OrderChanged(null);
  const changedOrders = await limitOrderMarket.queryFilter(
    OrderChangedFilter,
    0,
    "latest"
  );

  limitOrderMarket.on(orderCreatedFilter, (idx, event) => {
    console.log(idx);
    console.log(event);
  });
  limitOrderMarket.on(orderDeletedFilter, (idx, event) => {
    console.log(idx);
    console.log(event);
  });
  limitOrderMarket.on(OrderChangedFilter, (idx, event) => {
    console.log(idx);
    console.log(event);
  });
}
