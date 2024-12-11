# Proof Of Scrub

## Summary 

This was a hacker house project @Magik6k and myself worked on in Nov 2024.  The motivation came from @AngeloAVV who wanted true scrubbing with non-legal contract trust assumptions.  Since snarks aren't there we decided to build something with TEEs.  

We didn't finish but @Magik got SEV SNP running on Qemu and generated an attestation.  And we got the signature validating from within solidity code (that's what's in this repo).  These pieces are the heart of the technical challenge of using AMD TEEs in a decentralized compute / web3 setting.

## PoScrub protocol / smart contract

Sample randomness from the chain, insert it alongside a stream of bytes to be scrubbed into the TEE.  The TEE hashes byte stream and attests to 1. hash of randomness value 2. hash of byte stream.  A smart contract validates certificate chain and the attestation signature to root trust in sev snp.  And it validates that the randomness was sampled recently.  Input to the smart contract is the entire attestation from which the vm measurement is read and compared with the expected measurement corresponding to the trusted VM state. The message in the attestation is the two values above.  The smart contract checks that the hash of the file is as expected.

## Running sev snp with Qemu

@Magik6k has notes, it involved a lot of recompiling the kernel and about a week of banging one's head against one's computer.


## Missing pieces 

The main issue with SEV SNP in solidity is that the cryptography choices are all weird from evm point of view.  SHA 384, EC P384 and RSA PSS.  We found Marlin protocol OSS reimplementing SHA 384 and EC P384 (thanks!) which is enough to validate the attestation signature.  However I haven't found RSA PSS only the standard PKCS 1, so there is some light dev work to validate the certificate chain. There is no reason we can't just use modexp precompile as in PKCS1 implementations so it shouldn't be too bad.  But wihtout RSA PSS Cert chain validation in contract is main TODO.

Still need to actually implement the function hosted on the VM taking in a stream of data + DRAND value, hashing data and output hash alongside DRAND value in the attestation, i.e. the scrubbing application on top of SEVSNP.  And then the corresponding contract pieces which are relatively quite simple for filecoin since we can just get drand from precompile.  On other chains you could use some other randomness source which is maybe easier than implementing DRAND validation.  But with new BLS precompiles that should be pretty easy too.

Would then be cool to hook the scrubbing thing up to a one time payment agreement thing.








## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

## PoScrub

We don't want no invalid scrubs
An erroneous scrub is a scrub that doesn't get no love from me
We'll catch him the passenger side of his best friend's ride
Using our TEE Sev S N P 

-- TLC roughly

```shell
$ forge --help
$ anvil --help
$ cast --help
```
