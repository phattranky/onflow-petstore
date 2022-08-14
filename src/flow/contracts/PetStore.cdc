pub contract PetStore {
  pub var owners: {UInt64: Address}

  pub resource NFT {
    pub let id: UInt64
    pub var metadata: {String: String}

    init(id: UInt64, metadata: {String: String}) {
      self.id = id
      self.metadata = metadata
    }
  }

  pub resource interface NFTReceiver {
    pub fun withdraw(id: UInt64): @NFT

    pub fun deposit(token: @NFT)

    pub fun getTokenIds(): [UInt64]

    pub fun getTokenMetadata(id: UInt64): {String: String}

    // pub fun updateTokenMetadata(id: UInt64, metadata: {String: String})
  }

  pub resource NFTCollection: NFTReceiver {
    access(account) var ownedNFTs: @{UInt64: NFT}
    
    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }

    pub fun withdraw(id: UInt64): @NFT {
      let token <- self.ownedNFTs.remove(key: id)
      return <- token!
    }

    pub fun deposit(token: @NFT) {
      PetStore.owners[token.id] = self.owner?.address!
      self.ownedNFTs[token.id] <-! token
    }

    pub fun getTokenIds(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun getTokenMetadata(id: UInt64): {String: String} {
      let metadata = self.ownedNFTs[id]?.metadata
      return metadata!
    }

    // pub fun updateTokenMetadata(id: UInt64, metadata: {String: String}) {
    //   for key in metadata.keys {
    //     self.ownedNFTs[id]?.metadata?.insert(key: key, metadata[key]!)
    //   }
    // }
  }

  pub fun createNFTCollection(): @NFTCollection {
    return <- create NFTCollection()
  }

  pub resource NFTMinter {
    pub var idCount: UInt64

    init() {
      self.idCount = 1
    }

    pub fun mint(_ metadata: {String: String}): @NFT {
      let token <- create NFT(id: self.idCount, metadata: metadata)

      PetStore.owners[self.idCount] = PetStore.account.address

      self.idCount = self.idCount + 1 as UInt64

      return <- token
    }
  }

  init() {
    // Set `owners` to an empty dictionary.
    self.owners = {}

    // Create a new `@NFTCollection` instance and save it in `/storage/NFTCollection` domain,
    // which is only accessible by the contract owner's account.
    self.account.save(<-create NFTCollection(), to: /storage/NFTCollection)

    // "Link" only the `@NFTReceiver` interface from the `@NFTCollection` stored at `/storage/NFTCollection` domain to the `/public/NFTReceiver` domain, which is accessible to any user.
    self.account.link<&{NFTReceiver}>(/public/NFTReceiver, target: /storage/NFTCollection)

    // Create a new `@NFTMinter` instance and save it in `/storage/NFTMinter` domain, accesible
    // only by the contract owner's account.
    self.account.save(<-create NFTMinter(), to: /storage/NFTMinter)
  }
}