package org.fisco.bcos.Service.Interface;

import com.alibaba.fastjson.JSONObject;

public interface IReturnService {
    public JSONObject returnOrder(String key, int orderId,String reason)throws Exception;
}

