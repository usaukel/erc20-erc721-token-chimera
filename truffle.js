// See <http://truffleframework.com/docs/advanced/configuration>

require('babel-register');
require('babel-polyfill');

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      gas: 100000000,
      network_id: "*" // Match any network id
    },
    livenet: {
      host: "localhost",
      port: 8545,
      gas: 70000000,
      network_id: "1" // Match any network id
    },
    ropsten: {
      host: "localhost",
      port: 18545,
      network_id: 3, // official id of the ropsten network
      gas: 30000000
    }
  }
};
