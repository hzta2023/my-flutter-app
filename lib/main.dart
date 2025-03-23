import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '位置测试',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LocationDisplayScreen(),
    );
  }
}

class LocationDisplayScreen extends StatefulWidget {
  @override
  _LocationDisplayScreenState createState() => _LocationDisplayScreenState();
}

class _LocationDisplayScreenState extends State<LocationDisplayScreen> {
  Position? _currentPosition;
  String _status = "未开始定位";

  // 检查并请求定位权限
  Future<bool> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _status = "请先开启设备定位服务");
      return false;
    }

    PermissionStatus status = await Permission.location.request();
    if (status.isDenied) {
      setState(() => _status = "定位权限被拒绝");
      return false;
    }
    return true;
  }

  // 获取实时位置
  void _getLocation() async {
    if (!await _checkPermissions()) return;

    setState(() => _status = "定位中...");
    
    Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 10, // 位置变化超过10米时更新
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _status = "定位成功";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('位置测试')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _getLocation,
              child: Text('开始实时定位'),
            ),
            SizedBox(height: 20),
            Text('状态: $_status', style: TextStyle(fontSize: 16)),
            Divider(),
            if (_currentPosition != null) ...[
              Text('纬度: ${_currentPosition!.latitude}'),
              Text('经度: ${_currentPosition!.longitude}'),
              Text('精度: ±${_currentPosition!.accuracy}米'),
              Text('时间: ${DateTime.fromMillisecondsSinceEpoch(
                _currentPosition!.timestamp!.millisecondsSinceEpoch
              )}'),
            ]
          ],
        ),
      ),
    );
  }
}