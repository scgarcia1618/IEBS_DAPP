import React, { Component } from "react";
import "./App.css";
import Marketplace from "../contracts/Marketplace.json";
import getWeb3 from "../helpers/getWeb3";
import Popup from 'reactjs-popup';
import 'reactjs-popup/dist/index.css';

const CONTRACT_ADDRESS = require("../contracts/Marketplace.json").networks[5777].address//"0x6fe850679b27727bca6a26be87ae63f5cc38ba67";//
const CONTRACT_ABI = require("../contracts/Marketplace.json").abi

class App extends Component {
  state = { web3: null, accounts: null, contract: null , cart: [], cartTotal: 0};

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the network ID
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = Marketplace.networks[networkId];

      // Check if the Smart Contract is deployed on Network with ID: XY
      if (deployedNetwork === undefined) {
        // alert("Por favor, conectate a Ganache para continuar utilizando la aplicacion");
        this.setState({ web3, accounts, networkId })
        return;
      }

      // Create the Smart Contract instance
      const instance = new web3.eth.Contract(CONTRACT_ABI, CONTRACT_ADDRESS);

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.

    // Get Item Count information
    const itemCount = await instance.methods.itemCount().call();
    const items = [];
    for (let i = 1; i <= itemCount; i++) {
      const item = await instance.methods.getItemDetail(i).call();

      items.push(item);
    } 
    console.log(items);

    const arrayDataItems = items.map(item => 
      <li key={item.id}>
        <p>ID: {item.id} - {item.name}</p>
        <div class="tooltip">{item.price} WEI
          <span class="tooltiptext">{web3.utils.fromWei(item.price, "ether")}ETH</span>
        </div>


        <div class="tooltip">Merchant Name: {item.merchantName} 
          <span class="tooltiptext">{item.merchantAddress}</span>
        </div>
        <p></p>
        <img src={item.imageLink} alt="" width="200"></img>
        <button id="button-call" onClick={async () => {await this.addToCart(item.id, item.price);} }> Add to Cart</button>
      </li>
  
    )
    var merchantBalance = await instance.methods.getMerchantBalance(accounts[0]).call({ from: accounts[0] });
    this.setState({ web3, accounts, networkId, contract: instance , arrayDataItems: arrayDataItems, itemCount: itemCount, merchantBalance: merchantBalance});
    this.getPurchases();
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }

  };
 
  componentDidUpdate() {
    this.handleMetamaskEvent()
  }

  // --------- METAMASK EVENTS ---------
  handleMetamaskEvent = async () => {

    window.ethereum.on('accountsChanged', function (accounts) {
      // Time to reload your interface with accounts[0]!
      alert("Incoming event from Metamask: Account changed")
      window.location.reload(true)
    })

    window.ethereum.on('networkChanged', function (networkId) {
      // Time to reload your interface with the new networkId
      alert("Incoming event from Metamask: Network changed")
      window.location.reload()
    })
  }
  
  addToCart = async (id, amount) => {
    var cart = this.state.cart;
    cart.push(id);
    var cartTotal = this.state.cartTotal;
    cartTotal = parseFloat(cartTotal) + parseFloat(amount);
    this.setState({ cart , cartTotal});
  }

  // -obtengo info de las compras
  getPurchases = async () => {
    const { accounts, contract } = this.state;

    // Get the purchases information
    const purchases = await contract.methods.getAddressPurchases().call({ from: accounts[0] });
    
    const arrayDataPurchases = purchases.map(item => 
      <li key={item}>
        <p>{item}</p>
      </li>
    )

    this.setState({ arrayDataPurchases });
  }

  // PURCHASE FUNCTION
  purchase = async (ids, amount) => {

    const { accounts, contract } = this.state;
    // Purchase selectedItem
    if(accounts != null){
      await contract.methods.buy(ids).send({ from: accounts[0], value: amount});
      this.getPurchases();
      this.setState({cart: [], cartTotal: 0});
    }
  }

    // WITHDRAW FUNCTION
    withdraw = async () => {

      const { accounts, contract , merchantBalance } = this.state;
      // Purchase selectedItem
      if(accounts != null){
        await contract.methods.withdrawMoneyTo(accounts[0], merchantBalance).send({ from: accounts[0] });
        this.setState({merchantBalance: 0});
      }
    }
    
  render() {



    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    
    return (
      <div className="App">
        <h1>Ethereum Marketplace</h1>
        <Popup trigger={this.state.merchantBalance == 0 && <button> Cart</button>} position="right center" >
          <div>Selected items: 
              <ul>
                {this.state.cart.map(item => (
                  <li key={item}>{item}</li>
                ))}
              </ul>

          </div>
          {this.state.cartTotal > 0 && 
              <div>Total amount: {this.state.cartTotal} ({this.state.web3.utils.fromWei(this.state.cartTotal.toString(), "ether")} ETH)</div>
          }
          <p/>
          {this.state.cartTotal > 0 && <button id="button-call" onClick={async () => {await this.purchase(this.state.cart, this.state.cartTotal);} }> BUY</button>}

        </Popup>
        {this.state.merchantBalance > 0 && <button id="button-withdraw" onClick={async () => {if (window.confirm('Are you sure you want to withdraw your balance?')) {this.withdraw()}} }> Withdraw</button>}

        {/* Context Information: Account & Network */}
        <div className="Context-information">
          <p> Yout address: {this.state.accounts[0]}</p>
          <p> Network connected: {this.state.networkId}</p>
          {this.state.merchantBalance > 0 &&<p> Available balance to withdraw: {this.state.merchantBalance} ({this.state.web3.utils.fromWei(this.state.merchantBalance.toString(), "ether")} ETH)</p>}
          {this.state.merchantBalance == 0 && <p> Historico de Items Comprados:</p>}
          {this.state.merchantBalance == 0 && <ul>{this.state.arrayDataPurchases}</ul>}


        </div>

        {/* Items information */}
        {this.state.merchantBalance == 0 &&<h2 id="inline">Items</h2>}
        {
            <div className="container">
              {this.state.merchantBalance == 0 &&<ul>{this.state.arrayDataItems}</ul>}
            </div>
        }
      </div >
    );
  }
}

export default App;