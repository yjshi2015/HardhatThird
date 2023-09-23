// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "hardhat/console.sol";

/**
 * @title 结构化签名数据：让签名的内容不再是一堆十六进制码
 * @author 
 * @notice 
 * 这只是1个简单的demo，通过HTML生成签名，此时能够看到结构化签名内容，再用签名调用合约对应的接口，
 * 此时依旧是一堆十六进制码，这种方式很蹩脚，并不是预期的那种，但不妨碍它是核心demo。
 * 
 * 更详细的内容参见：https://eips.ethereum.org/EIPS/eip-712
 */
contract EIP712Storage {
    using ECDSA for bytes32;

    bytes32 private constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant SIGDATA_TYPEHASH = keccak256("sigData(address caller,uint256 number,address to,uint256 value)");
    bytes32 private DOMAIN_SEPARATOR;
    uint256 public number;
    address public owner;

    event SignerFromSig(address signer);

    constructor() {
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH, // type hash
            keccak256(bytes("EIP712Storage")), // name
            keccak256(bytes("1")), // version
            block.chainid, // chain id
            address(this) // contract address
        ));
        owner = msg.sender;
        console.log("chainid-->", block.chainid);
    }

    receive() external payable {}

    /**
     * @dev Store value in variable
     * 谁发起的签名，谁拿签名调用
     */
    function permitStore(uint256 _num, address to, uint256 value, bytes memory _signature) public {
        // 检查签名长度，65是标准r,s,v签名的长度
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        // 目前只能用assembly (内联汇编)来从签名中获得r,s,v的值
        assembly {
            /*
            前32 bytes存储签名的长度 (动态数组存储规则)
            add(sig, 32) = sig的指针 + 32
            等效为略过signature的前32 bytes
            mload(p) 载入从内存地址p起始的接下来32 bytes数据
            */
            // 读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
            // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }

        // 获取签名消息hash
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(SIGDATA_TYPEHASH, msg.sender, _num, to, value))
        )); 
        
        address signer = digest.recover(v, r, s); // 恢复签名者
        emit SignerFromSig(signer);
        require(signer == msg.sender, "EIP712Storage: Invalid signature"); // 检查签名

        // todo 模拟向to转账value
        
        // 修改状态变量
        number = _num;
    }  
}