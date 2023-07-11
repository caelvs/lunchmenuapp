import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'BMDOHYEON', // 폰트 패밀리 이름
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _counter = 0; // Counter variable

  List<List<String>> gridData = List.generate(8, (row) {
    if (row == 0) {
      return ['월', '화', '수', '목', '금'];
    } else {
      return List.generate(5, (col) => '');
    }
  });

  late String apiUrl; // Declare apiUrl as a late variable

  List<String> dishes = [];

  late String apiUrl2;

  List<String> dishes2 = [];

  @override

  void initState() {
    super.initState();
    loadTimetableData();
    apiUrl =
        'https://open.neis.go.kr/hub/mealServiceDietInfo?KEY=4001c07dd9b44c7aa9b0d04f30f2d131&Type=json&pIndex=1&pSize=10&ATPT_OFCDC_SC_CODE=J10&SD_SCHUL_CODE=7530071&MLSV_YMD=' + getToday(); // Assign apiUrl inside initState
    fetchData();
    apiUrl2 =
        'https://open.neis.go.kr/hub/mealServiceDietInfo?KEY=4001c07dd9b44c7aa9b0d04f30f2d131&Type=json&pIndex=1&pSize=10&ATPT_OFCDC_SC_CODE=J10&SD_SCHUL_CODE=7530071&MLSV_YMD=' + getTomorrow(); // Assign apiUrl inside initState
    fetchData2();
  }

  void loadTimetableData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? savedData = prefs.getStringList('timetable_data');
      if (savedData != null) {
        final List<List<String>> loadedData =
        savedData.map((row) => row.split(',')).toList();
        setState(() {
          gridData = loadedData;
        });
      }
    } catch (e) {
      print('Error loading timetable data: $e');
    }
  }

  void saveTimetableData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> dataToSave = gridData.map((row) => row.join(','))
          .toList();
      await prefs.setStringList('timetable_data', dataToSave);
    } catch (e) {
      print('Error saving timetable data: $e');
    }
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['mealServiceDietInfo'][1]['row'];

      for (var meal in meals) {
        final dishName = meal['DDISH_NM'];
        dishes.add(dishName);
      }

      setState(() {});
    } else {
      throw Exception('데이터를 가져오는 데 실패하였습니다.');
    }
  }

  Future<void> fetchData2() async {
    final response = await http.get(Uri.parse(apiUrl2));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['mealServiceDietInfo'][1]['row'];

      for (var meal in meals) {
        final dishName = meal['DDISH_NM'];
        dishes2.add(dishName);
      }

      setState(() {});
    } else {
      throw Exception('데이터를 가져오는 데 실패하였습니다.');
    }
  }


  String replaceBrTags(String input) {
    return input.replaceAll('<br/>', '\n\n');
  }


  String getToday() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyyMMdd');
    var strToday = formatter.format(now);
    return strToday;
  }

  String getTomorrow() {
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(Duration(days: 1));
    DateFormat formatter = DateFormat('yyyyMMdd');
    var strTomorrow = formatter.format(tomorrow);
    return strTomorrow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '학. 위. 앱',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: _currentIndex == 0
          ? buildTimeTable()
          : (_currentIndex == 3
          ? (_counter > 3
          ? buildGifImage()
          : buildSettings())
          : (_currentIndex == 1
          ? buildFoodInformation()
          : buildFoodInformation2())),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 30),
        unselectedLabelStyle: TextStyle(fontSize: 25),
        selectedItemColor: Colors.blue, // 선택된 요소 색
        unselectedItemColor: Colors.black, // 선택되지 않은 요소 색
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/CATDANCING.gif', width: 225, height: 75),
            label: '시간표',
          ),
          BottomNavigationBarItem(
            icon:
            Image.asset(
                'assets/MEXICANCATDANCING.gif', width: 225, height: 75),
            label: '오.급',
          ),
          BottomNavigationBarItem(
            icon:
            Image.asset(
                'assets/MEXICANCATDANCINGCP.gif', width: 225, height: 75),
            label: '낼.급',
          ),
          BottomNavigationBarItem(
            icon:
            Image.asset(
                'assets/CATDANCINGCP.gif', width: 225, height: 75),
            label: '인내',
          ),
        ],
      ),
    );
  }

  Widget buildFoodInformation() {
    if (dishes.isNotEmpty) {
      return ListView.builder(
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(bottom: 150, top: 100, left : 0, right: 0 ),
            child: Text(
              replaceBrTags(dishes[index]),
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text(
            '저런,,,  오늘은 급식이 없군요? \n\n 알아서 먹어야겠죠? 멍청이들아?',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center
        ),
      );
    }
  }

  Widget buildFoodInformation2() {
    if (dishes2.isNotEmpty) {
      return ListView.builder(
        itemCount: dishes2.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(bottom: 150, top: 100, left: 0, right: 0),
            child: Text(
              replaceBrTags(dishes2[index]),
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text(
          '내일은 휴일인데 설마 급식이 궁금한건가요? \n\n 정말 파렴치하고 탐욕스럽시군요?',
          style: TextStyle(fontSize: 30),
        ),
      );
    }
  }

  Widget buildGifImage() {
    return _currentIndex == 3
        ? Center(
      child: Image.asset('assets/BOD(GIF).gif'),
    )
        : SizedBox();
  }

  Widget buildTimeTable() {
    return _currentIndex == 0
        ? Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Calculate the maximum allowed font size based on the available space
                double maxFontSize = constraints.maxWidth / 30;

                return GridView.builder(
                  itemCount: gridData.length * gridData[0].length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 2,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    int row = index ~/ 5;
                    int col = index % 5;
                    String cellText = gridData[row][col];

                    Color cellColor = row == 0 ? Colors.blue : Colors.white;

                    return GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        if (row != 0) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String newValue = '';
                              return AlertDialog(
                                title: Text('과목 입력'),
                                content: TextField(
                                  onChanged: (value) {
                                    newValue = value;
                                  },
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('저장'),
                                    onPressed: () {
                                      setState(() {
                                        gridData[row][col] = newValue;
                                      });
                                      saveTimetableData();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('취소'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Container(
                        color: cellColor,
                        margin: EdgeInsets.all(4.0),
                        child: Center(
                          child: Text(
                            cellText,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: maxFontSize,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey[300],
          child: Text(
            'bch.schm.co.kr | bch-h.goebc.kr',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    )
        : SizedBox();
  }

  Widget buildSettings() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_currentIndex == 3) // Show the button only on the second screen
            Text(
              '3번의 기회',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          if (_currentIndex == 3) // Show the button only on the second screen
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _counter++;
                });
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Set the background color
                minimumSize: Size(200, 60), // Set the minimum width and height
                padding: EdgeInsets.all(16), // Set the padding
              ),
              child: Text(
                '忍',
                style: TextStyle(
                    fontSize: 40,
                    fontFamily: 'CustomFont'
                ),
              ),
            ),
        ],
      ),
    );
  }
}