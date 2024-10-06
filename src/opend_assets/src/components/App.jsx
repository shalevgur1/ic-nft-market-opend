import React from "react";
import Header from "./Header";
import Footer from "./Footer";
import "bootstrap/dist/css/bootstrap.min.css";
import Item from "./Item";
import Minter from "./Minter";
import homeImage from "../../assets/home-img.png";

function App() {

  // const NFTID = "ryjl3-tyaaa-aaaaa-aaaba-cai";

  return (
    <div className="App">
      <Header />
      {/* <Item 
      id={NFTID}
      /> */}
      {/* <img className="bottom-space" src={homeImage} /> */}
      <Footer />
    </div>
  );
}

export default App;
