pragma solidity ^0.4.26;  //�������İ汾
contract LAGCredit {

      //�������������������ô洢����������
      string name = "LAGC";
      string symbol = "LAG";
      uint256 totalSupply;
      
      //��ַ������ӳ�䣬�����ڲ鿴��Ӧ�˻���ַ��Ļ������
      mapping(address=>uint256) public balances;
    
      //������֪ͨǰ�η����˻��ֵĸı�
      event transferEvent(address from, address to, uint256 value);
      
      //��Լ�Ĺ��캯���������Լ��ʱ��Ӧ�ô�����������
      constructor(uint256 initialSupply, string creditName, string creditSymbol) public{
          totalSupply = initialSupply;
          name = creditName;
          symbol = creditSymbol;
          //ͬʱ���̵�Ļ�������޸ĳ�totalSupply
          balances[msg.sender] = totalSupply;
      }
      
      //���ڲ鿴�ܵĻ��ַ�����
      function getTotalSupply() constant returns(uint256){
          return totalSupply;
      }
      
      //���ڻ���ת�ˣ�internal˵��ֻ���ɺ�Լ�ڵĺ�������
      function _transfer(address _from, address _to, uint _value) internal{
          //�տ��ַ����Ϊ0x0��require������֤��������
          require( _to != 0x0 );
          //����ת�������˻����Ļ�����
          require( balances[_from] >= _value );
          //����ת�����Ļ��ֳ�ȥ
          require(balances[_to] + _value > balances[ _to ]);
          
          uint previousBalances = balances[_from]+balances[_to];
          
          balances[_from] -= _value;
          balances[_to] += _value;
          
          transferEvent(_from,_to,_value);
          assert(balances[_from] + balances[_to] == previousBalances);

      }
      
      //�ɼ���Ϊpublic��˵�����Ա��ⲿ���ã�ͨ���˺������һ�η����ߵ�Ŀ�ĵ�ַ�Ļ��ֽ���
      function transfer(address _to, uint256 _value)public{
          _transfer(msg.sender, _to, _value);
      }
      
      //�鿴�˻����
      function balanceOf(address _owner) constant returns(uint256){
          return balances[_owner];
      }
}