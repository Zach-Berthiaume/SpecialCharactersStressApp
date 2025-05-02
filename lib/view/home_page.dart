import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:special_characters/model/theme.dart';

class Sticker {
  Offset position;
  double scale;
  double rotation;
  final String imagePath;

  Sticker({
    required this.position,
    required this.scale,
    required this.rotation,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'x': position.dx,
    'y': position.dy,
    'scale': scale,
    'rotation': rotation,
    'imagePath': imagePath,
  };

  static Sticker fromJson(Map<String, dynamic> json) => Sticker(
    position: Offset(json['x'], json['y']),
    scale: json['scale'],
    rotation: json['rotation'],
    imagePath: json['imagePath'],
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey _stackKey = GlobalKey();
  List<Sticker> _stickers = [];
  bool _isDraggingOverTrash = false;

  final List<String> stickerAssets = [
    'assets/images/crab.jpg',
    'assets/images/coconut.png',
    'assets/images/starfish.png',
    'assets/images/dolphin.png',
    'assets/images/pink_flower.png',
    'assets/images/purple_flower.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadStickers();
  }

  Future<void> _loadStickers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('stickers');
    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString);
      setState(() {
        _stickers = decoded.map((item) => Sticker.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveStickers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_stickers.map((s) => s.toJson()).toList());
    await prefs.setString('stickers', jsonString);
  }

  void _addSticker(Offset globalOffset, String asset) {
    final RenderBox box = _stackKey.currentContext!.findRenderObject() as RenderBox;
    final local = box.globalToLocal(globalOffset);
    setState(() {
      _stickers.add(Sticker(
        position: local,
        scale: 1.0,
        rotation: 0.0,
        imagePath: asset,
      ));
    });
    _saveStickers();
  }

  void _removeSticker(Sticker sticker) {
    setState(() {
      _stickers.remove(sticker);
      _isDraggingOverTrash = false;
    });
    _saveStickers();
  }

  void _updateSticker(Sticker sticker) {
    setState(() {});
    _saveStickers();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    String formattedTime = DateFormat('h:mm a').format(DateTime.now());
    List<String> timeParts = formattedTime.split(' ');

    return Scaffold(
      backgroundColor:
      isDarkMode ? const Color.fromARGB(255, 0, 30, 50) : const Color.fromARGB(255, 0, 160, 180),
      body: Stack(
        key: _stackKey,
        children: [
          DragTarget<String>(
            onMove: (_) {
              setState(() => _isDraggingOverTrash = false);
            },
            onAcceptWithDetails: (details) {
              _addSticker(details.offset, details.data);
            },
            builder: (context, _, __) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: isDarkMode
                        ? [
                      const Color.fromARGB(255, 0, 30, 50),
                      const Color.fromARGB(255, 0, 78, 102),
                      const Color.fromARGB(255, 0, 80, 110),
                      const Color.fromARGB(255, 0, 90, 120),
                      const Color.fromARGB(255, 21, 0, 73),
                    ]
                        : [
                      const Color.fromARGB(255, 0, 160, 180),
                      Colors.cyan,
                      const Color.fromARGB(255, 0, 200, 230),
                      const Color.fromARGB(255, 0, 220, 255),
                      const Color.fromARGB(255, 0, 235, 255),
                    ],
                    stops: const [0.0, 0.3, 0.4, 0.9, 1],
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/images/island.png'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          timeParts[0],
                          style: const TextStyle(
                              fontSize: 60, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Text(
                          timeParts[1],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Stickers
          ..._stickers.map((sticker) {
            return Positioned(
              left: sticker.position.dx,
              top: sticker.position.dy,
              child: GestureDetector(
                onScaleUpdate: (details) {
                  setState(() {
                    sticker.scale *= details.scale;
                    sticker.rotation += details.rotation;
                    _updateSticker(sticker);
                  });
                },
                child: Draggable<Sticker>(
                  data: sticker,
                  feedback: Transform.rotate(
                    angle: sticker.rotation,
                    child: Transform.scale(
                      scale: sticker.scale,
                      child: Image.asset(sticker.imagePath, width: 60),
                    ),
                  ),
                  onDragEnd: (details) {
                    final box = _stackKey.currentContext!.findRenderObject() as RenderBox;
                    final newPos = box.globalToLocal(details.offset);
                    sticker.position = newPos;

                    if (_isDraggingOverTrash) {
                      _removeSticker(sticker);
                    } else {
                      _updateSticker(sticker);
                    }
                  },
                  childWhenDragging: const SizedBox.shrink(),
                  child: Transform.rotate(
                    angle: sticker.rotation,
                    child: Transform.scale(
                      scale: sticker.scale,
                      child: Image.asset(sticker.imagePath, width: 60),
                    ),
                  ),
                ),
              ),
            );
          }),

          // Trash can
          Positioned(
            bottom: 150,
            right: 20,
            child: DragTarget<Sticker>(
              onMove: (_) {
                setState(() => _isDraggingOverTrash = true);
              },
              onLeave: (_) => setState(() => _isDraggingOverTrash = false),
              onAcceptWithDetails: (details) {
                _removeSticker(details.data);
              },
              builder: (context, _, __) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isDraggingOverTrash ? Colors.red : Colors.grey.shade800,
                  ),
                  child: const Icon(Icons.delete, color: Colors.white, size: 40),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDarkMode ? Colors.grey : Colors.black, width: 2),
            ),
            child: SizedBox(
              height: 110,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: stickerAssets.map((assetPath) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Draggable<String>(
                        data: assetPath,
                        feedback: Image.asset(assetPath, width: 60),
                        child: Image.asset(assetPath, width: 60),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
