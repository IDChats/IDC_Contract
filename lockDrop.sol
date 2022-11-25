// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: lockDrop.sol


// File: lockDrop.sol
pragma solidity 0.8.1;




contract OwnerPausable is Ownable, Pausable {
    /// @notice Pauses the contract.
    function pause() public onlyOwner {
        Pausable._pause();
    }
    /// @notice Unpauses the contract.
    function unpause() public onlyOwner {
        Pausable._unpause();
    }

}
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LockDrop is OwnerPausable {

    address public rewardToken;
    address public usdt;
    address[] public funders;

    uint16 constant TEST_MONTHS = 2;
    uint16 constant SIX_MONTHS = 182;
    uint16 constant ONE_YEAR = 365;
    uint16[]  PERIOD = [TEST_MONTHS,SIX_MONTHS,ONE_YEAR];
    uint256 public tokenTotalSupply;
    uint256 public tokenCapacity;
    uint256 public ending;
    uint256 public constant TIMEUINT = 1 days;
    uint256 public constant RELEASEUINT = 182 days;

    struct Lock {
        uint amount;
        uint256 numOfTokens;
        uint256 releasedToken;
        uint256 lockEnding;
    }

    mapping ( uint => mapping (address => Lock) )  locks;
    mapping(address => uint256) public addressToAmountFunded;


    event Deposit(address indexed sender, uint numOfTokens, uint initAmount,uint lengthInDays);
    event Unlock(address indexed sender, uint lengthInDays);
    event WithdrawEvent(address indexed sender, uint value,uint lengthInDays);

    modifier hasNotEnded() {
        require(block.timestamp <= ending, "lock-drop-ended");
        _;
    }

    modifier hasEnded() {
        require(block.timestamp  > ending, "lock-drop-still-active");
        _;
    }



    constructor(uint initTokenCapacity,address token ,uint lockJoinInDays, address UsdtAddress)  {
        require(UsdtAddress != address(0),"usdt address wrong");
        require(initTokenCapacity>0,"tokenCapacity >0");
        require(token != address(0),"token address wrong");

    unchecked{
        ending = (block.timestamp + TIMEUINT*lockJoinInDays);
        usdt = UsdtAddress;
    }

        tokenCapacity = initTokenCapacity;
        tokenTotalSupply = initTokenCapacity;
        rewardToken = token;
    }


    function initial( )external  onlyOwner  {
        bool success = IERC20(rewardToken).transferFrom(msg.sender, address(this), tokenTotalSupply);
        require(success, "Call failed");
    }

    function adminWithDraw()external onlyOwner {
        require(block.timestamp> ending+ (ONE_YEAR * TIMEUINT) + RELEASEUINT,"now time  is not valid");
        bool successUsdt = IERC20(usdt).transfer(msg.sender,IERC20(usdt).balanceOf(address(this)));
        require(successUsdt, "Call failed");
        bool successRewardToken = IERC20(rewardToken).transfer(msg.sender,tokenCapacity);
        require(successRewardToken, "Call failed");
    }

    function lockERC20(uint lengthInDays,uint initAmount)  external hasNotEnded  whenNotPaused{

        require(initAmount >0 ,"invalid-value");
        require(tokenCapacity > 0, "no-more-tokens-available");
        require(lengthInDays ==TEST_MONTHS || lengthInDays ==  SIX_MONTHS || lengthInDays == ONE_YEAR,"invalid-lengtInDays");

    unchecked{
        uint _numOfTokens =(initAmount*uint(2));
        require(_numOfTokens <= tokenCapacity, "amount-exceeds-available-tokens");
        tokenCapacity = (tokenCapacity - _numOfTokens);
        if (locks[lengthInDays][msg.sender].amount == 0){
            Lock memory l = Lock({
            amount: initAmount,
            numOfTokens: _numOfTokens,
            lockEnding: ( ending+ (lengthInDays* TIMEUINT)),
            releasedToken:0
            });
            locks[lengthInDays][msg.sender]=l;
        }else{
            locks[lengthInDays][msg.sender].amount = (locks[lengthInDays][msg.sender].amount + initAmount);
            locks[lengthInDays][msg.sender].numOfTokens = (locks[lengthInDays][msg.sender].numOfTokens + _numOfTokens);
        }
        emit Deposit(msg.sender, _numOfTokens, initAmount,lengthInDays);

        bool success = IERC20(usdt).transferFrom(msg.sender, address(this), initAmount);
        require(success, "Call failed");
    }
    }

    function unlock(uint lengthInDays) external hasNotEnded  whenNotPaused{

        require(locks[lengthInDays][msg.sender].amount > 0, "deposit-already-unlocked");
        Lock memory l = locks[lengthInDays][msg.sender];
        delete locks[lengthInDays][msg.sender];
    unchecked{
        tokenCapacity = (tokenCapacity +  l.numOfTokens);
    }
        emit Unlock(msg.sender, lengthInDays);
        bool success =  IERC20(usdt).transfer(msg.sender,  l.amount);
        require(success, "Call failed");

    }

    function withdraw(uint lengthInDays) external hasEnded  whenNotPaused{
        require((locks[lengthInDays][msg.sender].numOfTokens - locks[lengthInDays][msg.sender].releasedToken) > 0,
            "no-token-withdraw");
        Lock memory l = locks[lengthInDays][msg.sender];
    unchecked{
        uint256 rewardAmount = vestedAmount( l , uint256(block.timestamp)  );
        locks[lengthInDays][msg.sender].releasedToken += rewardAmount;

        require(rewardAmount > 0, "no-locked-amount-found");

        emit WithdrawEvent(msg.sender, rewardAmount,lengthInDays);

        bool success = IERC20(rewardToken).transfer(msg.sender,  rewardAmount);
        require(success, "Call failed");
    }
    }

    function withdrawAll() external hasEnded whenNotPaused{
        uint totalWithdraw = 0;
        for(uint i=0;i<PERIOD.length; i++){
        unchecked{
            if ((locks[PERIOD[i]][msg.sender].numOfTokens - locks[PERIOD[i]][msg.sender].releasedToken) <= 0){
                continue;
            }
            Lock memory l = locks[PERIOD[i]][msg.sender];
            uint256 rewardAmount = vestedAmount( l , uint256(block.timestamp)  );
            if( rewardAmount <=0){
                continue;
            }
            locks[PERIOD[i]][msg.sender].releasedToken += rewardAmount;
            totalWithdraw += rewardAmount;
            emit WithdrawEvent(msg.sender, rewardAmount,PERIOD[i]);

        }

        }
        require(totalWithdraw > 0, "no-locked-amount-found");
        bool success = IERC20(rewardToken).transfer(msg.sender,  totalWithdraw);
        require(success, "Call failed");

    }


    function getTotalLocks(address user,uint lengthInDays) external view returns (uint _length) {
        return locks[lengthInDays][user].releasedToken;
    }

    function getLockAt(address user, uint lengthInDays) external view returns (uint amount, uint numOfTokens, uint lockEnding,uint releaseToken) {
        return (locks[lengthInDays][user].amount, locks[lengthInDays][user].numOfTokens, locks[lengthInDays][user].lockEnding,locks[lengthInDays][user].releasedToken);
    }

    function vestedAmount(Lock  memory lock ,uint256 timestamp ) public pure returns (uint256) {

    unchecked{
        if (timestamp < lock.lockEnding) {
            return 0;
        } else if (timestamp > lock.lockEnding + RELEASEUINT ) {
            return lock.numOfTokens  - lock.releasedToken ;
        } else {
            return (lock.numOfTokens * (timestamp - lock.lockEnding)) / RELEASEUINT  - lock.releasedToken;
        }
    }
    }

    function fund() public payable {
        require(msg.value>= 0, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    function withdrawETH() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}

