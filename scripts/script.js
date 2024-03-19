//PURPOSE OF THIS SCRIPT IS TO SHOW OFF SOME PTBS AND TYPESCRIPT SDK USAGE
const { bcs } = require('@mysten/bcs');
const { SuiClient, getFullnodeUrl } = require("@mysten/sui.js/client");
const { TransactionBlock } = require('@mysten/sui.js/transactions');
const { Ed25519Keypair } = require("@mysten/sui.js/keypairs/ed25519");

class ContractInteractions {
  constructor() {
    const rpcUrl = getFullnodeUrl("devnet");
    this.suiClient = new SuiClient({ url: rpcUrl });
    //Change MNEMONICS here
    this.keyPair = Ed25519Keypair.deriveKeypair(
      "hurt code dawn post true chronic holiday equal calm notable adapt chair"
    );
    //Change CONTRACT ADDRESS here
    this.contractId = "0xe38188bd24c8c327d671cac5843f272cb86e84c89b42a973dec01518142471a5";
  }

  async createPoll() {
    //create transaction block and moveCall
    const txb = new TransactionBlock();

    const vectorOfString = bcs.vector(bcs.string());

    const stringList = ["one", "two"];

    const stringListBytes = vectorOfString.serialize(stringList).toBytes();

    await txb.moveCall({
      target: `${this.contractId}::voting::createPoll`,
      arguments: [
        txb.pure.string("question"),
        txb.pure(stringListBytes),
        //change POLLCOLLECTION ADDRESS here
        txb.object("0x1f64c595f781450fbd5e91af60a141d20a0b8a66b6421c0b1328ed0afe367e7e"),
      ],
    });

    //signAndExecute part
    const result = await this.suiClient.signAndExecuteTransactionBlock({
      signer: this.keyPair,
      transactionBlock: txb,
      options: { showObjectChanges: true },
    });
    //console.log(result);

    //getting Poll and it's values
    const createdPoll = result.objectChanges.find(
        (element) => element.type === 'created',
    );
    const pollObject = await this.suiClient.getObject({
        id: createdPoll.objectId,
        
        options: { showContent: true },
    });

    //console.log(JSON.stringify(pollObject, null, 2));


    //devInspect example
    const inspectResult = await this.suiClient.devInspectTransactionBlock({
        //CHANGE THIS TO YOUR ADDRESS
        sender: '0x6ecfd8cbe297b68c48ae2fe3bb8e47577ec84313a55f0b1787b54cfd23a56059',
        transactionBlock: txb,
      });
    
    //console.log(JSON.stringify(inspectResult, null, 2));


    //dryRun example
    const builtTxb = await txb.build({
        client: this.suiClient, 
    });
    const dryRunResult = await this.suiClient.dryRunTransactionBlock({
        transactionBlock: builtTxb,
    });
    console.log(dryRunResult);
  }



  async registerVote() {
    //create transaction block and moveCall
    const txb = new TransactionBlock();
    txb.setGasBudget(1000000000);
    await txb.moveCall({
        target: `${this.contractId}::voting::registerVote`,
        arguments: [
          //CHANGE THIS TO YOUR POLL ADDRESS
          txb.object("0x13ccbd7e9eaf2a2a836c3971757fc02d44f3eddd66db373cfb6939c5829ce878"),
          txb.pure.u64(0),
          txb.pure.string("Johnny"),
        ],
      });
  
      //signAndExecute part
      const result = await this.suiClient.signAndExecuteTransactionBlock({
        signer: this.keyPair,
        transactionBlock: txb,
        options: { showObjectChanges: true },
      });
      //console.log(result);
  }

  async changePollStatus() {
    const txb = new TransactionBlock();
    await txb.moveCall({
        target: `${this.contractId}::voting::changePollStatus`,
        arguments: [
          //CHANGE THIS ADDRESS TO YOUR POLL ADDRESS
          txb.object("0x13ccbd7e9eaf2a2a836c3971757fc02d44f3eddd66db373cfb6939c5829ce878"),
          txb.pure.bool(true)
        ],
      });
  
      //signAndExecute part
      const result = await this.suiClient.signAndExecuteTransactionBlock({
        signer: this.keyPair,
        transactionBlock: txb,
        options: { showObjectChanges: true },
      });
  }

  async getPollVotes() {
    const txb = new TransactionBlock();
    await txb.moveCall({
        target: `${this.contractId}::voting::getPollVotes`,
        arguments: [
          //CHANGE THIS TO YOUR POLL ADDRESS
          txb.object("0x13ccbd7e9eaf2a2a836c3971757fc02d44f3eddd66db373cfb6939c5829ce878")
        ],
      });
  
      //signAndExecute part
      const result = await this.suiClient.signAndExecuteTransactionBlock({
        signer: this.keyPair,
        transactionBlock: txb,
        options: { showObjectChanges: true },
      });

    //devInspect example
    const inspectResult = await this.suiClient.devInspectTransactionBlock({
        //CHANGE THIS TO YOUR SENDER ADDRESS
        sender: '0x66d118fa67e40562ad088c43771e0cb2d34f252fbbec939f2688c5d62b1f87e7',
        transactionBlock: txb,
    });
    
    console.log(JSON.stringify(inspectResult, null, 2));
  }

  async invokeMethod(methodName) {
    if (typeof this[methodName] === "function") {
      await this[methodName]();
    } else {
      console.error("Invalid method. Method does not exist or is not callable.");
    }
  }
}

const interactions = new ContractInteractions();
const methodName = process.argv[2];

interactions.invokeMethod(methodName);
