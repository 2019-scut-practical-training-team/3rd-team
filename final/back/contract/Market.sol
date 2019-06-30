pragma solidity ^0.4.25;
import "./DataProcess.sol";
import "./OrderContract.sol";

contract Market is DataProcess{

    struct Pet {
        string petName;
        string petId;
        string petType;
        uint16 petPrice;
        uint8 petStatus;
        string petImg;
        string petIntro;
        address Owner;
    }
    //ȫ�ֱ�������������Ա��ַ��order��Լ��ַ�����۳�������б�
    address private adminAddress;
    address orderAddress;
    OrderContract OD = OrderContract(orderAddress);
    uint petIdNum=1;
    Pet[] private petOnSell;



    //���캯��,���ú�Լ������Ϊ����Ա������Ա���Ϊ2
    constructor() public {
        adminAddress = msg.sender;
        userIden[adminAddress] = 2;
    }

    //���η����ж�����ǲ��ǹ���Ա
    modifier isAdmin(address _caller) {
        require (_caller == adminAddress);
        _;
    }

    //ӳ�䣺
    //�ж��Ƿ��Ѵ���������
    mapping (address => uint8) createdPet;
    //��ַ�����ӳ��
    mapping (address => uint) Balance;
    //�ж��Ƿ����û�
    mapping (address => uint8) oldUser;
    //�û���ַ�������б��ӳ��
    mapping (address => Pet[]) addressToPetList;
    //����id���û���ַ��ӳ��
    mapping (string => address) petIdToOwner;
    //�û���ַ����ݵ�ӳ��
    mapping(address => uint8) userIden;


    //����order��Լ��ַ�����ڵ������еĺ���
    function setOrderAddress(address _orderAddress) public isAdmin(msg.sender) {
        orderAddress = _orderAddress;
    }

    //�ڲ����ú�����
    //��ʼ���û�����Լ��Ƿ񴴽����������
    function initUser() private {
        createdPet[msg.sender] = 0;
        Balance[msg.sender] = 10000;
    }
    //Ϊ�û�����һ�������б�
    function setAddressToPetList() private {
        Pet[] storage tempPetList;
        addressToPetList[msg.sender] = tempPetList;
    }
    //���ó�������
    function setPetOwner(string _id,address _owner) private {
        petIdToOwner[_id] = _owner;
    }

    //֧����Ӧ���ڲ�����
    function pay(address _from, address _to, uint16 _price) private {
        require(_to != 0x0);
        require(Balance[_from] >= _price);
        require(Balance[_to] + _price > Balance[_to]); //_value����Ϊ��ֵ
        uint previousBalances = Balance[_from] + Balance[_to];
        Balance[_from] -= _price;
        Balance[_to] += _price;
        assert(Balance[_from] + Balance[_to] == previousBalances);
    }
    //����Աʹ�õ�ת�˺����������˻�����Ĳ���
    function payByAdmin(address _from,address _to, uint16 _price, address _caller) public isAdmin(_caller){
        require(_to != 0x0);
        require(Balance[_from] >= _price);
        require(Balance[_to] + _price > Balance[_to]); //_value����Ϊ��ֵ
        uint previousBalances = Balance[_from] + Balance[_to];
        Balance[_from] -= _price;
        Balance[_to] += _price;
        assert(Balance[_from] + Balance[_to] == previousBalances);
    }
    //ת����������Ȩ�����ڹ��������˻�ʱʹ��
    function changePetOwner(address _from, address _to, string _petId, address _caller) public isAdmin(_caller) {
        require(_from != 0x0);
        require(petIdToOwner[_petId] == _from);
        setPetOwner(_petId, _to);
        uint petIndex;
        //����������ҵĳ����б�ɾ����������ҵĳ����б�
        for(uint i = 0;i < addressToPetList[_from].length;i++){
            if(keccak256(abi.encodePacked(_petId)) == keccak256(abi.encodePacked(addressToPetList[_from][i].petId))){
                addressToPetList[_to].push(addressToPetList[_from][i]);
                delete addressToPetList[_from][i];
                petIndex = i;
            }
        }
        //�ֶ������ҵĳ����б���λ�������б��ȼ�һ
        for(i = petIndex;i < addressToPetList[_from].length; i++){
            addressToPetList[_from][i] = addressToPetList[_from][i+1];
        }
        delete addressToPetList[_from][addressToPetList[_from].length-1];
        addressToPetList[_from].length--;
    }




    //�û���أ�
    //�����û���������ʼ�������Ƿ񴴽����������
    function createUser() public {
        require(oldUser[msg.sender] == 0);
        require(msg.sender != adminAddress);
        initUser();
        oldUser[msg.sender] = 1;
        userIden[msg.sender] = 1;
    }
    //��ȡ�û����
    function getUserIden() public view returns (uint8){
        return userIden[msg.sender];
    }
    //��ȡ�����ߵ����
    function getBalanceOfMe() public view returns (uint) {
        return Balance[msg.sender];
    }
    //ͨ����ַ��ȡ���
    function getBalace(address _address) public view returns (uint) {
        return Balance[_address];
    }




    //������أ�
    //�����û���Ӧ�ĳ����б�
    function getPetListFromAddress() public view returns (string) {
        string memory result;
        for(uint i=0;i<addressToPetList[msg.sender].length;i++){
            result = strConcat(result,addressToPetList[msg.sender][i].petName);
            result = strConcat(result,",");
            result = strConcat(result,addressToPetList[msg.sender][i].petId);
            result = strConcat(result,",");
            result = strConcat(result,addressToPetList[msg.sender][i].petType);
            result = strConcat(result,",");
            result = strConcat(result,DataProcess.getIntToString(addressToPetList[msg.sender][i].petPrice));
            result = strConcat(result,",");
            result = strConcat(result,DataProcess.getIntToString(addressToPetList[msg.sender][i].petStatus));
            result = strConcat(result,",");
            result = strConcat(result,addressToPetList[msg.sender][i].petImg);
            result = strConcat(result,",");
            result = strConcat(result,addressToPetList[msg.sender][i].petIntro);
            result = strConcat(result,",");
        }
        return result;
    }
    //չʾ�������۳���
    function showPetOnSell() public view returns(string){
        string memory result;
        for(uint i=0;i<petOnSell.length;i++){
            result = strConcat(result,petOnSell[i].petName);
            result = strConcat(result,",");
            result = strConcat(result,petOnSell[i].petId);
            result = strConcat(result,",");
            result = strConcat(result,petOnSell[i].petType);
            result = strConcat(result,",");
            result = strConcat(result,DataProcess.getIntToString(petOnSell[i].petPrice));
            result = strConcat(result,",");
            result = strConcat(result,DataProcess.getIntToString(petOnSell[i].petStatus));
            result = strConcat(result,",");
            result = strConcat(result,petOnSell[i].petImg);
            result = strConcat(result,",");
            result = strConcat(result,petOnSell[i].petIntro);
            result = strConcat(result,",");
        }
        return result;
    }

    //���������û�д��������ȴ��������б��ٴ�������
    function createPet(string _name,  string _type, uint16 _price, string _img, string _intro) public {
        //�ж��Ƿ��Ѵ���������
        if(createdPet[msg.sender] == 0){
            setAddressToPetList();
            createdPet[msg.sender] = 1;
        }
        //���ﴴ����һ���µĳ���������û���Ӧ�ĳ����б�
        addressToPetList[msg.sender].push(Pet(_name, getIntToString(petIdNum), _type, _price, 0, _img, _intro, msg.sender));
        setPetOwner(getIntToString(petIdNum),msg.sender);
    }
    //�������
    function buyPet(string _petId, uint16 _price, string _time, address _seller) public {
        pay(msg.sender, _seller, _price);
        changePetOwner(_seller, msg.sender, _petId, adminAddress);
        OD.createOrder( _seller, _time, _petId, _price, adminAddress);
    }

    //���۳���
    function sellPet(string _petId) public {
        require(petIdToOwner[_petId] == msg.sender);
        Pet storage tempPet;
        for(uint i=0;i<addressToPetList[msg.sender].length;i++){
            if(keccak256(abi.encodePacked(_petId)) == keccak256(abi.encodePacked(addressToPetList[msg.sender][i].petId))){
                addressToPetList[msg.sender][i].petStatus=1;
                tempPet = addressToPetList[msg.sender][i];
            }
        }
        petOnSell.push(tempPet);
    }
    //ȡ�����۳���
    function cancelSellPet(string _petId) public {
        require(petIdToOwner[_petId] == msg.sender);
        uint index;
        for(uint i=0;i<addressToPetList[msg.sender].length;i++){
            if(keccak256(abi.encodePacked(_petId)) == keccak256(abi.encodePacked(addressToPetList[msg.sender][i].petId))){
                addressToPetList[msg.sender][i].petStatus=0;
            }
        }
        for(i=0;i<petOnSell.length;i++){
            if(keccak256(abi.encodePacked(_petId)) == keccak256(abi.encodePacked(petOnSell[i].petId))){
                delete petOnSell[i];
                index = i;
                break;
            }
        }
        for(i=index;i<petOnSell.length-1;i++){
            petOnSell[i] = petOnSell[i+1];
        }
        delete petOnSell[petOnSell.length-1];
        petOnSell.length--;
    }
    //�޸ĳ�����Ϣ
    function changePetInfo(string _name, string _id, string _type, uint16 _price, string _img, string _intro) public view {
        require(petIdToOwner[_id] == msg.sender);
        for(uint i=0;i<addressToPetList[msg.sender].length;i++){
            if(keccak256(abi.encodePacked(addressToPetList[msg.sender][i].petId)) == keccak256(abi.encodePacked(_id))){
                _name = addressToPetList[msg.sender][i].petName;
                _type = addressToPetList[msg.sender][i].petType;
                _price = addressToPetList[msg.sender][i].petPrice;
                _img = addressToPetList[msg.sender][i].petImg;
                _intro = addressToPetList[msg.sender][i].petIntro;
                break;
            }
        }
    }
    
}
