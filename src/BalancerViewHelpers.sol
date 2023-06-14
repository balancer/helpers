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
}

interface IERC20 {
    function decimals() external view returns (uint8);
}

interface IRateProvider {
    function getRate() external view returns (uint256);
}

contract BalancerViewHelpers {
    struct PoolToken {
        bytes32 parentId;
        bytes32 poolId;
        address token;
        uint256 balance;
        uint8 decimals;
        uint256 priceRate;
    }

    IVault vault;

    constructor(address _vault) {
        vault = IVault(_vault);
    }

    // Returns a list of nested pool tokens upto 6 levels deep
    function poolTokens(bytes32 poolId) public view returns (PoolToken[] memory pooltokens) {
        (address[] memory tokens, uint256[] memory balances,) = vault.getPoolTokens(poolId);

        uint8 j = 0;
        // 12 tokens per pool, 6 levels of nesting
        PoolToken[] memory allTokens = new PoolToken[](12*6);

        for (uint8 i = 0; i < tokens.length; i++) {
            uint8 decimals = IERC20(tokens[i]).decimals();
            bytes32 nestedId = bytes32(0);

            uint256 priceRate = 1;
            try IRateProvider(tokens[i]).getRate() returns (uint256 rate) {
                priceRate = rate;
            } catch {
                // Safe to ignore, because we don't need to get priceRate for non-rate providers
            }

            // If it's a pool token, get it's nested tokens
            try BasePool(tokens[i]).getPoolId() returns (bytes32 id) {
                nestedId = id;

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

            allTokens[j] = PoolToken(poolId, nestedId, tokens[i], balances[i], decimals, priceRate);
            j++;
        }

        // Copy the array to the correct size
        pooltokens = new PoolToken[](j);
        for (uint8 i = 0; i < j; i++) {
            pooltokens[i] = allTokens[i];
        }
    }
}
