// SPDX-License-Identifier: MIT
// solhint-disable avoid-low-level-calls
pragma solidity >=0.8.0;

import "BoringSolidity/ERC20.sol";
import "libraries/SafeTransferLib.sol";
import "interfaces/IBentoBoxV1.sol";
import "interfaces/ILevSwapperV2.sol";
import "interfaces/ISolidlyPair.sol";
import "interfaces/ISolidlyRouter.sol";
import "libraries/SolidlyOneSidedVolatile.sol";

/// @notice Generic LP leverage swapper for Solidly Volatile Pool using Matcha/0x aggregator
contract ZeroXSolidlyLikeVolatileLPLevSwapper is ILevSwapperV2 {
    using SafeTransferLib for ERC20;

    error ErrToken0SwapFailed();
    error ErrToken1SwapFailed();

    IBentoBoxV1 public immutable bentoBox;
    ISolidlyPair public immutable pair;
    ISolidlyRouter public immutable router;
    ERC20 public immutable mim;
    ERC20 public immutable token0;
    ERC20 public immutable token1;

    address public immutable zeroXExchangeProxy;

    constructor(
        IBentoBoxV1 _bentoBox,
        ISolidlyRouter _router,
        ISolidlyPair _pair,
        ERC20 _mim,
        address _zeroXExchangeProxy
    ) {
        bentoBox = _bentoBox;
        router = _router;
        pair = _pair;
        mim = _mim;
        zeroXExchangeProxy = _zeroXExchangeProxy;

        ERC20 _token0 = ERC20(_pair.token0());
        ERC20 _token1 = ERC20(_pair.token1());
        token0 = _token0;
        token1 = _token1;

        _token0.safeApprove(address(_router), type(uint256).max);
        _token1.safeApprove(address(_router), type(uint256).max);
        _mim.approve(_zeroXExchangeProxy, type(uint256).max);
    }

    /// @inheritdoc ILevSwapperV2
    function swap(
        address recipient,
        uint256 shareToMin,
        uint256 shareFrom,
        bytes calldata data
    ) external override returns (uint256 extraShare, uint256 shareReturned) {
        // 0: MIM -> token0
        // 1: MIM -> token1
        (bytes[] memory swapData, uint256 minOneSideableAmount0, uint256 minOneSideableAmount1, uint256 fee) = abi.decode(
            data,
            (bytes[], uint256, uint256, uint256)
        );

        bentoBox.withdraw(mim, address(this), address(this), 0, shareFrom);

        {
            // MIM -> token0
            (bool success, ) = zeroXExchangeProxy.call(swapData[0]);
            if (!success) {
                revert ErrToken0SwapFailed();
            }

            // MIM -> token1
            (success, ) = zeroXExchangeProxy.call(swapData[1]);
            if (!success) {
                revert ErrToken1SwapFailed();
            }
        }

        uint256 liquidity;

        {
            SolidlyOneSidedVolatile.AddLiquidityAndOneSideRemainingParams memory params = SolidlyOneSidedVolatile
                .AddLiquidityAndOneSideRemainingParams(
                    router,
                    pair,
                    address(token0),
                    address(token1),
                    pair.reserve0(),
                    pair.reserve1(),
                    token0.balanceOf(address(this)),
                    token1.balanceOf(address(this)),
                    minOneSideableAmount0,
                    minOneSideableAmount1,
                    address(bentoBox),
                    fee
                );

            (, , liquidity) = SolidlyOneSidedVolatile.addLiquidityAndOneSideRemaining(params);
        }

        (, shareReturned) = bentoBox.deposit(ERC20(address(pair)), address(bentoBox), recipient, liquidity, 0);
        extraShare = shareReturned - shareToMin;
    }
}