const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("IDTTokenTest", function () {
  let IDTTokenTest, token, owner, addr1, addr2;

  beforeEach(async function () {
    IDTTokenTest = await ethers.getContractFactory("IDTTokenTest");
    [owner, addr1, addr2] = await ethers.getSigners();

    token = await IDTTokenTest.deploy();
    await token.deployed();
  });

  it("Harus memiliki total supply awal 1 Miliar IDT", async function () {
    const totalSupply = await token.totalSupply();
    expect(totalSupply).to.equal(ethers.utils.parseEther("1000000000"));
  });

  it("Harus memungkinkan minting token", async function () {
    await token.connect(owner).mint(addr1.address, ethers.utils.parseEther("1000"));
    const balance = await token.balanceOf(addr1.address);
    expect(balance).to.equal(ethers.utils.parseEther("1000"));
  });

  it("Harus memungkinkan burning token", async function () {
    const burnAmount = ethers.utils.parseEther("1000"); // Pastikan jumlah sesuai skala 18 desimal

    await token.connect(owner).burn(burnAmount);

    const totalSupply = await token.totalSupply();
    const expectedSupply = ethers.utils.parseEther("999999000"); // Koreksi total supply yang benar setelah burn

    expect(totalSupply).to.equal(expectedSupply);
  });

  it("Harus memungkinkan transfer token", async function () {
    await token.connect(owner).transfer(addr1.address, ethers.utils.parseEther("500"));
    const balance = await token.balanceOf(addr1.address);
    expect(balance).to.equal(ethers.utils.parseEther("500"));
  });
});