pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';

import './ChimeraBase.sol';

contract Chimera is ChimeraBase {
  using SafeMath for uint256;

  struct NonFungibleAsset {
    uint256 assetId;
    string name;
  }

  // Events
  event AddAsset(uint256 assetId);
  event RemoveAsset(uint256 assetId);
  event AddMediaUri(uint256 assetId, string mediaUri);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _approved, uint256 _value);

  mapping (uint256 => NonFungibleAsset) public assets;
  mapping (uint256 => string[]) public mediaUri;
  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 public numAssets;
  mapping(address => uint256) balances;

  constructor(string _name, string _symbol, uint256 _decimals, uint256 _totalSupply) public {
    name_ = _name;
    symbol_ = _symbol;
    decimals_ = _decimals;
    totalSupply_ = _totalSupply;
    owner = msg.sender;
    balances[msg.sender] = _totalSupply;
    numAssets = 0;
  }

  /**
   * @dev Gets the balance of the specified address
   * @param _owner address to query the balance of
   * @return uint256 representing the amount owned by the passed address
   */
  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return balances[_owner];
  }

  /**
   * @dev Transfer tokens from the calling address to another
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
    function approve(address _spender, uint256 _value) public returns (bool) {
      allowed[msg.sender][_spender] = _value;
      emit Approval(msg.sender, _spender, _value);
      return true;
    }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  /**
    * @dev Add a diamond to the basket. Can only be called by the owner of the Basket.
    *      Generates a AddDiamond event
    * @param _assetId Id of the asset.
    * @param _mediaUri The location of verifcation media
   */
  function addAsset(uint256 _assetId, string _name, string _mediaUri) onlyOwner canMint public returns (bool) {
    NonFungibleAsset memory newAsset = NonFungibleAsset({
      assetId: _assetId,
      name: _name
    });
    numAssets = numAssets.add(1);
    assets[_assetId] = newAsset;
    mediaUri[_assetId].push(_mediaUri);
    emit AddAsset(_assetId);
    emit AddMediaUri(_assetId, _mediaUri);
    return true;
  }

  /**
    * @dev Removes an asset from the contract. Can only be called by the owner of the contract.
    *      Generates a RemoveAsset event
    * @param _assetId Id of the asset.
   */
  function removeAsset(uint256 _assetId) onlyOwner public {
    numAssets = numAssets.sub(1);
    delete assets[_assetId];
    delete mediaUri[_assetId];
    emit RemoveAsset(_assetId);
  }

  function addMediaUri(uint256 _assetId, string _mediaUri) onlyOwner canMint public returns (bool) {
    require(assets[_assetId].assetId != 0);
    mediaUri[_assetId].push(_mediaUri);
    emit AddMediaUri(_assetId, _mediaUri);
  }

}
