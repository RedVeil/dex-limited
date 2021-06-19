pragma solidity =0.8.5;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MistXRouter.sol";
import "./interfaces/IMistXRouter.sol";
import "./interfaces/IWETH.sol";

contract LimitOrder is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct LimitOrderStruct {
        address fromToken;
        address toToken;
        uint256 amountIn;
        uint256 amountOut;
        uint256 reward;
    }

    IWETH public immutable WETH;
    IMistXRouter public router;
    address public house;
    uint256 public houseRate = 500;
    mapping(address => LimitOrder[]) public limitOrders;


    /* ========== CONSTRUCTOR ========== */
    constructor(
        IWETH _WETH,
        IMistXRouter _router,
        address _house
    ) {
        WETH = _WETH;
        router = _router;
        house = _house;
    }

    /* ========== VIEW FUNCTIONS ========== */



    /* ========== MUTATIVE FUNCTIONS ========== */

    // @notice Allows a anyone to submit an order they would like to get executed
    function makeOrder() external {

    }

    // @notice Allows a maker to change their order
    function changeOrder() external {
      
    }

    // @notice Allows a maker to delete their order
    function deleteOrder() external {
      
    }

    // @notice Allows anyone to take an submitted order and exchange funds OTC
    function takeOrder() external {

    }

    // @notice Allows anyone to execute submitted orders using MistXRouter
    function executeOrder() external {

    }


    /* ========== RESTRICTED FUNCTIONS ========== */

    // @notice Allows house address to change the house address
    function _deleteOrder() internal {}

    // @notice Allows owner to change the house address
    function changeHouseAddress(address _newHouse) external onlyOwner {
      house = _newHouse;
    }

    // @notice Allows owner to change the houseRate
    function changeHouseRate(uint256 _newRate) external onlyOwner {
      houseRate = _newRate;
    }


    /* ========== SETTERS ========== */
    

    /* ========== MODIFIERS ========== */

    /* ========== EVENTS ========== */





}
