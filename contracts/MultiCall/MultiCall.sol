// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title 批量调用，更详细的文档：https://github.com/mds1/multicall/blob/main/src/Multicall3.sol
 * @author 
 * @notice 
 * ①分别给address1和address2铸造mint代币：
 * [["0xd9145CCE52D386f254917e481eB44e9943F39138", false,"0x40c10f19000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb20000000000000000000000000000000000000000000000000000000000000064"],["0xd9145CCE52D386f254917e481eB44e9943F39138",true,"0x40c10f190000000000000000000000004b20993bc481177ec7e8f571cecae8a9e22c02db00000000000000000000000000000000000000000000000000000000000001f4"]]
 *
 * ②分别查询address1和address2的代币余额：
 * [["0xd9145CCE52D386f254917e481eB44e9943F39138",false,"0x70a08231000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb2"],["0xd9145CCE52D386f254917e481eB44e9943F39138",true,"0x70a082310000000000000000000000004b20993bc481177ec7e8f571cecae8a9e22c02db"]]
 */
contract Multicall {
    // Call结构体，包含目标合约target，是否允许调用失败allowFailure，和call data
    struct Call {
        address target;
        bool allowFailure;
        bytes callData;
    }

    // Result结构体，包含调用是否成功和return data
    struct Result {
        bool success;
        bytes returnData;
    }

    /// @notice 将多个调用（支持不同合约/不同方法/不同参数）合并到一次调用
    /// @param calls Call结构体组成的数组
    /// @return returnData Result结构体组成的数组
    function multicall(Call[] calldata calls) public returns (Result[] memory returnData) {
        uint256 length = calls.length;
        returnData = new Result[](length);
        Call calldata calli;
        
        // 在循环中依次调用
        for (uint256 i = 0; i < length; i++) {
            Result memory result = returnData[i];
            calli = calls[i];
            (result.success, result.returnData) = calli.target.call(calli.callData);
            // 如果 calli.allowFailure 和 result.success 均为 false，则 revert
            if (!(calli.allowFailure || result.success)){
                revert("Multicall: call failed");
            }
        }
    }
}