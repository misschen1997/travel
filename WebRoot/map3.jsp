<%@page import="cn.edu.ldu.util.Dbutil"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<style type="text/css">
body, html, #allmap {
	width: 80%;
	height: 80%;
	overflow: hidden;
	margin: 0;
	font-family: "微软雅黑";
}
</style>
<script type="text/javascript"
	src="http://api.map.baidu.com/api?v=2.0&ak=V6RjjChFXrifV2z41z0sYQEO"></script>
<title>设置驾车路线途经点</title>
</head>
<body style="background-size:100% 100%; background-repeat;">
	<div id="allmap"></div>
	输入起点:
	<input type="text"
		value=<%=(String) application.getAttribute("qidian")%> id="first">
	<br> 输入终点：
	<input type="text"
		value=<%=(String) application.getAttribute("zhongdian")%> id="second">
	<%-- <input type="text"
		value=<%=(String) application.getAttribute("disan")%> id="disan"> --%>
	<br>

	<p>
		<input type='button' value='开始' onclick='searchByStationName();' />
	</p>
	<div style="width:820px;height:500px;border:1px solid gray"
		id="container"></div>
</body>
<script type="text/javascript">
	window.onload = function() {
		searchByStationName();
	}
</script>

<script type="text/javascript">

	/*
	 *城市转化为坐标
	 */
		var myP1 = new BMap.Point(0, 0); //起点-重庆
		var myP2 = new BMap.Point(0, 0); //终点-西安
		var myP3 = new BMap.Point(0, 0); //终点-西安
		var myP4 = new BMap.Point(0, 0); //终点-西安
		var myP5 = new BMap.Point(0, 0); //终点-西安




	// 百度地图API功能
	var map = new BMap.Map("allmap");
	map.centerAndZoom(new BMap.Point(121.443532, 31.24603), 5);
	map.enableScrollWheelZoom(true);


	function showPoly(pointList) {

		//循环显示点对象
		for (c = 0; c < pointList.length; c++) {
			var marker = new BMap.Marker(pointList[c]);
			map.addOverlay(marker);
			//将途经点按顺序添加到地图上
			var label = new BMap.Label(c + 1, {
				offset : new BMap.Size(20, -10)
			});
			marker.setLabel(label);
		}

		var group = Math.floor(pointList.length / 11);
		var mode = pointList.length % 11;

		var driving = new BMap.DrivingRoute(map, {
			onSearchComplete : function(results) {
				if (driving.getStatus() == BMAP_STATUS_SUCCESS) {
					var plan = driving.getResults().getPlan(0);
					var num = plan.getNumRoutes();
					alert("plan.num ：" + num);
					for (var j = 0; j < num; j++) {
						var pts = plan.getRoute(j).getPath(); //通过驾车实例，获得一系列点的数组
						var polyline = new BMap.Polyline(pts);
						map.addOverlay(polyline);
					}
				}
			}
		});
		for (var i = 0; i < group; i++) {
			var waypoints = pointList.slice(i * 11 + 1, (i + 1) * 11);
			//注意这里的终点如果是11的倍数的时候，数组可是取不到最后一位的，所以要注意终点-1喔。感谢song141的提醒，怪我太粗心大意了~
			driving.search(pointList[i * 11], pointList[(i + 1) * 11 - 1], {
				waypoints : waypoints
			}); //waypoints表示途经点
		}
		if (mode != 0) {
			var waypoints = pointList.slice(group * 11, pointList.length - 1); //多出的一段单独进行search
			driving.search(pointList[group * 11], pointList[pointList.length - 1], {
				waypoints : waypoints
			});
		}

	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	function searchByStationName() {
	
		

	
		var myGeo = new BMap.Geocoder();
		var first = document.getElementById("first").value;
		var second = document.getElementById("second").value;
	/* 	var disan = document.getElementById("disan").value;
		var disi = document.getElementById("disi").value;
		var diwu = document.getElementById("diwu").value; */
		
		myGeo.getPoint(first, function(point) {
			if (point) {
				myP1 = new BMap.Point(point.lng, point.lat);

			}
		});
		myGeo.getPoint(second, function(point) {
			if (point) {
				myP2 = new BMap.Point(point.lng, point.lat);

			}

		});
	/* 	myP3 = myP4 = myP5 = myP1;
		myGeo.getPoint(disan, function(point) {
			if (point) {
				myP3 = new BMap.Point(point.lng, point.lat);

			}

		});
		myGeo.getPoint(disi, function(point) {
			if (point) {
				myP4 = new BMap.Point(point.lng, point.lat);

			}

		});
		myGeo.getPoint(diwu, function(point) {
			if (point) {
				myP5 = new BMap.Point(point.lng, point.lat);

			}

		}); */
		var driving = new BMap.DrivingRoute(map); //创建驾车实例
		driving.search(myP1, myP2); //第一个驾车搜索
		driving.setSearchCompleteCallback(function() {
			var pts = driving.getResults().getPlan(0).getRoute(0).getPath(); //通过驾车实例，获得一系列点的数组

			var polyline = new BMap.Polyline(pts);
			map.addOverlay(polyline);

			var m1 = new BMap.Marker(myP1);
			var m2 = new BMap.Marker(myP2);
			
			map.addOverlay(m1);
			map.addOverlay(m2);
			
			var lab1 = new BMap.Label("起点", {
				position : myP1
			}); //创建3个label
			var lab2 = new BMap.Label("终点", {
				position : myP2
			});
		
			map.addOverlay(lab1);
			map.addOverlay(lab2);
						
						
			/* 
			var m3 = new BMap.Marker(myP3);
			map.addOverlay(m3);
			var lab3 = new BMap.Label("途径地点", {
				position : myP3
			});
			map.addOverlay(lab3); */

			setTimeout(function() {
				map.setViewport([ myP1, myP2]); //调整到最佳视野
			}, 1000);

		});
		var p1 = new BMap.Point(121.493262, 31.207015);
		var p2 = new BMap.Point(121.493262, 31.207015);
		var p3 = new BMap.Point(117, 36.6);
		var p4 = new BMap.Point(121.494987, 36.230099);
		var p5 = new BMap.Point(121.489382, 36.225034);
		var p6 = new BMap.Point(121.512953, 36.219846);
		var p7 = new BMap.Point(121.510222, 31.228122);
		var p8 = new BMap.Point(121.520715, 31.232198);
		var p9 = new BMap.Point(121.515828, 31.239485);
		var p10 = new BMap.Point(121.498724, 31.238868);
		var p11 = new BMap.Point(121.496568, 31.227505);
		var p12 = new BMap.Point(121.479177, 31.244178);
		var p13 = new BMap.Point(121.496712, 31.249365);
		var p14 = new BMap.Point(121.503323, 31.260972);
		var p15 = new BMap.Point(121.512953, 31.276158);
		var p16 = new BMap.Point(121.481764, 31.26838);
		var p17 = new BMap.Point(121.464804, 31.285293);
		var p18 = new BMap.Point(121.468685, 31.251587);
		var p19 = new BMap.Point(121.47041, 31.245289);
		var p20 = new BMap.Point(121.489094, 31.19106);
		var p21 = new BMap.Point(121.514534, 31.207987);
		var p22 = new BMap.Point(121.525314, 31.178208);
		var p23 = new BMap.Point(121.533363, 31.159422);
		var p24 = new BMap.Point(121.533363, 31.159422);
		var p25 = new BMap.Point(121.545005, 31.203169);
		var p26 = new BMap.Point(121.562252, 31.186364);
		var p27 = new BMap.Point(121.569295, 31.170422);
		var p28 = new BMap.Point(121.575907, 31.15559);

		var arrayList = [];
		arrayList.push(myP1);arrayList.push(p2);arrayList.push(p3);arrayList.push(p4);arrayList.push(p5);arrayList.push(p6);arrayList.push(p7);arrayList.push(p8);
		arrayList.push(p9);arrayList.push(p10);arrayList.push(p11);arrayList.push(p12);arrayList.push(p13);arrayList.push(p14);arrayList.push(p15);
		arrayList.push(p16);arrayList.push(p17);arrayList.push(p18);arrayList.push(p19);arrayList.push(p20);arrayList.push(p21);arrayList.push(p22);
		arrayList.push(p23);arrayList.push(p24);arrayList.push(p25);arrayList.push(p26);arrayList.push(p27);arrayList.push(myP2);

		showPoly(arrayList);

	}

	//显示轨迹
</script>