package com.bjpowernode.crm.utils;

import java.util.UUID;

//UUID 随机id工具包
public class UUIDUtil {
	
	public static String getUUID(){
		
		return UUID.randomUUID().toString().replaceAll("-","");
		
	}
	
}
