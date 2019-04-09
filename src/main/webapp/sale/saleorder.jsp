<%@page import="java.util.ArrayList"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>销售订货单</title>
<link rel="stylesheet" type="text/css"
	href="/static/jquery-easyui-1.3.3/themes/default/easyui.css"></link>
<link rel="stylesheet" type="text/css"
	href="/static/jquery-easyui-1.3.3/themes/icon.css"></link>
<script type="text/javascript"
	src="/static/jquery-easyui-1.3.3/jquery.min.js"></script>
<script type="text/javascript"
	src="/static/jquery-easyui-1.3.3/jquery.easyui.min.js"></script>
<script type="text/javascript"
	src="/static/jquery-easyui-1.3.3/locale/easyui-lang-zh_CN.js"></script>
<script type="text/javascript" src="/static/js/date.js"></script>
<script type="text/javascript" src="print.js"></script>
<script type="text/javascript">
	var fieldlist = [];
	//确定选择要打印的列 
	function saveSelectRows() {
		var fieldArr = [];
		$("#dlg4").find("input").each(function() {
			if ($(this).is(':checked')) {
				var idVal = $(this).attr("id");
				idVal = idVal.substr(0, idVal.length - 3);
				if (fieldArr.indexOf(idVal) == -1) {
					fieldArr.push(idVal);
				}
			}
		});
		if (fieldArr.length == 0) {
			$.messager.alert("系统提示",
					"<span style='color:red;'>请选择要打印的列！</span>");
			return;
		}
		var fields = fieldArr.join(",");
		$.post("/admin/printSet/selectRows", {
			fields : fields
		}, function(result) {
			if (result.success) {
				$.messager.alert("系统提示", "保存成功！");
				closeSelectRows();
			}
		}, "json");
	}

	//打开设置打印列
	function selectPrintRows() {
		//获取之前所选择的打印列
		$.post("/admin/printSet/getSelectRows",
				function(result) {
					if (result.success) {
						console.log(result.fields);
						for (var i = 0; i < result.fields.length; i++) {
							result.fields[i] = "#" + result.fields[i];
							$(result.fields[i]).prop("checked", true);
							fieldlist.push(result.fields[i].substr(0,
									result.fields[i].length - 3));
						}
					}
				}, "json");

		$("#dlg4").dialog("open");
	}

	//关闭打印设置列 
	function closeSelectRows() {
		$("#dlg4").dialog("close");
	}

	function printdg() {
		CreateFormPage("datagrid", $("#dg"));
	}

	var url;
	$(document).ready(function() {

		$("#customerId").combobox({
			mode : 'remote',
			url : '/admin/customer/comboList',
			valueField : 'id',
			textField : 'name',
			delay : 100
		});

		$("#saleDate").datebox("setValue", genTodayStr());

		$("#dh").load("/admin/saleList/genCode");

	});

	//封装订单信息传递后台
	function saveSaleGoods() {
		$("#saleNumber").val($("#dh").text());
		$("#goodsJson").val(JSON.stringify($("#dg").datagrid("getData").rows));
		$("#fm").form("submit", {
			url : "/admin/saleList/save",
			onSubmit : function() {
				if ($("#dg").datagrid("getRows").length == 0) {
					$.messager.alert("系统提示", "请添加销售商品！");
					return false;
				}
				if (!$(this).form("validate")) {
					return false;
				}
				if (isNaN($("#clientId").combobox("getValue"))) {
					$.messager.alert("系统提示", "请选择客户！");
					return false;
				}
				return true;
			},
			success : function(result) {
				var result = eval('(' + result + ')');
				if (result.success) {
					alert("保存成功！");
					window.location.reload();
				} else {
					$.messager.alert("系统提示", result.errorInfo);
				}
			}
		});
	}

	function openSaleListGoodsModifyDialog() {
		$("#saveAddAddNextButton").hide();
		var selectedRows = $("#dg").datagrid("getSelections");
		if (selectedRows.length != 1) {
			$.messager.alert("系统提示", "请选择一条信息！");
			return;
		}
		var row = selectedRows[0];
		$("#dlg").dialog("open").dialog("setTitle", "修改销售订单信息");
		$("#fm2").form("load", row);
		$("#action").val("modify");
		$("#rowIndex").val($("#dg").datagrid("getRowIndex", row));
	}

	function deleteSaleListGoods() {
		var selectedRows = $("#dg").datagrid("getSelections");
		if (selectedRows.length != 1) {
			$.messager.alert("系统提示", "请选择一条要删除的商品！");
			return;
		}
		$.messager.confirm("系统提示", "您确定要删除这商品吗?", function(r) {
			if (r) {
				$("#dg").datagrid("deleteRow",
						$("#dg").datagrid("getRowIndex", selectedRows[0]));
				setSaleListAmount();
			}
		});
	}

	// 销售订货单模块
	function setSaleListAmount() {
		var rows = $("#dg").datagrid("getRows");
		var amount = 0;
		for (var i = 0; i < rows.length; i++) {
			var row = rows[i];
			amount += row.total;
		}
		$("#amountPayable").val(amount.toFixed(2));
	}

	function openSaleListGoodsAddDialog() {
		$("#action").val("add")
		$("#dlg").dialog("open").dialog("setTitle", "销售订货单");
	}

	function openGoodsChooseDialog() {
		$("#saveAddAddNextButton").show();
		var selectedRows = $("#dg2").datagrid("getSelections");
		if (selectedRows.length != 1) {
			$.messager.alert("系统提示", "请选择一个商品！");
			return;
		}
		var row = selectedRows[0];
		$("#dlg2").dialog("open").dialog("setTitle", "选择商品");
		$("#fm2").form("load", row);
		$("#sellingPrice").val("¥" + row.sellingPrice);
		$("#price").numberbox("setValue", row.sellingPrice);
		$("#action").val("add");
		$("#num").focus();
	}

	function resetValue() {
		$("#name").combobox('reset');
		$("#model").numberbox("reset");
		$("#price").numberbox("reset");
		$("#length").numberbox("reset");
		$("#color").val("");
		$("#realitymodel").numberbox("reset");
		$("#realityprice").numberbox("reset");
		$("#num").numberbox("reset");
		$("#theoryweight").numberbox("reset");
		$("#oneweight").numberbox("reset");
		$("#square").numberbox("reset");
		$("#numsquare").numberbox("reset");
		$("#demand").combobox('reset');
		$("#weightway").val("");
		$("#label").val("");
		$("#peasant").val("");
		$("#weight").numberbox("reset");
		$("#dao").combobox('reset');
		$("#brand").combobox('reset');
		$("#pack").combobox('reset');
		$("#letter").combobox('reset');
		$("#patu").combobox('reset');
		$("#wightset").combobox('reset');
		$("#sumwight").numberbox("reset");
		$("#meter").numberbox("reset");
		$("#realityweight").numberbox("reset");
		$("#clientname").val("");
		$("#remark").val("");
	}

	//添加或修改订单商品信息 
	function saveGoods(type) {
		var action = $("#action").val();
		if (!$("#fm2").form("validate")) {
			return;
		}
		if (action == "add") {
			var name = $("#name").combobox('getText');
			var model = $("#model").numberbox("getValue");
			var price = $("#price").numberbox("getValue");
			var length = $("#length").numberbox("getValue");
			var color = $("#color").val();
			var realitymodel = $("#realitymodel").numberbox("getValue");
			var realityprice = $("#realityprice").numberbox("getValue");
			var num = $("#num").numberbox("getValue");
			var theoryweight = $("#theoryweight").numberbox("getValue");
			var oneweight = $("#oneweight").numberbox("getValue");
			var square = $("#square").numberbox("getValue");
			var numsquare = $("#numsquare").numberbox("getValue");
			var demand = $("#demand").combobox('getText');
			var weightway = $("#weightway").val();
			var label = $("#label").val();
			var peasant = $("#peasant").val();
			var weight = $("#weight").numberbox("getValue");
			var dao = $("#dao").combobox('getText');
			var brand = $("#brand").combobox('getText');
			var pack = $("#pack").combobox('getText');
			var letter = $("#letter").combobox('getText');
			var patu = $("#patu").combobox('getText');
			var wightset = $("#wightset").combobox("getText");
			var sumwight = $("#sumwight").numberbox("getValue");
			var meter = $("#meter").numberbox("getValue");
			var clientname = $("#clientname").val();
			var realityweight = $("#realityweight").val();
			var remark = $("#remark").val();
			$("#dg").datagrid("appendRow", {
				name : name,
				model : model,
				price : price,
				length : length,
				color : color,
				realitymodel : realitymodel,
				realityprice : realityprice,
				num : num,
				theoryweight : theoryweight,
				oneweight : oneweight,
				square : square,
				numsquare : numsquare,
				demand : demand,
				weightway : weightway,
				label : label,
				peasant : peasant,
				weight : weight,
				dao : dao,
				brand : brand,
				pack : pack,
				letter : letter,
				patu : patu,
				wightset : wightset,
				sumwight : sumwight,
				meter : meter,
				clientname : clientname,
				realityweight : realityweight,
				remark : remark
			});
		} else if (action == "modify") {
			var selectedRows = $("#dg").datagrid("getSelections");
			var row = selectedRows[0];
			var rowIndex = $("#rowIndex").val();
			var name = $("#name").combobox('getText');
			var model = $("#model").numberbox("getValue");
			var price = $("#price").numberbox("getValue");
			var length = $("#length").numberbox("getValue");
			var color = $("#color").val();
			var realitymodel = $("#realitymodel").numberbox("getValue");
			var realityprice = $("#realityprice").numberbox("getValue");
			var num = $("#num").numberbox("getValue");
			var theoryweight = $("#theoryweight").numberbox("getValue");
			var oneweight = $("#oneweight").numberbox("getValue");
			var square = $("#square").numberbox("getValue");
			var numsquare = $("#numsquare").numberbox("getValue");
			var demand = $("#demand").combobox('getText');
			var weightway = $("#weightway").val();
			var label = $("#label").val();
			var peasant = $("#peasant").val();
			var weight = $("#weight").numberbox("getValue");
			var dao = $("#dao").combobox('getText');
			var brand = $("#brand").combobox('getText');
			var pack = $("#pack").combobox('getText');
			var letter = $("#letter").combobox('getText');
			var patu = $("#patu").combobox('getText');
			var wightset = $("#wightset").combobox("getText");
			var sumwight = $("#sumwight").numberbox("getValue");
			var meter = $("#meter").numberbox("getValue");
			var clientname = $("#clientname").val();
			var realityweight = $("#realityweight").val();
			var remark = $("#remark").val()
			$("#dg").datagrid("updateRow", {
				index : rowIndex,
				row : {
					name : name,
					model : model,
					price : price,
					length : length,
					color : color,
					realitymodel : realitymodel,
					realityprice : realityprice,
					num : num,
					theoryweight : theoryweight,
					oneweight : oneweight,
					square : square,
					numsquare : numsquare,
					demand : demand,
					weightway : weightway,
					label : label,
					peasant : peasant,
					weight : weight,
					dao : dao,
					brand : brand,
					pack : pack,
					letter : letter,
					patu : patu,
					wightset : wightset,
					sumwight : sumwight,
					meter : meter,
					clientname : clientname,
					realityweight : realityweight,
					remark : remark
				}
			});
		}
		setSaleListAmount();
		if (type == 1) {
			closeGoodsDialog();
		}
		closeGoodsChooseDialog();
	}

	function closeGoodsDialog() {
		$('#s_codeOrName').val('');
		$("#dlg").dialog("close");
	}

	function closeGoodsChooseDialog() {
		resetValue();
		$("#dlg2").dialog("close");
	}

	function saveGoodsType() {
		if (!$("#fm3").form("validate")) {
			return;
		}
		var goodsTypeName = $('#goodsTypeName').val();
		var node = $("#tree").tree("getSelected"); // 获取选中节点
		var parentId;
		if (node == null) {
			parentId = 1;
		} else {
			parentId = node.id;
		}
		$.post("/admin/goodsType/save", {
			name : goodsTypeName,
			parentId : parentId
		}, function(result) {
			if (result.success) {
				$("#tree").tree("reload");
				closeGoodsTypeDialog();
			} else {
				$.messager.alert("系统提示", "提交失败，请联系管理员！");
			}
		}, "json");
	}

	//打开上传文件面板
	function toLead() {
		$("#dlg3").dialog("open").dialog("setTitle", "选择上传文件");
	}

	//提交上传文件 
	function saveToLead() {

		$("#fm3").form('submit', {
			url : "/admin/toLead/importFile",
			onSubmit : function() {
				var fileAccept = $("#fil").val().split(".")[1];
				if (fileAccept != "xls" && fileAccept != "xlsx") {
					alert("只能上传.xls和.xlsx的文件！");
					return false;
				}
				return true;
			},
			success : function(result) {
				var resultt = $.parseJSON(result);
				$("#dg").datagrid({
					data : resultt
				});
			}
		});

		$("#dlg3").dialog("close");
	}

	//关闭面导入面板 
	function closeToLead() {
		$("#dlg3").dialog("close");
	}

	//存放隐藏的列的field
	var rowArr = [];
	//显示所有列 
	function showAllRows() {
		console.log(rowArr);
		for (var i = 0; i < rowArr.length; i++) {
			$("#dg").datagrid("showColumn", rowArr[i]);
		}
		rowArr = [];
	}

	//显示打印列
	function showPrintRows() {
		if (rowArr.length == 0) {
			$.messager
					.alert('系统提示',
							'<span style="color:red">你还未设置打印列，双击要想要取消打印列中的任意一个单元格点击确定即可</span>');
		} else {
			for (var i = 0; i < rowArr.length; i++) {
				("#dg").datagrid("hideColumn", rowArr[i]);
			}
		}
	}

	$(document).ready(function() {

		closeSelectRows();

		//双击隐藏该列
		$("#dg").datagrid({
			onDblClickCell : function(index, field, row) {
				$.messager.confirm('系统提示', '确定取消打印该列吗？', function(r) {
					if (r) {
						rowArr.push(field);
						$("#dg").datagrid("hideColumn", field);
					}
				});
			}
		});

	});

	var tableString;
	// strPrintName 打印任务名
	// printDatagrid 要打印的datagrid
	function CreateFormPage(strPrintName, printDatagrid) {
		tableString = "";
		tableString += "<h1 style='font-size: 66px;text-align: center;'>销售订货单</h1>";
		tableString += "<h3>销售日期：" + $("#saleDate").datebox("getValue")
				+ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;购货单位："
				+ $("#clientId").combobox("getText")
				+ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 销售方式："
				+ $("#sellId").combobox("getText")
				+ " &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;业务员： "
				+ $("#clerkId").combobox("getText")
				+ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;联系人："
				+ $("#lankman").val()
				+ " &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;客户电话："
				+ $("#tel").val()
				+ " &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;客户地址： "
				+ $("#address").val()
				+ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;发货时间："
				+ $("#deliveryDate").datebox("getValue") + "</h3>";
		tableString += '<table cellspacing="0" class="pb">';
		var frozenColumns = printDatagrid.datagrid("options").frozenColumns; // 得到frozenColumns对象
		var columns = printDatagrid.datagrid("options").columns; // 得到columns对象
		var nameList = '';

		// 载入title
		if (typeof columns != 'undefined' && columns != '') {
			$(columns)
					.each(
							function(index) {
								tableString += '\n<tr>';
								if (typeof frozenColumns != 'undefined'
										&& typeof frozenColumns[index] != 'undefined') {
									for (var i = 0; i < frozenColumns[index].length; ++i) {
										if (!frozenColumns[index][i].hidden) {
											tableString += '\n<th width="'
													+ frozenColumns[index][i].width
													+ '"';
											if (typeof frozenColumns[index][i].rowspan != 'undefined'
													&& frozenColumns[index][i].rowspan > 1) {
												tableString += ' rowspan="'
														+ frozenColumns[index][i].rowspan
														+ '"';
											}
											if (typeof frozenColumns[index][i].colspan != 'undefined'
													&& frozenColumns[index][i].colspan > 1) {
												tableString += ' colspan="'
														+ frozenColumns[index][i].colspan
														+ '"';
											}
											if (typeof frozenColumns[index][i].field != 'undefined'
													&& frozenColumns[index][i].field != '') {
												nameList += ',{"f":"'
														+ frozenColumns[index][i].field
														+ '", "a":"'
														+ frozenColumns[index][i].align
														+ '"}';
											}
											tableString += '>'
													+ frozenColumns[0][i].title
													+ '</th>';
										}
									}
								}
								for (var i = 0; i < columns[index].length; ++i) {
									if (!columns[index][i].hidden) {
										tableString += '\n<th width="'
												+ columns[index][i].width + '"';
										if (typeof columns[index][i].rowspan != 'undefined'
												&& columns[index][i].rowspan > 1) {
											tableString += ' rowspan="'
													+ columns[index][i].rowspan
													+ '"';
										}
										if (typeof columns[index][i].colspan != 'undefined'
												&& columns[index][i].colspan > 1) {
											tableString += ' colspan="'
													+ columns[index][i].colspan
													+ '"';
										}
										if (typeof columns[index][i].field != 'undefined'
												&& columns[index][i].field != '') {
											nameList += ',{"f":"'
													+ columns[index][i].field
													+ '", "a":"'
													+ columns[index][i].align
													+ '"}';
										}
										tableString += '>'
												+ columns[index][i].title
												+ '</th>';
									}
								}
								tableString += '\n</tr>';
							});
		}
		// 载入内容
		var rows = printDatagrid.datagrid("getRows"); // 这段代码是获取当前页的所有行
		console.log(rows);
		console.log(nameList);
		var nl = eval('([' + nameList.substring(1) + '])');
		console.log(nl);
		for (var i = 0; i < rows.length; ++i) {
			tableString += '\n<tr>';
			$(nl).each(function(j) {
				var e = nl[j].f.lastIndexOf('_0');

				tableString += '\n<td';
				if (nl[j].a != 'undefined' && nl[j].a != '') {
					tableString += ' style="text-align:' + nl[j].a + ';"';
				}
				tableString += '>';
				if (e + 2 == nl[j].f.length) {
					tableString += rows[i][nl[j].f.substring(0, e)];
				} else {
					var tdStr = rows[i][nl[j].f];
					if (tdStr == null) {
						tdStr = "";
					}
					console.log(tdStr);
					tableString += tdStr;
				}
				tableString += '</td>';
			});
			tableString += '\n</tr>';
		}
		tableString += '\n</table>';
		if (window.showModalDialog) {
			window
					.showModalDialog(
							"print.html",
							tableString,
							"location:No;status:No;help:No;dialogWidth:800px;dialogHeight:600px;scroll:auto;");
		} else {
			window
					.open(
							"print.html",
							tableString,
							"location:No;status:No;help:No;dialogWidth:800px;dialogHeight:600px;scroll:auto;");
			console.log(tableString);
		}
	}
