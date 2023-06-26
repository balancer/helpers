// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

interface IVault {
    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (address[] memory tokens, uint256[] memory balances, uint256 lastChangeBlock);
}

interface BasePool {
    function getPoolId() external view returns (bytes32);
    function getRateProviders() external view returns (address[] memory);
    function version() external view returns (string memory);
    function getVirtualSupply() external view returns (uint256);
    function getActualSupply() external view returns (uint256);
    function percentFee() external view returns (uint256);
    function getSwapFeePercentage() external view returns (uint256);
}

interface WeightedPool {
    function getNormalizedWeights() external view returns (uint256[] memory);
}

interface ILinearPool {
    function getMainToken() external view returns (address);
    function getWrappedToken() external view returns (address);
}

enum TotalSupplyType { TOTAL_SUPPLY, VIRTUAL_SUPPLY, ACTUAL_SUPPLY }
enum SwapFeeType { SWAP_FEE_PERCENTAGE, PERCENT_FEE }

interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
}

interface IRateProvider {
    function getRate() external view returns (uint256);
}

contract BalancerViewHelpers {
    struct PoolToken {
        bytes32 parentId;
        bytes32 poolId;
        string version;
        address addr;
        uint256 balance;
        uint256 decimals;
        uint256 weight;
        uint256 priceRate;
        uint256 totalSupply;
        uint256 swapFee;
        address mainToken;
    }

    IVault vault;

    constructor(address _vault) {
        vault = IVault(_vault);
    }

    // Returns a list of nested pool tokens upto 6 levels deep
    function poolTokens(bytes32 poolId) public view returns (PoolToken[] memory pooltokens) {
        (address[] memory tokens, uint256[] memory balances,) = vault.getPoolTokens(poolId);

        // Try to fetch the pool token weights
        uint256[] memory weights = new uint256[](tokens.length);
        try WeightedPool(_getPoolAddress(poolId)).getNormalizedWeights() returns (uint256[] memory _weights) {
            weights = _weights;
        } catch {
            // Fill with 0s if the pool is not weighted
            // for (uint8 i = 0; i < tokens.length; i++) {
            //     weights[i] = 0;
            // }
        }

        uint8 j = 0;
        // 12 tokens per pool, 6 levels of nesting
        PoolToken[] memory allTokens = new PoolToken[](12*6);

        for (uint8 i = 0; i < tokens.length; i++) {
            uint256[4] memory tokenProps;
            tokenProps[0] = IERC20(tokens[i]).decimals();
            tokenProps[1] = 0; // Actual supply of the BPT token
            tokenProps[2] = 0; // Swap fee of the pool
            tokenProps[3] = weights[i]; // Token weight
            bytes32 nestedId = bytes32(0);
            string memory version;
            address mainToken = address(0);

            uint256 priceRate = 1;
            try IRateProvider(tokens[i]).getRate() returns (uint256 rate) {
                priceRate = rate;
            } catch {
                // Safe to ignore, because we don't need to get priceRate for non-rate providers
            }

            // If it's a pool token, get it's nested tokens
            try BasePool(tokens[i]).getPoolId() returns (bytes32 id) {
                nestedId = id;
                version = BasePool(tokens[i]).version();

                try ILinearPool(tokens[i]).getMainToken() returns (address _mainToken) {
                    mainToken = _mainToken;
                } catch {
                    // Safe to ignore, because we don't need to get wrapped tokens for non-linear pools
                }

                try BasePool(tokens[i]).getVirtualSupply() returns (uint256 virtualSupply) {
                    tokenProps[1] = virtualSupply;
                } catch {
                    try BasePool(tokens[i]).getActualSupply() returns (uint256 actualSupply) {
                        tokenProps[1] = actualSupply;
                    } catch {
                        try IERC20(tokens[i]).totalSupply() returns (uint256 totalSupply) {
                            tokenProps[1] = totalSupply;
                        } catch {
                            // Safe to ignore, because we don't need to get wrapped tokens for non-linear pools
                        }
                    }
                }

                try BasePool(tokens[i]).getSwapFeePercentage() returns (uint256 swapFee) {
                    tokenProps[2] = swapFee;
                } catch {
                    try BasePool(tokens[i]).percentFee() returns (uint256 swapFee) {
                        tokenProps[2] = swapFee;
                    } catch {
                        // Ignoring
                    }
                }

                // Get nested tokens only when the token is another pool
                // Don't get them for BPT, because it will cause a stack overflow
                if (poolId != nestedId) {
                    pooltokens = poolTokens(nestedId);
                    for (uint8 k = 0; k < pooltokens.length; k++) {
                        allTokens[j] = pooltokens[k];
                        j++;
                    }
                }
            } catch {
                // Safe to ignore, becase we don't need to get nested tokens for non-pool tokens
            }

            allTokens[j] = PoolToken(poolId, nestedId, version, tokens[i], balances[i], tokenProps[0], tokenProps[3], priceRate, tokenProps[1], tokenProps[2], mainToken);
            j++;
        }

        // Copy the array to the correct size
        pooltokens = new PoolToken[](j);
        for (uint8 i = 0; i < j; i++) {
            pooltokens[i] = allTokens[i];
        }
    }

    function _getPoolAddress(bytes32 poolId) internal pure returns (address) {
        return address(bytes20(poolId));
    }
}
