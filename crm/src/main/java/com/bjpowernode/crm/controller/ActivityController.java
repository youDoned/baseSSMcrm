package com.bjpowernode.crm.controller;

import com.bjpowernode.crm.domain.Activity;
import com.bjpowernode.crm.domain.ActivityRemark;
import com.bjpowernode.crm.domain.User;
import com.bjpowernode.crm.service.ActivityService;
import com.bjpowernode.crm.service.UserService;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.PrintJson;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PaginationVO;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.List;
import java.util.Map;



@RequestMapping("/workbench/activity")
@Controller
public class ActivityController {
    @Resource
    private ActivityService activityService;

    @Resource
    private UserService userService;

    //取用户信息 填充下拉框
    @ResponseBody
    @RequestMapping("/getUserList.do")
    private List<User> getUserList() {
        List<User> userList;
        userList = userService.getUserList();
        return userList;
    }

    //为保存按钮绑定事件，执行添加操作
    @RequestMapping("/save.do")
    private void save(Activity activity, HttpServletRequest request, HttpServletResponse response) {
        activity.setId(UUIDUtil.getUUID());
        //当前时间
        activity.setCreateTime(DateTimeUtil.getSysTime());
        //从session中取用户信息name
        activity.setCreateBy(((User) request.getSession().getAttribute("user")).getName());

        boolean flag = activityService.save(activity);
        PrintJson.printJsonFlag(response, flag);
    }

    //分页查询
    @ResponseBody
    @RequestMapping("/pageList.do")
    private PaginationVO<Activity> pageList(String name,String owner,String startDate,String endDate,Integer pageNo,Integer pageSize){
        int beginIndex = (pageNo-1) * pageSize;
        Map<String,Object> map = new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("beginIndex",beginIndex);
        map.put("pageSize",pageSize);
        //vo用于 多个模块    map用于返回较少的
        PaginationVO<Activity> vo;
        vo = activityService.pageList(map);
        return vo;
    }

    //删除市场活动
    @RequestMapping(value = "/delete.do",method = RequestMethod.POST)
    private void delete(HttpServletRequest request,HttpServletResponse response){
        String[] ids = request.getParameterValues("id");
        boolean flag = activityService.delete(ids);
        PrintJson.printJsonFlag(response,flag);
    }

    //进入到查询用户信息列表和根据市场活动id查询一条记录
    @ResponseBody
    @RequestMapping("/getUserListAndActivity.do")
    private Map<String, Object> getUserListAndActivity(String id){
        Map<String,Object> map = activityService.getUserListAndActivity(id);
        return map;
    }

    @RequestMapping("/update.do")
    private void update(Activity activity,HttpServletRequest request,HttpServletResponse response){
        activity.setEditTime(DateTimeUtil.getSysTime());
        activity.setEditBy(((User) request.getSession().getAttribute("user")).getName());
        boolean flag = activityService.update(activity);
        PrintJson.printJsonFlag(response,flag);
    }

    //跳转详细信息页
    @RequestMapping("/detail.do")
    private ModelAndView detail(String id){
        ModelAndView mv = new ModelAndView();
        Activity activity = activityService.detail(id);
        mv.addObject("activity",activity);
        mv.setViewName("activity/detail");
        return mv;
    }

    //根据市场活动id，取得备注信息列表
    @ResponseBody
    @RequestMapping("/getRemarkListByAid.do")
    private List<ActivityRemark> getRemarkListByAid(String activityId){
        List<ActivityRemark> activityRemarkList = activityService.getRemarkListByAid(activityId);
        return activityRemarkList;
    }

    //删除备注操作
    @RequestMapping("/deleteRemark.do")
    private void deleteRemark(String id,HttpServletResponse response){
        boolean flag = activityService.deleteRemark(id);
        PrintJson.printJsonFlag(response,flag);
    }

    //添加备注
    @ResponseBody
    @RequestMapping("/saveRemark.do")
    private Map<String,Object> saveRemark(String noteContent,String activityId,HttpServletRequest request){
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User) request.getSession().getAttribute("user")).getName();
        String editFlag = "0";
        ActivityRemark ar = new ActivityRemark();
        ar.setActivityId(activityId);
        ar.setNoteContent(noteContent);
        ar.setId(id);
        ar.setCreateTime(createTime);
        ar.setCreateBy(createBy);
        ar.setEditBy(editFlag);
        boolean flag = activityService.saveRemark(ar);
        Map<String,Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("ar",ar);
        return map;
    }

    //修改备注
    @ResponseBody
    @RequestMapping("/updateRemark.do")
    private Map<String,Object> updateRemark(String id,String noteContent,HttpServletResponse response,HttpServletRequest request){
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User) request.getSession().getAttribute("user")).getName();
        String editFlag = "1";
        ActivityRemark ar = new ActivityRemark();
        ar.setId(id);
        ar.setNoteContent(noteContent);
        ar.setEditBy(editBy);
        ar.setEditTime(editTime);
        ar.setEditFlag(editFlag);
        boolean flag = activityService.updateRemark(ar);
        Map<String,Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("ar",ar);
        return map;
    }

}
