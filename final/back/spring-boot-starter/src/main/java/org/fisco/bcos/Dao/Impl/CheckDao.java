package org.fisco.bcos.Dao.Impl;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.fisco.bcos.Contracts.OrderContract;
import org.fisco.bcos.Dao.Interface.ICheckDao;
import org.fisco.bcos.Dao.Interface.IRefundListDao;
import org.fisco.bcos.Variables;
import org.fisco.bcos.constants.GasConstants;
import org.fisco.bcos.web3j.crypto.Credentials;
import org.fisco.bcos.web3j.crypto.gm.GenCredential;
import org.fisco.bcos.web3j.protocol.Web3j;
import org.fisco.bcos.web3j.tuples.generated.Tuple7;
import org.fisco.bcos.web3j.tx.gas.StaticGasProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.math.BigInteger;
import java.util.List;

@Repository
public class CheckDao implements ICheckDao {
    @Autowired
    private Web3j web3j;

    @Autowired
    private Variables variables;

    @Override
    public JSONObject check(String key) throws Exception {
        Credentials credentials = GenCredential.create(key);
        OrderContract orderContract = OrderContract.load(variables.getOrder(), web3j, credentials, new StaticGasProvider(GasConstants.GAS_PRICE, GasConstants.GAS_LIMIT));

        JSONObject send = new JSONObject();
        JSONArray jsonArray = new JSONArray();

        List index = orderContract.userGetOrderIndex().send();
        for (int i = 0; i < index.size(); i++){
            JSONObject jsonObject = new JSONObject();

            BigInteger id = new BigInteger(index.get(i).toString());
            Tuple7<String, String, String, String, String, BigInteger, BigInteger> t = orderContract.getOrderByIndex(id).send();
            jsonObject.put("orderId", t.getValue1());
            jsonObject.put("orderBuyer", t.getValue2());
            jsonObject.put("orderSeller", t.getValue3());
            jsonObject.put("orderTime", t.getValue4());
            jsonObject.put("petId", t.getValue5());
            jsonObject.put("petPrice", t.getValue6());
            jsonObject.put("orderStatus", t.getValue7());
            jsonArray.add(jsonObject);
        }

        send.put("orderList", jsonArray);

        return send;
    }
}
