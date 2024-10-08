import React, { useEffect, useState } from "react";
import Item from "./Item";
import { Principal } from "@dfinity/principal";

function Gallery(props) {

  const [items, setItems] = useState();
  const [loadDisabled, setLoadDisabled] = useState(false);

  function fetchNFTs() {
    if (props.nftList != undefined) {
      setItems(props.nftList.map((nft) => <Item id={nft} key={nft.toText()} role={props.role}/>));
      setLoadDisabled(false);
    } else {
      setLoadDisabled(true);
    }
  }

  useEffect(() => {fetchNFTs();}, []);

  if(!items) {
    return(
      <div hidden={!loadDisabled} className="lds-ellipsis">
        <div></div>
        <div></div>
        <div></div>
        <div></div>
      </div>
      );
  } else {
    return(
    <div className="gallery-view">
      <h3 className="makeStyles-title-99 Typography-h3">{props.title}</h3>
      <div className="disGrid-root disGrid-container disGrid-spacing-xs-2">
        <div className="disGrid-root disGrid-item disGrid-grid-xs-12">
          <div className="disGrid-root disGrid-container disGrid-spacing-xs-5 disGrid-justify-content-xs-center">
            {items}
          </div>
        </div>
      </div>
    </div>
    );
  };
}

export default Gallery;
