pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/AddressUtils.sol';
import 'zeppelin-solidity/contracts/token/ERC20/BasicToken.sol';

contract ChimeraBase is BasicToken{
  using SafeMath for uint256;
  using AddressUtils for address;

  // Token name
  string internal name_;

  // Token symbol
  string internal symbol_;

  // Token decimals
  uint256 internal decimals_;

  // Owner address of contract
  address public owner;

  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
  function name() public view returns (string) {
    return name_;
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
  function symbol() public view returns (string) {
    return symbol_;
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
  function decimals() public view returns (uint256) {
    return decimals_;
  }

  /**
   * @dev Events for minting
   */
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  // Check if minting is allowed
  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  // Allow only the owner
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // Allow only the owner
  modifier onlyMinter() {
    require(minters[msg.sender]);
    _;
  }

  mapping(address => bool) public minters;

  event MintersAddressAdded(address addr);
  event MintersAddressRemoved(address addr);

  /**
   * @dev add an address to the minters
   * @param addr address
   * @return true if the address was added to the minters, false if the address was already in the minters
   */
  function addAddressToMinters(address addr) onlyOwner public returns(bool success) {
    if (!minters[addr]) {
      minters[addr] = true;
      emit MintersAddressAdded(addr);
      success = true;
    }
  }

  /**
   * @dev add addresses to the minters
   * @param addrs addresses
   * @return true if at least one address was added to the minters,
   * false if all addresses were already in the minters
   */
  function addAddressesToMinters(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addAddressToMinters(addrs[i])) {
        success = true;
      }
    }
  }

  /**
   * @dev remove an address from the minters
   * @param addr address
   * @return true if the address was removed from the minters,
   * false if the address wasn't in the minters in the first place
   */
  function removeAddressFromMinters(address addr) onlyOwner public returns(bool success) {
    if (minters[addr]) {
      minters[addr] = false;
      emit MintersAddressRemoved(addr);
      success = true;
    }
  }

  /**
   * @dev remove addresses from the minters
   * @param addrs addresses
   * @return true if at least one address was removed from the minters,
   * false if all addresses weren't in the minters in the first place
   */
  function removeAddressesFromMinters(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (removeAddressFromMinters(addrs[i])) {
        success = true;
      }
    }
  }

  // Event for ownership transfer
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }

  /**
   * @dev Mapping for the whitelisted addresses
   */
  mapping(address => bool) public whitelist;

  event WhitelistedAddressAdded(address addr);
  event WhitelistedAddressRemoved(address addr);

  /**
   * @dev Throws if called by any account that's not whitelisted.
   */
  modifier onlyWhitelisted() {
    require(whitelist[msg.sender]);
    _;
  }

  /**
   * @dev add an address to the whitelist
   * @param addr address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
    if (!whitelist[addr]) {
      whitelist[addr] = true;
      emit WhitelistedAddressAdded(addr);
      success = true;
    }
  }

  /**
   * @dev add addresses to the whitelist
   * @param addrs addresses
   * @return true if at least one address was added to the whitelist,
   * false if all addresses were already in the whitelist
   */
  function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addAddressToWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

  /**
   * @dev remove an address from the whitelist
   * @param addr address
   * @return true if the address was removed from the whitelist,
   * false if the address wasn't in the whitelist in the first place
   */
  function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
    if (whitelist[addr]) {
      whitelist[addr] = false;
      emit WhitelistedAddressRemoved(addr);
      success = true;
    }
  }

  /**
   * @dev remove addresses from the whitelist
   * @param addrs addresses
   * @return true if at least one address was removed from the whitelist,
   * false if all addresses weren't in the whitelist in the first place
   */
  function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (removeAddressFromWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

}
