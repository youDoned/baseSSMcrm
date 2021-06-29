package com.bjpowernode.crm.web.listener;

import com.bjpowernode.crm.domain.DicValue;
import com.bjpowernode.crm.service.DicService;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextRefreshedEvent;

import javax.servlet.ServletContext;
import java.util.*;

//监听上下文域创建的时机 导入数据字典
public class SysInitListener implements ApplicationListener<ContextRefreshedEvent> {


    private DicService dicService;

    private ServletContext application;

    public void setDicService(DicService dicService) {
        this.dicService = dicService;
    }

    public void setApplication(ServletContext application) {
        this.application = application;
    }

    @Override
    public void onApplicationEvent(ContextRefreshedEvent event) {

        System.out.println("服务器缓存处理数据字典开始");

        //管业务层要7个List，打包成为Map
        //以数据字典中的类型为key   
        Map<String, List<DicValue>> listMap = dicService.getAll();

        Set<String> set = listMap.keySet();
        for (String key : set){
            System.out.println(key);
            application.setAttribute(key,listMap.get(key));
        }

        System.out.println("服务器缓存处理数据字典结束");

        //----数据字典处理完毕后，需要解析Stage2Possibility.properties文件---
        Map<String,String> pMap = new HashMap<>();
        ResourceBundle resourceBundle = ResourceBundle.getBundle("Stage2Possibility");
        Enumeration<String> keys = resourceBundle.getKeys();
        while (keys.hasMoreElements()){
            String key = keys.nextElement();

            String value = resourceBundle.getString(key);

            pMap.put(key,value);
        }

        //将pMap保存到服务器缓存中
        application.setAttribute("pMap",pMap);

    }
}
