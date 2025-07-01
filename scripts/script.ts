import { getFullnodeUrl, SuiClient } from "@mysten/sui/client";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { Transaction } from "@mysten/sui/transactions";
import { fromBase64 } from "@mysten/sui/utils";
import * as dotenv from "dotenv";

dotenv.config()



const b64priv = process.env.PRIVATE_KEY as string;

const keyArray = Array.from(fromBase64(b64priv));
keyArray.shift();

const keypair = Ed25519Keypair.fromSecretKey(Uint8Array.from(keyArray));

const packageId = "0x3e79f023818c92b419119c7e9d20c2e2a4b35015e5f86bf6b8c4bf7bd844fd6d";
console.log(keypair.toSuiAddress());

const client = new SuiClient({
    url: getFullnodeUrl('devnet')
});

const newContainer = async () => {
    const tx = new Transaction();

    const coin = tx.splitCoins(tx.gas, [tx.pure.u64(1_000_000_000)]);
    // tx.mergeCoins(coin, [tx.object("0x123123123121")])

    // tx.makeMoveVec({
    //     type: `${packageId}::hello_world::MessageContainer`,
    //     elements: [tx.object("0x1231312"), tx.object]
    // })


    const object = tx.moveCall({
        target: `${packageId}::hello_world::new_container`,
        arguments: [
            tx.pure.string("My new message"),
            
        ]
    });

    tx.moveCall({
        target: `${packageId}::hello_world::change_message`,
        arguments: [
            object,
            tx.pure.string("My second message")
        ]
    });

    tx.transferObjects([object, coin], tx.pure.address(keypair.toSuiAddress()));

    const response = await client.signAndExecuteTransaction({
        transaction: tx,
        signer: keypair,
        options: {
            showEffects: true,
            showObjectChanges: true,
            showBalanceChanges: true,
            showEvents: true
        }
    });

    console.dir(response, {depth: 6});

}

const changeMessage = async (containerId: string) => {

    const tx = new Transaction();

    tx.moveCall({
        target: `${packageId}::hello_world::change_message`,
        arguments: [
            tx.object(containerId),
            tx.pure.string("Beautiful message")
        ]
    });

    try {
    const response = await client.signAndExecuteTransaction({
        transaction: tx,
        signer: keypair,
        options: {
            showEffects: true,
            showObjectChanges: true,
            showBalanceChanges: true,
            showEvents: true
        }
    });
    console.log(`The transaction was a ${response.effects?.status.status}`);
} catch (err) {
    if (err.status === 429) {
        console.log("Please use an rpc provider.")
    }
}
    
}

// newContainer();

// changeMessage("0xa0d4690fda90f54975243652af068aae3f8d53f123a340c781e85d9270a51fd7")


const readChain = async () => {
    const coinsOfSender = await client.getAllBalances({
        owner: keypair.toSuiAddress(),
    })

    console.log(coinsOfSender.filter(item => item.coinType === "0x2::sui::SUI"))

    client.getObject({id: "0x2342432"});

    let cursor: string | undefined | null = undefined;
    let hasNext = true;
    let result: any = [];
    while (hasNext) {
        const {data, nextCursor, hasNextPage} = await client.getOwnedObjects({owner: "address 0x1231312", cursor});

        result = [...result, ...data];
        cursor = nextCursor;
        hasNext = hasNextPage
    }
    

    client.getBalance({owner: "0x123", coinType: "0x2::sui::SUI"});
    client.getTransactionBlock({digest: "aabbccddff", options: {showEffects: true}});
    
}

// readChain();

const newContainerBuildOnly = async () => {

    




    const tx = new Transaction();


    // tx.setSender(keypair.toSuiAddress());


    const object = tx.moveCall({
        target: `${packageId}::hello_world::new_container`,
        arguments: [
            tx.pure.string("My new message"),
            
        ],
        typeArguments: []
    });

    tx.transferObjects([object], tx.pure.address(keypair.toSuiAddress()));

    const bytes = await tx.build({client});

    return bytes;

    // these can happen in another place
    


}

const executeTx = async (bytes: Uint8Array<ArrayBufferLike>, sender: string) => {

    const tx = Transaction.fromKind(bytes);

  
  
    // const {bytes: bytesAgain, signature} = await keypair.signTransaction(bytes);

    // const response = await client.executeTransactionBlock({
    //     transactionBlock: bytes,
    //     signature: [signature]
    // });

    // client.signAndExecuteTransaction()
}

// newContainerBuildOnly()
