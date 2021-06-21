export default async function main(ethers: any): Promise<void> {
  const limitOrderMarket = await (
    await ethers.getContractFactory("LimitOrderMarket")
  ).deploy("0xc778417E063141139Fce010982780140Aa0cD5Ab","","0x22f5413C075Ccd56D575A54763831C4c27A37Bdb");
  await limitOrderMarket.deployTransaction.wait(2);
  console.log(`LOM_ADDRESS=${limitOrderMarket.address}`);
}
