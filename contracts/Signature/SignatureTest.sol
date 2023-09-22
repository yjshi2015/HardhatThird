// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title 解析Signature签名：使用到了内联汇编，_signature变量为memory类型，所以需要按照memory 
 *        layout布局来解析。
 * @author 
 * @notice 
 * memory layout中，前4个32 bytes的slot（即0x00~0x80,共128个字节)为预留空间，实际从128字节后
 * 才为参数的信息，并且参数先以length开头，然后才是value。
 * 故r := mload(add(_signature, 0x20))中，_signature的起止位置为第128个字节，add(_signature,
 * 0x20)=160，即从160字节开始，才是参数的值。
 * 
 * 另：
 * 数组中的元素，即使小于32字节，在内存中也是占据32字节。（节点的内存是256位的，那么大，为什么不用
 * 呢，况且用完就释放了）；
 * 但是对于storage而言，能package的，就会package，毕竟在链上，storage比memory更珍贵。
 * 
 * 参见：https://docs.soliditylang.org/en/stable/internals/layout_in_memory.html
 */
contract SignatureTest {

    event Split(bytes32 r, bytes32 s, uint8 v, uint256 pos);

    address public signer;
    constructor(address _signer) {
        signer = _signer;
    }

    function getMessageHash(string memory str) public pure returns(bytes32){
        return keccak256(abi.encodePacked(str));
    }
    
    //todo syj 生成签名
    function signatureMsg() public view returns(bytes32) {
        //1.利用Remix账户的签名小工具，传参为msgHash，不是ethMsgHash
        //2.在浏览器F12中调用小狐狸钱包，本质上等同于第一种
        //3.python脚本,见./Sig.py
        //4.ethers进行加密，见../scripts/SignatureTest.js
    }

    /**
     * @dev 返回 以太坊签名消息
     * `hash`：消息哈希 
     * 遵从以太坊签名标准：https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * 以及`EIP191`:https://eips.ethereum.org/EIPS/eip-191`
     * 添加"\x19Ethereum Signed Message:\n32"字段，防止签名的是可执行交易。
     */
    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev 通过ECDSA，验证签名地址是否正确，如果正确则返回true
     * _msgHash为消息的hash
     * _signature为签名
     * _signer为签名地址
     */
    function verify(bytes32 _ethMsgHash, bytes memory _signature) public returns (bool) {
        return recoverSigner(_ethMsgHash, _signature) == signer;
    }

    // @dev 从_ethMsgHash和签名_signature中恢复signer地址
    function recoverSigner(bytes32 _ethMsgHash, bytes memory _signature) public returns (address){
        // 检查签名长度，65是标准r,s,v签名的长度
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        uint pos;
        assembly {
            // 读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
            // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
        emit Split(r, s, v, pos);
        // 使用ecrecover(全局函数)：利用 msgHash 和 r,s,v 恢复 signer 地址
        return ecrecover(_ethMsgHash, v, r, s);
    }

    //0x9d76927783219184a68cefd2a19e0c5036790c9f1f583511d9106aedac8866434a80325ba3fa36517b6a50a75333e986e628d65472f1e1f4098f8603dfd75d021c
    event TestSplit(uint a, uint b, uint c, uint d);
    function testAssembly(bytes memory _signature) public {
        uint pos1;
        uint pos2;
        uint pos3;
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            pos1 := add(1, 2) //3
            pos2 := add(1, 0x20) //33
            pos3 := add(_signature, 0x20) //160
            r := mload(add(_signature, 0x20))
            // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
        emit TestSplit(pos1, pos2, pos3, 0);
        emit Split(r, s, v, pos1);
    }

}

