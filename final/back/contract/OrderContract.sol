pragma solidity ^0.4.25;
import "./DataProcess.sol";
import "./Market.sol";

contract OrderContract is DataProcess{
    //�����ṹ��
    struct Order {
        string orderId;
        address orderBuyer;
        address orderSeller;
        string orderTime;
        string petId;
        uint16 petPrice;
        uint8 orderStatus;
        string returnResult;
    }
    //����������market��Լ��ַ������Ա��ַ�������б�����id
    address marketAddress;
    Market MK = Market(marketAddress);
    address private adminAddress;
    Order[] public orderList;
    uint orderIdNum=1;

    //���캯�� ����Ա��ַ
    constructor() public {
        adminAddress = msg.sender;
    }
    //���η�������Ƿ����Ա
    modifier isAdmin(address _caller) {
        require (_caller == adminAddress);
        _;
    }
    //����market��Լ��ַ
    function setMarketAddress(address _mkAddress) public isAdmin(msg.sender){
        marketAddress = _mkAddress;
    }


    //����һ���¶�����market����
    function createOrder(address _seller, string _time, string _petId, uint16 _petPrice, address _caller) public isAdmin(_caller) {
        orderList.push(Order(getIntToString(orderIdNum), _caller, _seller, _time, _petId, _petPrice, 0, ""));
        orderIdNum++;
    }


    //������أ�
    //����Ա���֣�
    //�������ж���������Ա�鿴
    function adminGetOrderList() public isAdmin(msg.sender) returns (string, address[], address[]) {
        string memory result;
        address[] storage buyerAddress;
        address[] storage sellerAddress;
        for(uint i=0;i<orderList.length;i++){
            result = strConcat(result,orderList[i].orderId);
            result = strConcat(result,",");
            result = strConcat(result,orderList[i].orderTime);
            result = strConcat(result,",");
            result = strConcat(result,orderList[i].petId);
            result = strConcat(result,",");
            result = strConcat(result,DataProcess.getIntToString(uint(orderList[i].petPrice)));
            result = strConcat(result,",");
            result = strConcat(result,DataProcess.getIntToString(uint(orderList[i].orderStatus)));
            result = strConcat(result,",");
            result = strConcat(result,orderList[i].returnResult);
            result = strConcat(result,",");

            buyerAddress.push(orderList[i].orderBuyer);
            sellerAddress.push(orderList[i].orderSeller);
        }
        return (result, buyerAddress, sellerAddress);
    }
    //����Ա��������ٲõĶ���
    function adminGetReturnOrderList() public isAdmin(msg.sender) returns (string, address[], address[]) {
        string memory result;
        address[] storage buyerAddress;
        address[] storage sellerAddress;
        for(uint i = 0;i < orderList.length;i++){
            if(orderList[i].orderStatus == 1){
                result = strConcat(result,orderList[i].orderId);
                result = strConcat(result,",");
                result = strConcat(result,orderList[i].orderTime);
                result = strConcat(result,",");
                result = strConcat(result,orderList[i].petId);
                result = strConcat(result,",");
                result = strConcat(result,getIntToString(uint(orderList[i].petPrice)));
                result = strConcat(result,",");
                result = strConcat(result,getIntToString(uint(orderList[i].orderStatus)));
                result = strConcat(result,",");
                result = strConcat(result,orderList[i].returnResult);
                result = strConcat(result,",");

                buyerAddress.push(orderList[i].orderBuyer);
                sellerAddress.push(orderList[i].orderSeller);
            }
        }
        return (result, buyerAddress, sellerAddress);
    }
    //����Ա�����˻�����
    function acceptReturn(string _orderId) public isAdmin(msg.sender) {
        uint index;
        for(uint i=0;i<orderList.length;i++) {
            if(keccak256(abi.encodePacked(_orderId)) == keccak256(abi.encodePacked(orderList[i].orderId))){
                index = i;
                break;
            }
        }
        orderList[index].orderStatus = 2;
        MK.changePetOwner(orderList[index].orderBuyer, orderList[index].orderSeller, orderList[index].petId, msg.sender);
        MK.payByAdmin(orderList[index].orderBuyer,orderList[index].orderSeller,orderList[index].petPrice, msg.sender);
    }
    //����Ա�ܾ��˻�����
    function rejectReturn(string _orderId) public isAdmin(msg.sender) {
        uint index;
        for(uint i=0;i<orderList.length;i++) {
            if(keccak256(abi.encodePacked(_orderId)) == keccak256(abi.encodePacked(orderList[i].orderId))){
                index = i;
                break;
            }
        }
        orderList[index].orderStatus = 3;
    }


    //�û����֣�
    //�û�����Լ��Ķ����б�
    function userGetOrderList() public view returns (string, address[], address[]) {
        string memory result;
        address[] storage buyerAddress;
        address[] storage sellerAddress;
        for(uint i = 0;i < orderList.length;i++){
            if(orderList[i].orderBuyer == msg.sender || orderList[i].orderSeller == msg.sender){
                result = strConcat(result,orderList[i].orderId);
                result = strConcat(result,",");
                result = strConcat(result,orderList[i].orderTime);
                result = strConcat(result,",");
                result = strConcat(result,orderList[i].petId);
                result = strConcat(result,",");
                result = strConcat(result,getIntToString(uint(orderList[i].petPrice)));
                result = strConcat(result,",");
                result = strConcat(result,getIntToString(uint(orderList[i].orderStatus)));
                result = strConcat(result,",");
                result = strConcat(result,orderList[i].returnResult);
                result = strConcat(result,",");

                buyerAddress.push(orderList[i].orderBuyer);
                sellerAddress.push(orderList[i].orderSeller);
            }
        }
        return (result, buyerAddress, sellerAddress);
    }
    //�����˻�
    function applyForReturn(string _orderId) public {
        uint index;
        for(uint i=0;i<orderList.length;i++) {
            if(keccak256(abi.encodePacked(_orderId)) == keccak256(abi.encodePacked(orderList[i].orderId))){
                index = i;
                break;
            }
        }
        //�ж�������Ϊ���Ҷ���״̬Ϊ���˻�
        require(orderList[index].orderBuyer == msg.sender && orderList[index].orderStatus == 0);
        orderList[index].orderStatus = 1;
    }
}