// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IMistXRouter {
    struct Swap {
        uint256 amount0;
        uint256 amount1;
        address[] path;
        address to;
        uint256 deadline;
    }

    function swapExactETHForTokens(Swap calldata _swap, uint256 _bribe)
        external
        payable;

    function swapETHForExactTokens(Swap calldata _swap, uint256 _bribe)
        external
        payable;

    function swapExactTokensForTokens(Swap calldata _swap, uint256 _bribe)
        external
        payable;

    function swapTokensForExactTokens(Swap calldata _swap, uint256 _bribe)
        external
        payable;

    function swapTokensForExactETH(Swap calldata _swap, uint256 _bribe)
        external
        payable;

    function swapExactTokensForETH(Swap calldata _swap, uint256 _bribe)
        external
        payable;

    function deposit(uint256 value) external payable;
}
