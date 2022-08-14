import { config } from '@onflow/fcl';

// console.log("discovery.wallet", process.env.REACT_APP_WALLET_DISCOVERY)
console.log('accessNode.api', process.env.REACT_APP_ACCESS_NODE);
config().put('accessNode.api', process.env.REACT_APP_ACCESS_NODE);
