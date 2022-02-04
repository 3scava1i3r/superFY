/* eslint-disable prettier/prettier */
import React from "react";
const SuperfluidSDK = require("@superfluid-finance/js-sdk");
const { Web3Provider } = require("@ethersproject/providers");
import { useMoralis } from "react-moralis";

export default function FixedYield() {

    const { account } =
      useMoralis();
    const sf = new SuperfluidSDK.Framework({
      ethers: new Web3Provider(window.ethereum),
    });
    const sfstart = async() => {
        
        await sf.initialize();
    } 
    sfstart()

    const startflow = async() => {
        console.log(sf.cfa);
        console.log(account)
        await sf.cfa.createFlow({
          superToken: "0x5d8b4c2554aeb7e86f387b4d6c00ac33499ed01f",
          receiver: "0x71026E214A2d4E98b6F2fc214dD47dA7a1148705",
          flowRate: "385802469135",
        });
    }

    const stopflow = async() => {
        await sf.cfa.deleteFlow({
          superToken: "0x5d8b4c2554aeb7e86f387b4d6c00ac33499ed01f",
          sender: account,
          receiver: "0x71026E214A2d4E98b6F2fc214dD47dA7a1148705",
          by: account,
        });
    }
  //console.log(sf);

  return (
    <>
      <div>imma do some FY shit now lets start stream</div>
      <button onClick={startflow}>start flow pls</button>
      <button onClick={stopflow}>stop flow pls</button>

      <div>
        <div>
        {account}
        </div>
      </div>
    </>
  );
}
