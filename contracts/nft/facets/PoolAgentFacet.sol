// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import '@solidstate/contracts/access/OwnableInternal.sol';
import '@solidstate/contracts/utils/AddressUtils.sol';
import '@solidstate/contracts/token/ERC1155/base/ERC1155BaseStorage.sol';

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import '../../shared/lib/LibPausable.sol';
import '../../shared/lib/LibTokenId.sol';
import '../../agent/interfaces/IMortgage.sol';
import '../interfaces/IDeMineNFT.sol';
import '../lib/AppStorage.sol';

contract PoolAgentFacet is
    IPoolAgent,
    OwnableInternal,
    PausableModifier
{
    AppStorage internal s;
    using AddressUtils for address;
    using SafeERC20 for IERC20;

    event Mint(uint128 indexed, uint128, uint128, uint);
    event Shrink(uint128 indexed, uint128, uint128);
    event RegisterPool(uint128 indexed, address indexed);

    function registerPool(address agent, uint128 pool) external onlyOwner {
        // 0 is reserved for non-existence check
        require(agent.isContract() && pool > 0, 'DeMineNFT: invalid input');
        require(
            s.agents[pool] == address(0) && s.pools[agent] == 0,
            'DeMineNFT: pool already registered'
        );
        s.agents[pool] = agent;
        s.pools[agent] = pool;
        emit RegisterPool(pool, agent);
    }

    function mintBatch(
        uint128 pool,
        uint128 start,
        uint128 end,
        uint amount,
        bytes memory data
    ) external onlyOwner {
        address agent = s.agents[pool];
        require(agent != address(0), 'DeMineNFT: invalid pool');
        ERC1155BaseStorage.Layout storage l = ERC1155BaseStorage.layout();
        uint mining = s.mining;
        for (uint cycle = start; cycle <= end; cycle++) {
            require(cycle > mining, 'DeMineNFT: mined cycle');
            uint id = LibTokenId.encode(pool, cycle);
            l.balances[id][msg.sender] += amount;
            s.cycles[cycle].supply += amount;
        }
        IMortgage(agent).mortgage(start, end, supply, data);
        emit Mint(pool, start, end, amount);
    }

    function shrink(uint128 start, uint128 end) external whenNotPaused {
        require(end >= start, 'DeMineNFT: invalid input');
        uint128 pool = s.pools[msg.sender];
        require(pool > 0, 'DeMineNFT: only registered pool agent is allowed');
        ERC1155BaseStorage.Layout storage l = ERC1155BaseStorage.layout();
        unchecked {
            uint mining = s.mining + 1; // plus one in case it's lagging
            for (uint128 cycle = start; cycle <= end; cycle++) {
                require(cycle > mining, 'DeMineNFT: mined cycle');
                uint id = LibTokenId.encode(pool, cycle);
                l.balances[id][msg.sender] = 0;
            }
        }
        emit Shrink(pool, start, end);
    }

    function getAgent(uint128 pool) external view returns(address) {
        return s.agents[pool];
    }

    function getPool(address agent) external view returns(uint128) {
        return s.pools[agent];
    }
}
