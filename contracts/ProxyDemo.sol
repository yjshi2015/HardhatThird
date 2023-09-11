contract OwnedUpgradeabilityProxy is Proxy { 
    bytes32 private constant ownerPosition = keccak256("org.zeppelinos.proxy.owner"); 
    bytes32 private constant implementationPosition = keccak256("org.zeppelinos.proxy.implementation"); 
    function upgradeTo(address newImplementation) public onlyProxyOwner {   
        address currentImplementation = implementation();   
        setImplementation(newImplementation); 
    } 
    function implementation() public view returns(address impl) {   
        bytes32 position = implementationPosition;   
        assembly {
            impl: = sload(position)
        } 
    } 
    function setImplementation(address newImplementation) internal {   
        bytes32 position = implementationPosition;   
        assembly {
            sstore(position, newImplementation)
        } 
    } 
    function proxyOwner() public view returns(address owner) {   
        bytes32 position = proxyOwnerPosition;   
        assembly {
            owner: = sload(position)
        } 
    } 
    function setUpgradeabilityOwner(address newProxyOwner) internal {   
        bytes32 position = proxyOwnerPosition;   
        assembly {
            sstore(position, newProxyOwner)
        } 
    }
}