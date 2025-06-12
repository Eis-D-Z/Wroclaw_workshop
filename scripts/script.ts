import { getFullnodeUrl, SuiClient } from "@mysten/sui/client";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { Transaction } from "@mysten/sui/transactions";
import { fromBase64 } from "@mysten/sui/utils";



const b64priv ="AIVSfm/gdSJmyCAUEdCqww9ubQ1XQLd+y4n0xc4IeakG";

const keyArray = Array.from(fromBase64(b64priv));
keyArray.shift();

const keypair = Ed25519Keypair.fromSecretKey(Uint8Array.from(keyArray));

const packageId = "0xbfbe74bb5c4b9d410fc0efe0db4030774d574347286888dc21dfda54f8d038f0";
console.log(keypair.toSuiAddress());
const client = new SuiClient({
    url: getFullnodeUrl('devnet')
});
const newContainer = async () => {
    const tx = new Transaction();

    let object = tx.moveCall({
        target: `${packageId}::hello_world::new_container`,
        arguments: [
            tx.pure.string("My new message")
        ]
    });

    tx.transferObjects([object], tx.pure.address(keypair.toSuiAddress()));

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

newContainer();