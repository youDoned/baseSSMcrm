<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
<meta charset="UTF-8">
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

	<script type="text/javascript">

	$(function(){

		//为创建按钮绑定事件打开添加操作的模态窗口
		$("#addBtn").click(function (){

			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});

			//走后台，目的是为了取得用户信息列表，为所有者下拉框铺值
			$.ajax({
				url : "workbench/activity/getUserList.do",
				type : "get",
				dataType : "json",
				success : function (data){
					var html = "<option></option>";
					$.each(data,function (index,element){
						html += "<option value='"+ element.id +"'>"+ element.name+ "</option>";
					})

					$("#create-owner").html(html);

					//将当前登录的用户，设置为下拉框默认的选项
					//取得当前登录用户的id，在js中使用el表达式，el表达式一定要套用在字符串中
					var id = "${user.id}";

					$("#create-owner").val(id)

					//所有者下拉框处理完毕后，展现模态窗口
					$("#createActivityModal").modal("show");

				}
			})
		})
		
		//为保存按钮绑定事件，执行添加操作
		$("#saveBtn").click(function (){
			$.ajax({
				url : "workbench/activity/save.do",
				data : {
					"owner" : $.trim($("#create-owner").val()),
					"name" : $.trim($("#create-name").val()),
					"startDate" : $.trim($("#create-startDate").val()),
					"endDate" : $.trim($("#create-endDate").val()),
					"cost" : $.trim($("#create-cost").val()),
					"description" : $.trim($("#create-description").val())
				},
				type : "post",
				dataType: "json",
				success : function (data){
					if (data.success){
						//添加成功后回到第一页
						pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

						//清空添加操作模态窗口中的数据
						//虽然jquery对象没有为我们提供submit()方法，但是原生js为我们提供了reset方法  所以我们要将jquery对象转换为原生dom对象
						//jquery对象转换为dom对象: 	jquery对象[下标]
						//dom对象转为jquery对象:		$(dom)
						$("#activityAddForm")[0].reset();

						//关闭添加操作的模态窗口
						$("#createActivityModal").modal("hide");
					}else{
						alert("添加市场活动失败")
					}
				}
			})
		})

		//页面加载完毕后触发分页查询
		pageList(1,2);

		//为查询按钮绑定按钮，触发pageList方法
		$("#searchBtn").click(function (){

			//点击搜索框按钮的时候，应该先将搜索框中的信息保存起来,保存到隐藏域中
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-startDate").val($.trim($("#search-startDate").val()));
			$("#hidden-endDate").val($.trim($("#search-endDate").val()));

			pageList(1,2);
		})

		//为全选的复选框绑定事件，触发全选操作
		$("#qx").click(function (){
			$("input[name=xz]").prop("checked",this.checked);
		})

		//为动态生成的复选框绑定事件，动态生成的元素，要以on方法的形式来触发事件
		//语法: $(需要绑定元素的有效的外层元素).on("绑定事件的方式",需要绑定的元素的jquery对象,回调函数)
		$("#ActivityBody").on("click",$("input[name=xz]"),function (){
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length);
		})

		//为删除按钮绑定事件，执行市场活动删除操作
		$("#deleteBtn").click(function (){
			//找到复选框中所有打√的复选框的jquery对象
			var $xz = $("input[name=xz]:checked");
			if ($xz.length == 0){
				alert("请选择需要删除的记录")
			}else{

				//有可能选中一条，有可能选中多条拼接参数
				var param = "";
				//将$xz中的每一个dom对象遍历出来，取其value值，就相当于取得了需要删除的记录的id
				for (var i=0; i<$xz.length; i++){
					param += "id=" +$($xz[i]).val();

					//如果不是最后一个元素，需要在后面追加一个&符号
					if (i<$xz.length-1){
						param += "&";
					}
				}

				if (confirm("您确定要删除所选的记录吗?")){
					//发出删除市场活动列表的AJAX请求
					$.ajax({
						url : "workbench/activity/delete.do",
						data : param,
						type : "post",
						dataType : "json",
						success : function (data){
							if (data.success){

								//修改成功后，应该回到第一页，维持每页展现的记录数。
								pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

							}else{
								alert("删除市场活动失败");
							}
						}
					})
				}
			}
		})

		//为修改按钮绑定事件，打开修改操作的模态窗口
		$("#editBtn").click(function (){
			var $xz = $("input[name=xz]:checked");
			if ($xz.length==0){
				alert("请选择需要修改的记录")
			}else if ($xz.length>1){
				alert("只能选择一条记录进行修改")
			}else{
				var id = $xz.val();

				//查询要修改的记录信息
				$.ajax({
					url : "workbench/activity/getUserListAndActivity.do",
					data : {
						"id" : id
					},
					type : "get",
					dataType : "json",
					success : function (data){
						//data:返回用户列表和市场活动对象  {"uList":[{用户1},{2},{3}], "activity":{市场活动}}

						//1.处理所有者的下拉框
						var html = "<option></option>";
						$.each(data.uList, function (i,n){
							html += "<option value='"+n.id+"'>"+n.name+"</option>";
						})
						$("#edit-owner").html(html);

						//2.处理单条activity
						$("#edit-id").val(data.activity.id);
						$("#edit-name").val(data.activity.name);
						$("#edit-owner").val(data.activity.owner);
						$("#edit-startDate").val(data.activity.startDate);
						$("#edit-endDate").val(data.activity.endDate);
						$("#edit-cost").val(data.activity.cost);
						$("#edit-description").val(data.activity.description);

						//打开修改操作的模态窗口
						$("#editActivityModal").modal("show");
					}
				})
			}
		})

		//为更新按钮绑定事件，执行市场活动的修改操作
		$("#updateBtn").click(function (){
			$.ajax({
				url : "workbench/activity/update.do",
				data : {
					"id" : $.trim($("#edit-id").val()),
					"owner" : $.trim($("#edit-owner").val()),
					"name" : $.trim($("#edit-name").val()),
					"startDate" : $.trim($("#edit-startDate").val()),
					"endDate" : $.trim($("#edit-endDate").val()),
					"cost" : $.trim($("#edit-cost").val()),
					"description" : $.trim($("#edit-description").val())
				},
				type : "post",
				dataType: "json",
				success : function (data){
					if (data.success){
						//修改成功后，应该维持当前页
						pageList($("#activityPage").bs_pagination('getOption', 'currentPage')	//操作后停留在当前页
								,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));	//操作后维持已经设置好的每页展现的记录数

						//关闭修改操作的模态窗口
						$("#editActivityModal").modal("hide");
					}else{
						alert("修改市场活动失败")
					}
				}
			})
		})

	});

	//对于所有的关系型数据库，做前端的分页相关操作的基础组件，就是 pageSize(每页展现的记录条数) 和 pageNo(当前页的页码)
	/*
		在哪些情况下需要调用pageList
			1.点击左侧菜单中的"市场活动"超链接  页面加载完刷新
			2.添加、修改、删除后，需要刷新市场活动列表
			3.点击查询按钮的时候，需要刷新市场活动列表
			4.点击分页组件的时候
	*/
	function pageList(pageNo,pageSize){

		//将全选的复选框的√干掉
		$("#qx").prop("checked",false);

		//查询前，将隐藏域中的信息取出来，重新赋予到搜索框中
		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-startDate").val($.trim($("#hidden-startDate").val()));
		$("#search-endDate").val($.trim($("#hidden-endDate").val()));

		$.ajax({
			url : "workbench/activity/pageList.do",
			data : {
				"pageNo" : pageNo,
				"pageSize" : pageSize,
				"name" : $.trim($("#search-name").val()),
				"owner" : $.trim($("#search-owner").val()),
				"startDate" : $.trim($("#search-startDate").val()),
				"endDate" : $.trim($("#search-endDate").val()),
			},
			type : "get",
			dataType : "json",
			success : function (data){
				//data: 返回市场活动json,{"total":"100","dataList":[{市场活动1},{2},{3}]}
				var html = "";
				//每一个n就是一个市场活动对象
				$.each(data.dataList,function (i,n){
					html += '<tr class="active">';
					html += '	<td><input type="checkbox" name="xz" value="'+n.id+'" /></td>';
					html += '	<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/detail.do?id='+n.id+'\';">'+n.name+'</a></td>';
					html += '	<td>'+n.owner+'</td>';
					html += '	<td>'+n.startDate+'</td>';
					html += '	<td>'+n.endDate+'</td>';
					html += '</tr>';
				})
				$("#ActivityBody").html(html);

				//计算总页数
				var totalPages = data.total%pageSize == 0 ? data.total/pageSize : parseInt(data.total/pageSize)+1;

				//数据处理完毕后，结合分页查询，对前端展现分页信息
				$("#activityPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: data.total, // 总记录条数

					visiblePageLinks: 3, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,

					//该回调函数在点击分页组件的时候触发
					onChangePage : function(event, data){
						pageList(data.currentPage , data.rowsPerPage);
					}
				});
			}
		})
	}

	$.ajaxSetup({
		//设置ajax请求结束后的执行动作
		complete : function(XMLHttpRequest, textStatus) {
			//拦截器实现超时跳转到登录页面
			// 通过XMLHttpRequest取得响应头，sessionstatus
			var sessionstatus = XMLHttpRequest.getResponseHeader("sessionstatus");
			if (sessionstatus == "TIMEOUT")
			{
				var win = window;
				while (win != win.top)
				{
					win = win.top;
				}
				//重新跳转到 login.html
				win.location.href= XMLHttpRequest.getResponseHeader("CONTEXTPATH");
			}
		}
	});

