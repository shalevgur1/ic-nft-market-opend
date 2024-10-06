import Principal "mo:base/Principal";
import NFTActorClass "../NFT/nft";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Debug "mo:base/Debug";

actor OpenD {

    // NFTs HashMap list
    var mapOfNFTs = HashMap.HashMap<Principal, NFTActorClass.NFT>(1, Principal.equal, Principal.hash);
    // Owners HashMap list. Including all principals of owners of NFT.
    // Match a list of NFTs for each owner of NFTs  - owner-principal : list-of-nfts
    var mapOfOwners = HashMap.HashMap<Principal, List.List<Principal>>(1, Principal.equal, Principal.hash);
 
    public shared(msg) func mint(imgData: [Nat8], name: Text) : async Principal {
        // Minting a new NFT using the nft actor class from nft.mo
        let owner : Principal = msg.caller;

        let newNFT = await NFTActorClass.NFT(name, owner, imgData);

        let newNFTPrincipal = await newNFT.getCanisterId();

        // Adding new nft to the nft's HashMap list and to the owner list
        mapOfNFTs.put(newNFTPrincipal, newNFT);
        addToOwnershipMap(owner, newNFTPrincipal);

        // Returning the principel of the canister of the new NFT
        return newNFTPrincipal;
    };

    private func addToOwnershipMap(owner: Principal, nftPrincipal: Principal) {
        // Get list of NFTs by owner principal. return null for new owners
        var ownedNFTs : List.List<Principal> = switch (mapOfOwners.get(owner)) {
            case null List.nil<Principal>();
            case (?result) result;
        };

        ownedNFTs := List.push(nftPrincipal, ownedNFTs);
        mapOfOwners.put(owner, ownedNFTs);
    };

    public query func getOwnedNFTs(user: Principal) : async [Principal] {
        var userNFTs : List.List<Principal> = switch (mapOfOwners.get(user)) {
            case null List.nil<Principal>();
            case (?result) result;
        };

        return List.toArray(userNFTs);
    };

};
