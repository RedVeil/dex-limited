// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MistXRouter.sol";
import "./interfaces/IMistXRouter.sol";
import "./interfaces/IWETH.sol";

contract LimitOrderMarket is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct LimitOrder {
        address fromToken;
        address toToken;
        uint256 amountIn;
        uint256 amountOut;
        uint256 deadline;
        uint256 reward;
        address maker;
    }

    IWETH public immutable WETH;
    IMistXRouter public router;
    address public house;
    uint256 public houseRate = 500;
    mapping(bytes32 => LimitOrder) public limitOrders;

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
    function makeOrder(bytes32 _orderId, LimitOrder calldata _limitOrder)
        external
    {
        //Check that the order doesnt already exist
        require(
            limitOrders[_orderId].maker == address(0),
            "cant overwrite order"
        );
        require(
            _limitOrder.maker == msg.sender,
            "dont create orders for others"
        );
        require(
            _limitOrder.deadline > block.timestamp,
            "Deadline must be in the future"
        );
        require(_limitOrder.reward >= 200, "dont be stingy");

        //TODO deal with WETH
        limitOrders[_orderId] = _limitOrder;
        emit OrderCreated(_orderId, _limitOrder);
    }

    // @notice Allows a maker to change their order
    function changeOrder(bytes32 _orderId, LimitOrder calldata _limitOrder)
        external
    {
        require(
            limitOrders[_orderId].maker == msg.sender,
            "dont edit orders for others"
        );
        require(
            _limitOrder.maker == msg.sender,
            "dont create orders for others"
        );
        require(
            _limitOrder.deadline > block.timestamp,
            "Deadline must be in the future"
        );
        require(_limitOrder.reward >= 200, "dont be stingy");

        limitOrders[_orderId] = _limitOrder;
        emit OrderChanged(_orderId, _limitOrder);
    }

    // @notice Allows a maker to delete their order
    function deleteOrder(bytes32 _orderId) external {
        require(
            limitOrders[_orderId].maker == msg.sender,
            "dont delete orders for others"
        );
        _deleteOrder(_orderId, msg.sender);
    }

    // @notice Allows anyone to take an submitted order and exchange funds OTC
    function takeOrder(bytes32 _orderId) external {
        LimitOrder memory limitOrder = limitOrders[_orderId];
        require(limitOrder.deadline > block.timestamp, "deadline over");
        uint256 fee = limitOrder.amountIn.mul(limitOrder.reward).div(10_000);
        require(
            IERC20(limitOrder.fromToken).balanceOf(limitOrder.maker) >=
                limitOrder.amountIn.add(fee),
            "maker cant pay"
        );
        require(
            IERC20(limitOrder.toToken).balanceOf(msg.sender) >=
                limitOrder.amountOut,
            "taker cant pay"
        );

        uint256 houseFee = limitOrder.amountIn.mul(houseRate).div(10_000);
        uint256 takerFee = fee.sub(houseFee);
        IERC20(limitOrder.toToken).safeTransferFrom(
            msg.sender,
            limitOrder.maker,
            limitOrder.amountOut
        );

        _payFees(
            limitOrder.fromToken,
            limitOrder.maker,
            msg.sender,
            limitOrder.amountIn.add(takerFee),
            houseFee
        );

        _deleteOrder(_orderId, limitOrder.maker);
        emit OrderFulfilled(_orderId, msg.sender);
    }

    // @notice Allows anyone to execute submitted orders using MistXRouter
    function executeOrder(
        bytes32 _orderId,
        uint256 _deadline,
        uint256 _bribe
    ) external {
        LimitOrder memory limitOrder = limitOrders[_orderId];
        require(limitOrder.deadline > block.timestamp, "deadline over");
        uint256 fee = limitOrder.amountIn.mul(limitOrder.reward).div(10_000);
        require(
            IERC20(limitOrder.fromToken).balanceOf(limitOrder.maker) >=
                limitOrder.amountIn.add(fee),
            "maker cant pay"
        );
        uint256 houseFee = limitOrder.amountIn.mul(houseRate).div(10_000);
        uint256 takerFee = fee.sub(houseFee);
        address[] memory path;
        path[0] = limitOrder.fromToken;
        path[1] = limitOrder.toToken;
        if (limitOrder.fromToken == address(WETH)) {
            router.swapETHForExactTokens(
                IMistXRouter.Swap({
                    amount0: limitOrder.amountIn,
                    amount1: limitOrder.amountOut,
                    path: path,
                    to: limitOrder.maker,
                    deadline: _deadline
                }),
                _bribe
            );
        } else if (limitOrder.toToken == address(WETH)) {
            router.swapTokensForExactETH(
                IMistXRouter.Swap({
                    amount0: limitOrder.amountIn,
                    amount1: limitOrder.amountOut,
                    path: path,
                    to: limitOrder.maker,
                    deadline: _deadline
                }),
                _bribe
            );
        } else {
            router.swapExactTokensForTokens(
                IMistXRouter.Swap({
                    amount0: limitOrder.amountIn,
                    amount1: limitOrder.amountOut,
                    path: path,
                    to: limitOrder.maker,
                    deadline: _deadline
                }),
                _bribe
            );
        }
        _payFees(
            limitOrder.fromToken,
            limitOrder.maker,
            msg.sender,
            takerFee,
            houseFee
        );
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function _payFees(
        address _token,
        address _maker,
        address _taker,
        uint256 _takerFee,
        uint256 _houseFee
    ) internal {
        IERC20(_token).safeTransferFrom(_maker, _taker, _takerFee);
        IERC20(_token).safeTransferFrom(_maker, house, _houseFee);
    }

    // @notice Allows house address to change the house address
    function _deleteOrder(bytes32 _orderId, address _maker) internal {
        delete limitOrders[_orderId];
        emit OrderDeleted(_orderId, _maker);
    }

    // @notice Allows owner to change the house address
    function changeHouseAddress(address _newHouse) external onlyOwner {
        house = _newHouse;
    }

    // @notice Allows owner to change the houseRate
    function changeHouseRate(uint256 _newRate) external onlyOwner {
        houseRate = _newRate;
    }

    /* ========== EVENTS ========== */
    event OrderCreated(bytes32 _orderId, LimitOrder _limitOrder);
    event OrderChanged(bytes32 _orderId, LimitOrder _limitOrder);
    event OrderDeleted(bytes32 _orderId, address maker);
    event OrderFulfilled(bytes32 _orderId, address taker);
}