</script>
</head>
<body>
<!--由隐藏域保存市场活动列表中的搜索框信息-->
<input type="hidden" id="hidden-name">
<input type="hidden" id="hidden-owner">
<input type="hidden" id="hidden-startDate">
<input type="hidden" id="hidden-endDate">

<!-- 修改市场活动的模态窗口 -->
<div class="modal fade" id="editActivityModal" role="dialog">
	<div class="modal-dialog" role="document" style="width: 85%;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">
					<span aria-hidden="true">×</span>
				</button>
				<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
			</div>
			<div class="modal-body">

				<form class="form-horizontal" role="form">

					<input type="hidden" id="edit-id" />

					<div class="form-group">
						<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="edit-owner">

							</select>
						</div>
						<label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-name">
						</div>
					</div>

					<div class="form-group">
						<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control time" id="edit-startDate">
						</div>
						<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control time" id="edit-endDate" >
						</div>
					</div>

					<div class="form-group">
						<label for="edit-cost" class="col-sm-2 control-label">成本</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-cost">
						</div>
					</div>

					<div class="form-group">
						<label for="edit-describe" class="col-sm-2 control-label">描述</label>
						<div class="col-sm-10" style="width: 81%;">
							<!--
								关于文本域textarea:
									1.一定要以标签对的方式呈现，正常状态下标签对要紧紧的挨着
									2.textarea虽然是以标签对的形式来呈现的，但是它也是属于表单元素范畴，所有对于textarea的取值和赋值操作，应该统一使用val()方法 (不是html方法)
							-->
							<textarea class="form-control" rows="3" id="edit-description"></textarea>
						</div>
					</div>

				</form>

			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
			</div>
		</div>
	</div>
</div>


<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="activityAddForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
									<!--此处为拼接的option字符串-->
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-name">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startDate" readonly>
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endDate" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>

	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="search-startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="search-endDate">
				    </div>
				  </div>
				  
				  <button type="button" id="searchBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
					<!--
					点击创建按钮，观察两个属性和属性值
						data-toggle="modal": 表示触发该按钮，将要打开一个模态窗口
						data-target="#createActivityModal": 表示要打开哪个模态窗口，通过#id的形式找到该窗口

					现在我们是以属性、属性值的方式写在了button元素中，用来打开模态窗口，但是这样做是有问题的。
						问题在于没有办法对按钮的功能进行扩充
					-->
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx"/></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="ActivityBody">
						<%--<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="activityPage"></div>
			</div>
			
		</div>
		
	</div>
</body>
</html>