</script>
</head>
<body class="easyui-layout">
	<div data-options="region:'north'"
		style="height: 135px; padding: 10px; border: 0px; padding-top: 20px">
		<fieldset style="border-color: #E7F0FF">
			<legend>
				单号：<span id="dh"></span>
			</legend>
			<form id="fm" method="post">
				<table cellspacing="8px">
					<tr>
						<td>日&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;期：<input
							type="text" id="saleDate" name="saleDate" class="easyui-datebox"
							demandd="true" data-options="editable:false" size="15" />
						</td>
						<td>&nbsp;&nbsp;&nbsp;&nbsp;购货单位：<input
							class="easyui-combobox" id="clientId" name="clientId"
							style="width: 150px" required="true" demandd="true"
							data-options="demandd:true,panelHeight:'auto',valueField:'id',textField:'name',url:'/admin/client/clientList'" />
						</td>
						<td>&nbsp;&nbsp;&nbsp;&nbsp;销售方式：<input
							class="easyui-combobox" id="sellId" name="sellId"
							style="width: 100px"
							data-options="panelHeight:'auto',valueField:'id',textField:'method',url:'/admin/sell/sellList'" />
						</td>
						<td width="180px">
							&nbsp;&nbsp;&nbsp;&nbsp;业&nbsp;务&nbsp;员&nbsp;：<input
							class="easyui-combobox" id="clerkId" name="clerkId"
							style="width: 100px"
							data-options="panelHeight:'auto',valueField:'id',textField:'name',url:'/admin/clerk/clerkList'" />
						</td>
						<td>联系人：<input type="text" id="lankman" required="true"
							name="lankman" size="15" />
						</td>
					</tr>
					<tr>
						<td>客户电话：<input type="text" id="tel" name="tel"
							class="easyui-validatebox" size="15" />
						</td>
						<td colspan="2">&nbsp;&nbsp;&nbsp;客户地址 ：<input type="text"
							id="address" name="address" size="43" />
						</td>
						<td>&nbsp;&nbsp;&nbsp;&nbsp;发货时间：<input type="text"
							id="deliveryDate" name="deliveryDate" class="easyui-datebox"
							size="10" />
						</td>
						<td><input type="hidden" id="saleNumber" name="saleNumber" />
							<input type="hidden" id="goodsJson" name="goodsJson" /> <a
							href="javascript:saveSaleGoods()" class="easyui-linkbutton"
							iconCls="icon-ok">保存</a> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a
							href="javascript:toLead()" class="easyui-linkbutton"
							iconCls="icon-add">导入</a></td>
					</tr>
				</table>
			</form>
		</fieldset>
	</div>
	<div data-options="region:'center'" style="padding: 10px; border: 1px">
		<table id="dg" class="easyui-datagrid" style="" rownumbers="true"
			singleSelect="true" fit="true" toolbar="#tb">
			<thead>
				<th id="nameRow" field="name" width="200" align="center">产品名称</th>
				<th id="modelRow" field="model" width="200" align="center">幅宽（m）</th>
				<th id="priceRow" field="price" width="200" align="center">厚度（mm）</th>
				<th id="lengthRow" field="length" width="200" align="center">长度（m）</th>
				<th id="meterRow" field="meter" width="200" align="center">生产米数</th>
				<th id="colorRow" field="color" width="200" align="center">颜色</th>
				<th id="oneweightRow" field="oneweight" width="200" align="center">单件重量（kg）</th>
				<th id="numRow" field="num" width="200" align="center">订货数量</th>
				<th id="sumwightRow" field="sumwight" width="200" align="center">总重量</th>
				<th id="realitymodRow" field="realitymodel" width="200"
					align="center">实际幅宽（m）</th>
				<th id="demandRow" field="demand" width="200" align="center">要求</th>
				<th id="wightsetRow" field="wightset" width="200" align="center">重量设置</th>
				<th id="daoRow" field="dao" width="200" align="center">剖刀</th>
				<th id="brandRow" field="brand" width="200" align="center">商标</th>
				<th id="packRow" field="pack" width="200" align="center">包装</th>
				<th id="letterRow" field="letter" width="200" align="center">印字</th>
				<th id="peasantRow" field="peasant" width="200" align="center">农户名称</th>
				<th id="clientnameRow" field="clientname" width="200" align="center">客户名称</th>
				<th id="realityweiRow" field="realityweight" width="200"
					align="center">实际重量（kg）</th>
				<th id="realitypriRow" field="realityprice" width="200"
					align="center">实际厚度（mm）</th>
				<th id="theoryweigRow" field="theoryweight" width="200"
					align="center">理论重量（kg）</th>
				<th id="squareRow" field="square" width="200" align="center">单件平米</th>
				<th id="numsquareRow" field="numsquare" width="200" align="center">总平米</th>
				<th id="weightwayRow" field="weightway" width="200" align="center">称重方式</th>
				<th id="labelRow" field="label" width="200" align="center">标签名称</th>
				<th id="weightRow" field="weight" width="200" align="center">重量（kg）</th>
				<th id="patuRow" field="patu" width="200" align="center">纸管</th>
				<th id="remarkRow" field="remark" width="200" align="center">备注</th>
			</thead>
		</table>

		<div id="tb">
			<div style="padding: 2px">
				<a href="javascript:openSaleListGoodsAddDialog()"
					class="easyui-linkbutton" iconCls="icon-add" plain="true">添加</a> <a
					href="javascript:openSaleListGoodsModifyDialog()"
					class="easyui-linkbutton" iconCls="icon-edit" plain="true">修改</a> <a
					href="javascript:deleteSaleListGoods()" class="easyui-linkbutton"
					iconCls="icon-remove" plain="true">删除</a> <a
					href="javascript:printdg()" ;
					class="easyui-linkbutton"
					iconCls="icon-print" plain="true">打印</a> <a
					href="javascript:showAllRows()" class="easyui-linkbutton"
					plain="true">显示所有列</a> <a href="javascript:showPrintRows()"
					class="easyui-linkbutton" plain="true">显示打印列</a> <a
					href="javascript:selectPrintRows()" class="easyui-linkbutton"
					plain="true">设置打印列</a>
			</div>
		</div>
	</div>

	<div id="dlg" class="easyui-dialog"
		style="width: 600px; height: 450px; padding: 10px 20px" closed="true"
		buttons="#dlg-buttons" data-options="onClose:function(){resetValue()}">
		<form id="fm2" method="post">
			<table>
				<tr>
					<td>产&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;品&nbsp;&nbsp;&nbsp;&nbsp;名&nbsp;&nbsp;&nbsp;&nbsp;称
						：</td>
					<td><input type="hidden" id="action" /> <input type="hidden"
						id="rowIndex" /> <input type="text" id="name" name="name"
						class="easyui-combobox" style="width: 119px"
						data-options="demandd:true,panelHeight:'auto',valueField:'id',textField:'name',url:'/admin/product/productList'" />
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>幅&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;宽（m）&nbsp;：</td>
					<td><input type="text" id="model" name="model"
						class="easyui-numberbox" style="width: 120px" /></td>
				</tr>
				<tr>
					<td>厚&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;度（mm）：</td>
					<td><input type="text" id="price" name="price"
						class="easyui-numberbox" style="width: 120px" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>长&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;度（m） ：</td>
					<td><input type="text" id="length" name="length"
						class="easyui-numberbox" style="width: 120px" /></td>
				</tr>
				<tr>
					<td>颜&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;色
						：</td>
					<td><input type="text" id="color" name="color"
						class="easyui-validatebox" style="width: 120px" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>实际幅宽（m） ：</td>
					<td><input type="text" id="realitymodel" name="realitymodel"
						class="easyui-numberbox" style="width: 120px" /></td>
				</tr>
				<tr>
					<td>实际厚度（mm） ：</td>
					<td><input type="text" id="realityprice" name="realityprice"
						class="easyui-numberbox" style="width: 120px" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>订&nbsp;&nbsp;&nbsp;货&nbsp;&nbsp;&nbsp;数&nbsp;&nbsp;&nbsp;量&nbsp;&nbsp;：</td>
					<td><input type="text" id="num" name="num"
						class="easyui-numberbox" style="width: 120px" /></td>
				</tr>
				<tr>
					<td>理论重量（k&nbsp;&nbsp;&nbsp;g）：</td>
					<td><input type="text" id="theoryweight" name="theoryweight"
						class="easyui-numberbox" style="width: 120px" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>单件重量（kg）：</td>
					<td><input type="text" id="oneweight" name="oneweight"
						class="easyui-numberbox" style="width: 120px" /></td>
				</tr>
				<tr>
					<td>单&nbsp;&nbsp;&nbsp;
						件&nbsp;&nbsp;&nbsp;&nbsp;平&nbsp;&nbsp;&nbsp;&nbsp;米&nbsp;&nbsp;：</td>
					<td><input type="text" id="square" name="square"
						class="easyui-numberbox" style="width: 120px" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>总&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;平&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;米：</td>
					<td><input type="text" id="numsquare" name="numsquare"
						class="easyui-numberbox" style="width: 120px" /></td>
				</tr>
				<tr>
					<td>要&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;求
						：</td>
					<td><input type="text" id="demand" name="demand"
						class="easyui-combobox" style="width: 120px" id="demandId"
						name="demand.id" style="width: 100px"
						data-options="panelHeight:'auto',valueField:'id',textField:'name',url:'/admin/require/requireList'" />
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>称&nbsp;&nbsp;&nbsp;重&nbsp;&nbsp;&nbsp;方&nbsp;&nbsp;&nbsp;式
						&nbsp;：</td>
					<td><input type="text" id="weightway" name="weightway"
						class="easyui-validatebox" style="width: 120px" /></td>
				</tr>
				<tr>
					<td>标&nbsp;&nbsp;&nbsp;&nbsp;签&nbsp;&nbsp;&nbsp;&nbsp;名&nbsp;&nbsp;&nbsp;&nbsp;称&nbsp;&nbsp;：</td>
					<td><input type="text" id="label" name="label"
						class="easyui-validatebox" style="width: 120px" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>农&nbsp;&nbsp;&nbsp;户&nbsp;&nbsp;&nbsp;名&nbsp;&nbsp;&nbsp;称&nbsp;&nbsp;：</td>
					<td><input type="text" id="peasant" name="peasant"
						class="easyui-validatebox" style="width: 120px" /></td>
				</tr>
				<tr>
					<td>重&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;量（kg）&nbsp;：</td>
					<td><input type="text" id="weight" name="weight"
						class="easyui-numberbox" style="width: 120px" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>剖&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;刀&nbsp;：</td>
					<td><input type="text" id="dao" name="dao"
						class="easyui-combobox" style="width: 120px" id="daoId"
						name="dao.id" style="width: 100px"
						data-options="panelHeight:'auto',valueField:'id',textField:'name',url:'/admin/dao/daoList'" />
					</td>
				</tr>
				<tr>
					<td>商&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;标&nbsp;：</td>
					<td><input type="text" id="brand" name="brand"
						class="easyui-combobox" style="width: 120px" id="brandId"
						name="brand.id" style="width: 100px"
						data-options="panelHeight:'auto',valueField:'id',textField:'name',url:'/admin/brand/brandList'" />
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>包&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;装&nbsp;：</td>
					<td><input type="text" id="pack" name="pack"
						class="easyui-combobox" style="width: 120px" id="packId"
						name="pack.id" style="width: 100px"
						data-options="panelHeight:'auto',valueField:'id',textField:'name',url:'/admin/pack/packList'" />
					</td>
				</tr>
				<tr>
					<td>印&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;字&nbsp;：</td>
					<td><input type="text" id="letter" name="letter"
						class="easyui-combobox" style="width: 120px" id="letterId"
						name="letter.id" style="width: 100px"
						data-options="panelHeight:'auto',valueField:'id',textField:'name',url:'/admin/letter/letterList'" />
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>纸&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;管&nbsp;：</td>
					<td><input type="text" id="patu" name="patu"
						class="easyui-combobox" style="width: 120px" id="patuId"
						name="patu.id" style="width: 100px"
						data-options="panelHeight:'auto',valueField:'id',textField:'name',url:'/admin/patu/patuList'" />
					</td>
				</tr>
				<tr>
					<td>重&nbsp;&nbsp;&nbsp;&nbsp;量&nbsp;&nbsp;&nbsp;&nbsp;设&nbsp;&nbsp;&nbsp;&nbsp;置&nbsp;&nbsp;：</td>
					<td><input type="text" id="wightset" name="wightset"
						class="easyui-combobox" style="width: 120px" id="wightId"
						name="wight.id" style="width: 100px"
						data-options="panelHeight:'auto',valueField:'id',textField:'name',url:'/admin/wight/wightList'" />
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>总&nbsp;&nbsp;重&nbsp;&nbsp;量（kg）：</td>
					<td><input type="text" id="sumwight" name="sumwight"
						class="easyui-numberbox" style="width: 120px" /></td>
				</tr>
				<tr>
					<td>生&nbsp;&nbsp;&nbsp;
						产&nbsp;&nbsp;&nbsp;&nbsp;米&nbsp;&nbsp;&nbsp;&nbsp;数&nbsp;&nbsp;：</td>
					<td><input type="text" id="meter" name="meter"
						class="easyui-numberbox" style="width: 120px" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>客&nbsp;&nbsp;&nbsp;&nbsp;户&nbsp;&nbsp;&nbsp;&nbsp;名&nbsp;&nbsp;&nbsp;称：</td>
					<td><input type="text" id="clientname" name="clientname"
						class="easyui-validatebox" style="width: 120px" /></td>
				</tr>
				<tr>
					<td>实&nbsp;&nbsp;&nbsp;际&nbsp;&nbsp;&nbsp;&nbsp;重&nbsp;&nbsp;&nbsp;&nbsp;量&nbsp;&nbsp;&nbsp;：</td>
					<td><input type="text" id="realityweight" name="realityweight"
						class="easyui-numberbox" style="width: 120px" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>备&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;注&nbsp;：</td>
					<td><input type="text" id="remark" name="remark"
						class="easyui-validatebox" style="width: 120px" /></td>
				</tr>
			</table>
		</form>
	</div>

	<div id="dlg-buttons">
		<a id="saveAddAddNextButton" href="javascript:saveGoods(2)"
			class="easyui-linkbutton" iconCls="icon-ok">保存并新增下一订单</a> <a
			href="javascript:saveGoods(1)" class="easyui-linkbutton"
			iconCls="icon-ok">保存</a> <a href="javascript:closeGoodsDialog()"
			class="easyui-linkbutton" iconCls="icon-cancel">关闭</a>
	</div>

	<div id="dlg3" class="easyui-dialog"
		style="width: 400px; height: 180px; padding: 10px 20px" closed="true"
		buttons="#dlg-buttons2"
		data-options="onClose:function(){resetValue()}">
		<form id="fm3" method="post" enctype="multipart/form-data"
			action="/admin/toLead/importFile">
			<input id="fil" name="fileName" type="file" />
		</form>
	</div>

	<div id="dlg-buttons2">
		<a href="javascript:saveToLead()" class="easyui-linkbutton"
			iconCls="icon-ok">确定</a> <a href="javascript:closeToLead()"
			class="easyui-linkbutton" iconCls="icon-cancel">关闭</a>
	</div>

	<div id="dlg4" class="easyui-dialog" title="请选择要打印的列"
		style="width: 500px; height: 270px; padding: 10px;"
		buttons="#dlg-buttons4">
		<form action="">
			<table>
				<tr>
					<td><input id="nameIpt" type="checkbox" />产品名称</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="modelIpt"
						type="checkbox" />幅宽（m）
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="priceIpt"
						type="checkbox" />厚度（mm）
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="lengthIpt"
						type="checkbox" />长度（m）
					</td>
				</tr>
				<tr>
					<td><input id="meterIpt" type="checkbox" />生产米数</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="colorIpt"
						type="checkbox" />颜色
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="oneweightIpt"
						type="checkbox" />单件重量（kg）
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="numIpt" type="checkbox" />订货数量
					</td>
				</tr>
				<tr>
					<td><input id="sumwightIpt" type="checkbox" />重量设置</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="realitymodelIpt"
						type="checkbox" />剖刀
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="demandIpt"
						type="checkbox" />商标
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="wightsetIpt"
						type="checkbox" />包装
					</td>
				</tr>
				<tr>
					<td><input id="daoIpt" type="checkbox" />印字</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="brandIpt"
						type="checkbox" />农户名称
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="packIpt"
						type="checkbox" />客户名称
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="letterIpt"
						type="checkbox" />长度（m）
					</td>
				</tr>
				<tr>
					<td><input id="peasantIpt" type="checkbox" />实际厚度（mm）</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="clientnameIpt"
						type="checkbox" />幅宽（m）
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="realityweightIpt"
						type="checkbox" />厚度（mm）
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="realitypriceIpt"
						type="checkbox" />长度（m）
					</td>
				</tr>
				<tr>
					<td><input id="theoryweightIpt" type="checkbox" />理论重量（kg）</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="squareIpt"
						type="checkbox" />单件平米
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="numsquareIpt"
						type="checkbox" />总平米
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="weightwayIpt"
						type="checkbox" />称重方式
					</td>
				</tr>
				<tr>
					<td><input id="labelIpt" type="checkbox" />标签名称</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="weightIpt"
						type="checkbox" />重量（kg）
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="patuIpt"
						type="checkbox" />纸管
					</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;<input id="remarkIpt"
						type="checkbox" />备注
					</td>
				</tr>
			</table>
		</form>
	</div>

	<div id="dlg-buttons4">
		<a href="javascript:saveSelectRows()" class="easyui-linkbutton"
			iconCls="icon-ok">确定</a> <a href="javascript:closeSelectRows()"
			class="easyui-linkbutton" iconCls="icon-cancel">关闭</a>
	</div>
</body>
</html>