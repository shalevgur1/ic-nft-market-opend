import Principal "mo:base/Principal";
import NFTActorClass "../NFT/nft";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Debug "mo:base/Debug";

actor OpenD {

    // A data type for the listed nfts for sale HashMap.
    // Includes information regarding the item listed for sale.
    private type Listing = {
        itemOwner: Principal;
        itemPrice: Nat;
    };

    // NFTs HashMap list
    var mapOfNFTs = HashMap.HashMap<Principal, NFTActorClass.NFT>(1, Principal.equal, Principal.hash);
    // Owners HashMap list. Including all principals of owners of NFT.
    // Match a list of NFTs for each owner of NFTs  - owner-principal : list-of-nfts
    var mapOfOwners = HashMap.HashMap<Principal, List.List<Principal>>(1, Principal.equal, Principal.hash);
    // An HashMap includes all the NFTs that are listed for sale
    var mapOfListings = HashMap.HashMap<Principal, Listing>(1, Principal.equal, Principal.hash);
 
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
        // Return all NFTs owned by a given user. Return an array datatype.
        var userNFTs : List.List<Principal> = switch (mapOfOwners.get(user)) {
            case null List.nil<Principal>();
            case (?result) result;
        };

        return List.toArray(userNFTs);
    };

    public shared(msg) func listItem(itemPrincipal: Principal, price: Nat) : async Text {
        // List an nft for sale for sale. Include the nft in the list HashMap
        var item : NFTActorClass.NFT = switch (mapOfNFTs.get(itemPrincipal)) {
            case null return "NFT does not exist.";
            case (?result) result;
        };

        let owner = await item.getOwner();
        if(Principal.equal(owner, msg.caller)) {
            let newListing : Listing = {
                itemOwner = owner;
                itemPrice = price;
            };
            mapOfListings.put(itemPrincipal, newListing);
            return "Success";
        } else {
            return "The NFT is not owned by the requested user";
        }
    };

    public query func getOpendCanisterPrinc() : async Principal {
        // Return the opend canister principal id.
        return Principal.fromActor(OpenD);
    };

    public query func isListed(princ : Principal) : async Bool {
        // Check if an NFT is listed or not.
        if (mapOfListings.get(princ) != null) {
            return true;
        } else {
            return false;
        }
    };
};
