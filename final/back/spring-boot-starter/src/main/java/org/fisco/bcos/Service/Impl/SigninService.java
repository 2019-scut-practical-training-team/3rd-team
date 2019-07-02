package org.fisco.bcos.Service.Impl;

import com.alibaba.fastjson.JSONObject;
import org.fisco.bcos.Contracts.Market;
import org.fisco.bcos.Service.Interface.ISigninService;
import org.fisco.bcos.constants.GasConstants;
import org.fisco.bcos.web3j.crypto.Credentials;
import org.fisco.bcos.web3j.crypto.EncryptType;
import org.fisco.bcos.web3j.crypto.gm.GenCredential;
import org.fisco.bcos.web3j.protocol.Web3j;
import org.fisco.bcos.web3j.tx.gas.StaticGasProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigInteger;


@Service(value = "siService")
public class SigninService implements ISigninService {

    @Autowired
    private Web3j web3j;

    @Override
    public JSONObject signin(String key) throws Exception{

        EncryptType.encryptType = 0;
        Credentials credentials = GenCredential.create(key);

        String contract = "0xa7f3026b5b9274c7b96ba0c5bbbf3db866b2f3ed";

        Market market = Market.load(
                contract,
                web3j,
                credentials,
                new StaticGasProvider(
                        GasConstants.GAS_PRICE, GasConstants.GAS_LIMIT));


        int identity = market.getUserIden().send().intValue();

        JSONObject json = new JSONObject();
        json.put("identity",identity);
        return json;
    }
}