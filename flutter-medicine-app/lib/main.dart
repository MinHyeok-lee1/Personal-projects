// ignore_for_file: depend_on_referenced_packages, unrelated_type_equality_checks
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'next_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 초기화 보장
  await Future.delayed(const Duration(seconds: 1)); // 1초 지연
  await initializeDateFormatting();
  runApp(const MyApp());
}

class TableCalendarScreen extends StatelessWidget {
  const TableCalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: TableCalendar(
        firstDay: DateTime.utc(2021, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: DateTime.now(),
      ),
    );
  }
}

class Event {
  String title;

  Event(this.title);
  @override
  String toString() => title;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 디버그 표시를 없앤다.
      debugShowCheckedModeBanner: false,
      title: 'Emotions_Calendar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home:  const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // const MyHomePage({super.key});
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DateTime _now = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).toUtc().add(const Duration(hours: 9));

  DateTime _selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).toUtc().add(const Duration(hours: 9));
  late final ValueNotifier<List<Event>> _selectedEvents;

  int _selectedIndex = 0;
  final ScrollController _homeController = ScrollController();
  late Map<DateTime, List<Event>> events = {};
  late Map<String, dynamic> savedData = {};

  @override
  void initState() {
    super.initState();
    events = {};
    prefsData();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    // _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }


  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  prefsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getString("data") ?? 'NoneData';

    if(result != "NoneData") {
      var dataMap = jsonDecode(result);
      savedData = dataMap;
      dataMap.forEach((key, value) {
        events = events..addAll({
          DateTime.parse(key) : [Event(value)],
        });
      });
    }
    setState(() {});
  }

  void _saveData(String color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    events = events..addAll({
      _selectedDay : [Event(color)],
    });
    savedData = savedData..addAll({
      _selectedDay.toString() : color,
    });
    prefs.setString("data", (jsonEncode(savedData)));
  }

  void _deleteData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("data");
    events = {};
    savedData = {};
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }


  void showModal(BuildContext context) {
    if(_now.microsecondsSinceEpoch < _selectedDay.microsecondsSinceEpoch) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
            width: 360,
            height:160, // 모달 높이 크기
            margin: const EdgeInsets.only(
              left: 25,
              right: 25,
              bottom: 180,
            ), // 모달 좌우하단 여백 크기
            padding: const EdgeInsets.only(
              left: 25,
              right: 25,
            ), // 모달 좌우하단 여백 크기
            decoration: const BoxDecoration(
              color: Colors.white, // 모달 배경색
              borderRadius: BorderRadius.all(
                Radius.circular(20), // 모달 전체 라운딩 처리
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  _now.microsecondsSinceEpoch == _selectedDay.microsecondsSinceEpoch ?
                  '${DateFormat('M월 d일').format(_selectedDay)}, 오늘의 감정은 어떠신가요?'
                      : '${DateFormat('M월 d일').format(_selectedDay)}, 그때의 감정은 어떠셨나요?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Divider(
                  thickness: 0.4,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                    [
                      Column(
                          children: [
                            SizedBox(width: 26,
                                height: 50,
                                child: InkWell(
                                    onTap:() {
                                      _saveData('yellow');
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: Image.asset('images/yellow@3x.png')
                                )),
                            const SizedBox(height: 4),
                            const Text('최고에요',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)
                            ),
                          ]),
                      Column(
                          children: [
                            SizedBox(width: 26,
                                height: 50,
                                child: InkWell(
                                    onTap:() {
                                      _saveData('orange');
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: Image.asset('images/orange@3x.png')
                                )),
                            const SizedBox(height: 4),
                            const Text('좋아요',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                          ]),
                      Column(
                          children: [
                            SizedBox(width: 26,
                                height: 50,
                                child: InkWell(
                                    onTap:() {
                                      _saveData('green');
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: Image.asset('images/green@3x.png')
                                )),
                            const SizedBox(height: 4),
                            const Text('괜찮아요',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                          ]),
                      Column(
                          children: [
                            SizedBox(width: 26,
                                height: 50,
                                child: InkWell(
                                    onTap:() {
                                      _saveData('blue');
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: Image.asset('images/blue@3x.png')
                                )),
                            const SizedBox(height: 4),
                            const Text('별로에요',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                          ]),
                      Column(
                          children: [
                            SizedBox(width: 26,
                                height: 50,
                                child: InkWell(
                                    onTap:() {
                                      _saveData('gray');
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child:  Image.asset('images/gray@3x.png')
                                )),
                            const SizedBox(height: 4),
                            const Text('나빠요',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                          ]),
                    ]),
              ],
            )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        toolbarHeight: 80,
        centerTitle: false,
        backgroundColor: Colors.white,
        title:  Transform(
          transform:  Matrix4.translationValues(-12.0, -2.0, 0.0),
          child: const Text(
            "기록",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        leading:
            const IconButton(
               icon: ImageIcon(
                   AssetImage("images/clock@3x.png"),
                   color: Color(0xFFFEC880)
               ),
              iconSize: 24,
              onPressed: null,
             // onPressed: () async {
             //   _deleteData();
             //   setState(() {});
             // },
          ),
      ),
      body: SafeArea(
          top: true,
          bottom: true,
          right: true,
          left: true,
          maintainBottomViewPadding: true,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),
                Expanded(child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TableCalendar(
                    locale: 'ko_KR',
                    daysOfWeekHeight: 30,
                    firstDay: DateTime.utc(2021, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _selectedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    eventLoader: _getEventsForDay,
                    calendarBuilders: CalendarBuilders(
                      singleMarkerBuilder: (context, date, event) {
                        return Container(
                          decoration:
                          events[date]?[0].title  == "yellow" ?
                          const BoxDecoration(
                            image: DecorationImage(image: AssetImage('images/record_ye@3x.png')),
                          ) :
                          events[date]?[0].title  == "orange" ?
                          const BoxDecoration(
                            image: DecorationImage(image: AssetImage('images/record_or@3x.png')),
                          ) :
                          events[date]?[0].title == "green" ?
                          const BoxDecoration(
                            image: DecorationImage(image: AssetImage('images/record_gre@2x.png')),
                          ) :
                          events[date]?[0].title  == "blue" ?
                          const BoxDecoration(
                            image: DecorationImage(image: AssetImage('images/record_bl@2x.png')),
                          ) :
                          const BoxDecoration(
                            image: DecorationImage(image: AssetImage('images/record_gray@2x.png')),
                          ),
                          width: 28.0,
                          height: 28.0,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                        );
                      },
                    ),


                    // headerStyle
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      titleTextFormatter: (date, locale) =>
                      // DateFormat.yMMMMd(locale).format(date),
                      DateFormat.yMMMM(locale).format(date),
                      formatButtonVisible: false,
                      titleTextStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      headerPadding: const EdgeInsets.symmetric(vertical: 4.0),
                      leftChevronIcon: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        size: 24.0,
                      ),
                      rightChevronIcon: const Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 24.0,
                      ),
                    ),

                    // calendarStyle
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      // outsideDay 노출 여부
                      outsideDaysVisible : false,
                      // marker 위치 조정
                      markersAlignment : Alignment.center,
                      // marker 크기 조절
                      markerSize : 40.0,
                      // marker 크기 비율 조절
                      markerSizeScale : 40.0,
                      // marker 의 기준점 조정
                      markersAnchor : 1,
                      // marker margin 조절
                      markerMargin : const EdgeInsets.symmetric(horizontal: 0.3),
                      // 한줄에 표시 marker 갯수
                      markersMaxCount : 1,
                      markersOffset : const PositionedOffset(),
                      // marker 모양 조정
                      // markerDecoration : const BoxDecoration(
                      //   image: DecorationImage(image: AssetImage('images/record_ye.png')),
                      // ),

                      // today 표시 여부
                      isTodayHighlighted : false,
                      // today 글자 조정
                      todayTextStyle : const TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 16.0,
                      ),

                      // today 모양 조정
                      todayDecoration : BoxDecoration(
                        // color: const Color(0xffFF0000),
                        color: const Color(0xFFFFF2E0),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFEC880),
                            width: 4
                        ),
                      ),

                      // selectedDecoration
                      selectedTextStyle: const TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 16.0,
                      ),
                      selectedDecoration: BoxDecoration(
                        // color: const Color(0xffFF0000),
                        color: const Color(0xFFFFF2E0),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFEC880),
                            width: 4
                        ),
                      ),
                    ),
                  ),
                ))
              ],
            ),
          )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
      SizedBox(
        width: 72,
        height: 72,
        child: FittedBox(
          child: FloatingActionButton(
            shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(999))
            ),
            onPressed: () {
              showModal(context);
            },
            elevation: 0,
            backgroundColor: const Color(0xFFFEC880),
            child: const Image(image: AssetImage('images/home@3x.png')),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 90,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("images/clock@3x.png"),
                size: 24,
              ),
              label: '복약 알람',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("images/check@3x.png"),
                size: 24,
              ),
              label: '섭취 정보',
            ),
          ],
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.grey[600],
          selectedItemColor: Colors.grey[600],
          onTap: (int index) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NextScreen(_selectedIndex))
            );
            switch (index) {
              case 0:
                if (_selectedIndex == index) {
                  _homeController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                }
                break;
              case 1:
                if (_selectedIndex == index) {
                  _homeController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                }
                break;
            }
            setState(() {
              _selectedIndex = index;
              });
          },
        ),
      ),
    );
  }
}