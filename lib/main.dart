import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CodeInputScreen(),
      ),
    );
  }
}

class CodeInputScreen extends StatefulWidget {
  @override
  _CodeInputScreenState createState() => _CodeInputScreenState();
}

class _CodeInputScreenState extends State<CodeInputScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isValid = false;
  bool _isError = false;
  int _dotCount = 0;
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestSmsPermission();
  }

  Future<void> _requestSmsPermission() async {
    final status = await Permission.sms.request();
    setState(() {
      _isPermissionGranted = status.isGranted;
    });
  }

  void _checkCode() {
    final code = _controller.text;
    if (code.length == 9 && RegExp(r'^\d+$').hasMatch(code)) {
      setState(() {
        _isValid = true;
        _isError = false;
      });
      _startLoadingAnimation();
    } else {
      setState(() {
        _isValid = false;
        _isError = true;
      });
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _isError = false;
          _controller.clear();
        });
      });
    }
  }

  void _startLoadingAnimation() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (_isValid) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
        _startLoadingAnimation();
      }
    });
  }

  void _reset() {
    setState(() {
      _isValid = false;
      _isError = false;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPermissionGranted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Для работы приложения необходимо разрешение на чтение SMS.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestSmsPermission,
              child: Text('Запросить разрешение'),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      color: Colors.white, // Фон всегда белый
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!_isValid)
                Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Код реквизита',
                        errorText: _isError ? 'Пожалуйста, введите корректные реквизиты' : null,
                        counterText: '', // Скрываем счетчик символов
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 9, // Ограничение на 9 символов, но счетчик скрыт
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted: (_) => _checkCode(),
                    ),
                    SizedBox(height: 16),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      child: ElevatedButton(
                        onPressed: _checkCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isError ? Colors.red : Colors.blue, // Цвет кнопки
                        ),
                        child: Text('Подключить'),
                      ),
                    ),
                  ],
                ),
              if (_isValid)
                Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 100),
                    SizedBox(height: 16),
                    Text(
                      'working${'.' * _dotCount}',
                      style: TextStyle(fontSize: 24, color: Colors.green),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reset,
                      child: Text('Отключить'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
