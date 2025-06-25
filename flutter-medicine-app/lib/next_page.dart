// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';

class NextScreen extends StatefulWidget {
  late int data;
  NextScreen(this.data, {super.key});
  @override
  State<NextScreen> createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  final ScrollController _homeController = ScrollController();
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 136,
                  height: 174,
                  child: InkWell(
                      onTap:() {
                        Navigator.pop(context);
                      },
                      child: Image.asset('images/announce@3x.png')
                  )),
              const SizedBox(height: 12),
              const Text('해당 기능은 카카오톡',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              ),
              const Text('오픈 채팅을 통해 제공됩니다.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
      const SizedBox(
        width: 72,
        height: 72,
        child: FittedBox(
          child: FloatingActionButton(
            shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(999))
            ),
            onPressed: null,
            elevation: 0,
            backgroundColor: Color(0xFFFEC880),
            child: Image(image: AssetImage('images/home@3x.png')),
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
          currentIndex: widget.data,
          selectedItemColor: const Color(0xFFFEC880),
          onTap: (int index) {
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
              widget.data = index;
            });
          },
        ),
      ),
    );
  }
}
