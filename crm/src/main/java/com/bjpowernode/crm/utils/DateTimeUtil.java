package com.bjpowernode.crm.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

//日期工具包
public class DateTimeUtil {
	
	public static String getSysTime(){
		
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		
		Date date = new Date();
		String dateStr = sdf.format(date);
		
		return dateStr;
		
	}
	
}
