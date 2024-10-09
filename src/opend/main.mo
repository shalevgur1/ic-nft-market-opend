import Principal "mo:base/Principal";
import NFTActorClass "../NFT/nft";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

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
        // Add new NFT to ownership list in ownership HashMap
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

    public query func getListedNFTs() : async [Principal] {
        // Return all NFTs that are listed for selling in the market place.
        let listedNFTs = Iter.toArray(mapOfListings.keys());
        return listedNFTs;
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

    public query func getOriginalOwner(nftPrinc : Principal) : async Principal {
        // Get original owner of NFT (when NFT is listed the owner that displayed is the opend market canister).
        var listing : Listing = switch (mapOfListings.get(nftPrinc)) {
            case null return Principal.fromText("");
            case (?result) result;
        };
        return listing.itemOwner;
    };

    public query func getListedNftPrice(nftPrinc : Principal) : async Nat {
        // Get NFT that is listed for sale price
        var listing : Listing = switch (mapOfListings.get(nftPrinc)) {
            case null return 0;
            case (?result) result;
        };
        return listing.itemPrice;
    };

    public shared(msg) func purchase(nftPrinc: Principal, ownerPrinc: Principal, newOwnerPrinc: Principal) : async Text {
        // Handle purchasing of NFT. Transfer NFT ownership to a new owner.

        // Get required NFT
        var purchasedNFT : NFTActorClass.NFT = switch (mapOfNFTs.get(nftPrinc)) {
            case null return "Requested NFT does not exist";
            case (?result) result;
        };

        // Transfer NFT and change data in HashMaps
        let transferResult = await purchasedNFT.transferOwnership(newOwnerPrinc);
        if (transferResult == "Success") {
            // Delete from market
            mapOfListings.delete(nftPrinc);
            // Delete from previous owner list
            var ownedNFTs : List.List<Principal> = switch (mapOfOwners.get(ownerPrinc)) {
                case null List.nil<Principal>();
                case (?result) result;
            };
            ownedNFTs := List.filter(ownedNFTs, func (listNftPrinc : Principal) : Bool {
                return listNftPrinc != nftPrinc;
            });
            mapOfOwners.put(ownerPrinc, ownedNFTs);
            // Add to new owner list
            addToOwnershipMap(newOwnerPrinc, nftPrinc);
            return "Success";
        } else {
            return transferResult;
        }
    };
};
