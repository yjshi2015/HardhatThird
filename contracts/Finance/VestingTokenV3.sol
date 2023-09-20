// SPDX-License-Identifier: MIT
// wtf.academy
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title ERC20代币线性释放
 * @dev 这个合约会将ERC20代币线性释放给给受益人`_beneficiary`。
 * 释放的代币可以是一种，也可以是多种。释放周期由起始时间`_start`和时长`_duration`定义。
 * 所有转到这个合约上的代币都会遵循同样的线性释放周期，并且需要受益人调用`release()`函数提取。
 * 合约是从OpenZeppelin的VestingWallet简化而来。
 * 
 * 升级内容：
 * 支持多个受益人线性提取属于自己的Token
 * 
 * 关键点：
 * 1、合约初始化时即指定受益人列表，以及每个受益人的待领取Token总额
 * 2、启动时要求项目方必须向该合约注入约定数量的Token，否则启动失败
 */
contract TokenVesting {
    // 事件
    event ERC20Released(address indexed token, uint256 amount); // 提币事件
    //项目启动，受益人可以按照约定领取Token，amount即项目方注入的总资金
    event VestingBegin(uint amount);

    struct BeneficiaryParam {
        address addr; //受益人地址
        uint erc20Pending;   //分配给该受益人的Token总量
        uint start;//归属期起始时间
        uint duration; //归属期
    }

    struct Beneficiary {
        uint erc20Pending;   //分配给该受益人的Token总量
        uint erc20Released;//已领取的Token数量
        uint start;//归属期起始时间
        uint duration; //归属期
    }
    
    mapping(address => Beneficiary) public beneficiaryMap;
    address[] public beneficiaryAddr;
    IERC20 erc20;
    bool begin;//项目是否启动

    /**
     * @dev 初始化受益人地址，释放周期(秒), 起始时间戳(当前区块链时间戳)
     */
    constructor(
        BeneficiaryParam[] _beneficiaryParam,
        address _erc20
    ) {
        require(_beneficiaryParam.length > 0, "invalid param: _beneficiaryParam");
        erc20 = IERC20(_erc20);
        for (uint i; i < _beneficiaryParam.length; i++) {
            Beneficiary beneficiary = Beneficiary({
                erc20Pending : _beneficiaryParam[i].erc20Pending,
                erc20Released : 0,
                start : _beneficiaryParam[i].start,
                duration : _beneficiaryParam[i].duration
            });
            beneficiaryMap[_beneficiaryParam[i].addr] = beneficiary;
            beneficiaryAddr[i] = _beneficiaryParam[i].addr
        }
    }

    //启动该项目
    function vestingBegin() external returns(bool) {
        require(!begin, "already begin");
        uint total;
        for(uint i; i < beneficiaryAddr.length; i++) {
            address thisAddr = beneficiaryAddr[i];
            Beneficiary beneficiary = beneficiaryMap[thisAddr];
            total += (beneficiary.erc20Pending + beneficiary.erc20Released);
        }
        require(erc20.balanceOf(address(this)) >= total, "VestingBegin failed: insufficient token");
        begin = true;
        emit VestingBegin(total);
    }

    modifier started {
        require(begin, "vesting not begin");
        _;        
    }

    /**
     * @dev 受益人提取已释放的代币。
     * 调用vestedAmount()函数计算可提取的代币数量，然后transfer给受益人。
     * 释放 {ERC20Released} 事件.
     */
    function release() public started{
        Beneficiary beneficiary = beneficiaryMap[msg.sender];
        //必须是受益人领取收益
        require(beneficiary.duration > 0, "you can not release!");

        // 调用vestedAmount()函数计算可提取的代币数量
        uint256 releasable = vestedAmount(beneficiary);
        require(releasable > 0, "you have released all tokens");
        // 更新已释放代币数量   
        beneficiary.erc20Released += releasable;
        beneficiary.erc20Pending -= releasable;

        // 转代币给受益人
        emit ERC20Released(msg.sender, releasable);
        IERC20(token).transfer(msg.sender, releasable);
    }

    /**
     * @dev 根据线性释放公式，计算已经释放的数量。开发者可以通过修改这个函数，自定义释放方式。
     * @param token: 代币地址
     * @param timestamp: 查询的时间戳
     */
    function vestedAmount(Beneficiary calldata beneficiary) public view returns (uint256 releasable) {
        uint timestamp = uint256(block.timestamp);
        // 合约里总共收到了多少代币（当前余额 + 已经提取）
        uint totalAllocation = beneficiary.erc20Pending + beneficiary.erc20Released;
        uint start = beneficiary.start;
        uint duration = beneficiary.duration;
        uint erc20Released = beneficiary.erc20Released;
        uint releasable;
        // 根据线性释放公式，计算已经释放的数量
        if (timestamp < start) {
            releasable = 0;
        } else if (timestamp > start + duration) {
            releasable = beneficiary.erc20Pending;
        } else {
            releasable = (totalAllocation * (timestamp - start)) / duration - erc20Released;
        }
    }
}