import React, { useEffect, useState } from "react";
import logo from "../../assets/logo.png";
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "../../../declarations/nft";
import { idlFactory as tokenIdlFactory } from "../../../declarations/token";
import { Principal } from "@dfinity/principal";
import Button from "./Button";
import { opend } from "../../../declarations/opend";
import CURRENT_USER_ID from "../index";
import PriceLable from "./PriceLable";


function Item(props) {

  const [name, setName] = useState();
  const [owner, setOwner] = useState();
  const [image, setImage] = useState();
  const [sellButton, setButton] = useState();
  const [priceInput, setPriceInput] = useState();
  const [loaderHidden, setLoaderHidden] = useState(true);
  const [blur, setBlur] = useState();
  const [listedText, setListedText] = useState();
  const [priceLable, setPriceLable] = useState();
  const [shouldDisplay, setShouldDisplay] = useState(true);

  const id = props.id;
  const blurStyle = {filter: "blur(4px)"};
  const localHost = "http://localhost:8080/";
  const agent = new HttpAgent({host: localHost});
  // TODO: When deploying live, remove the following line
  agent.fetchRootKey();
  // The NFTActor Created when NFT is loaded
  let NFTActor;

  async function loadNFT() {
    NFTActor = await Actor.createActor(idlFactory, {
      agent,
      canisterId: id
    });

    const name = await NFTActor.getName();
    const owner = await NFTActor.getOwner();
    const imageData = await NFTActor.getAsset();
    const imageContent = new Uint8Array(imageData);
    const image = URL.createObjectURL(new Blob([imageContent.buffer], {type: "image/png"}));

    setName(name);
    setOwner(owner.toText());
    setImage(image);

    // Check item role (dependes on the tab the user is in).
    // Change style accordingly.
    if (props.role === "collection") {
      // Check if NFT is listed to change frontend style.
      const nftIsListed = await opend.isListed(id);
      if (nftIsListed) {
        setOwner("OpenD");
        setBlur(blurStyle);
        setListedText("Listed");
      } else {
        setButton(<Button handleClick={handleSell} text="Sell"/>);
      }
    } else if (props.role === "discover") {
      const originalOwner = await opend.getOriginalOwner(id);
      if (originalOwner.toText() != CURRENT_USER_ID && originalOwner.toText() != "") {
        setButton(<Button handleClick={handleBuy} text="Buy"/>);
      }

      const price = await opend.getListedNftPrice(id);
      setPriceLable(<PriceLable sellPrice={price.toString()} />);

    } else if (props.role === "minted") {
      setButton();
      setBlur();
      setListedText();
    }
  }

  useEffect(() => {
    loadNFT();
  }, []);

  let price;
  function handleSell() {
    // Handle the listing of an NFT in the market place.
    setPriceInput(
      <input
        placeholder="Price in DONG"
        type="number"
        className="price-input"
        value={price}
        onChange={(e) => price=e.target.value}
      />
    ); 
    setButton(<Button handleClick={sellItem} text="Confirm"/>);
  }

  async function sellItem() {
    // List an NFT for sale
    setBlur(blurStyle);
    setLoaderHidden(false);
    const listingResult = await opend.listItem(id, Number(price));
    console.log(listingResult);
    if(listingResult === "Success") {
      const opendPrinc = await opend.getOpendCanisterPrinc();
      // Transfering ownership to the opend canister (to the "market canister")
      const transferResult = await NFTActor.transferOwnership(opendPrinc);
      console.log(transferResult);
      if(transferResult == "Success") {
        setLoaderHidden(true);
        setButton();
        setPriceInput();
        setOwner("OpenD");
        setListedText("Listed");
      }
    }
  }

  async function handleBuy() {
    // Handle the buying procedure of an NFT from the market place.
    setLoaderHidden(false);

    const tokenActor = await Actor.createActor(tokenIdlFactory, {
      agent,
      canisterId: Principal.fromText("sp3hj-caaaa-aaaaa-aaajq-cai")
    });

    const sellerId = await opend.getOriginalOwner(id);
    const nftPrice = await opend.getListedNftPrice(id);

    // Transfer tokens between buyer and seller
    const result = await tokenActor.transfer(sellerId, nftPrice);

    if (result === "Success") {
      // Transfer NFT ownership to buyer
      const transferResult = await opend.purchase(id, sellerId, CURRENT_USER_ID);
      console.log("Transfer NFT result: " + transferResult);
      setLoaderHidden(true);
      setShouldDisplay(false);
    }
  }

  return (
    <div style={{ display: shouldDisplay ? "inline" : "none" }} className="disGrid-item">
      <div className="disPaper-root disCard-root makeStyles-root-17 disPaper-elevation1 disPaper-rounded">
        <img
          className="disCardMedia-root makeStyles-image-19 disCardMedia-media disCardMedia-img"
          src={image}
          style={blur}
        />
        <div hidden={loaderHidden} className="lds-ellipsis">
          <div></div>
          <div></div>
          <div></div>
          <div></div>
        </div>
        <div className="disCardContent-root">
          {priceLable}
          <h2 className="disTypography-root makeStyles-bodyText-24 disTypography-h5 disTypography-gutterBottom">
            {name}<span className="purple-text"> {listedText}</span>
          </h2>
          <p className="disTypography-root makeStyles-bodyText-24 disTypography-body2 disTypography-colorTextSecondary">
            Owner: {owner}
          </p>
          {priceInput}
          {sellButton}
        </div>
      </div>
    </div>
  );
}

export default Item;
