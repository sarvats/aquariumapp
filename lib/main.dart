import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'database_helper.dart'; 

void main() {
  runApp(AquariumApp());
}

class AquariumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aquarium App',
      theme: ThemeData.dark(),
      home: AquariumScreen(),
    );
  }
}

class Fish {
  Color color;
  double speed;
  double positionX;
  double positionY;
  double directionX;
  double directionY;

  Fish({
    required this.color,
    required this.speed,
    this.positionX = 0,
    this.positionY = 0,
    this.directionX = 1,
    this.directionY = 1,
  });
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Fish> fishList = [];
  Color selectedColor = Colors.yellow; // Default color for new fish
  double selectedSpeed = 1.0; // Default speed for new fish
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 50), vsync: this);
    _loadSettings();
    _startFishMovement();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _loadSettings() async {
    Map<String, dynamic>? settings = await DatabaseHelper().getSettings();
    if (settings != null) {
      setState(() {
        int fishCount = settings['fishCount'] ?? 0;
        selectedSpeed = settings['speed'] ?? 1.0;
        // Convert color back from integer to Color object
        selectedColor = Color(settings['color'] ?? Colors.yellow.value);
        for (int i = 0; i < fishCount; i++) {
          _addFish();
        }
      });
    }
  }

  void _startFishMovement() {
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        for (Fish fish in fishList) {
          // Update fish position based on speed and direction
          fish.positionX += fish.directionX * fish.speed;
          fish.positionY += fish.directionY * fish.speed;

          // Change direction if the fish hits the boundaries
          if (fish.positionX <= 0 || fish.positionX >= 280) {
            fish.directionX *= -1; // Reverse horizontal direction
          }
          if (fish.positionY <= 0 || fish.positionY >= 280) {
            fish.directionY *= -1; // Reverse vertical direction
          }
        }
      });
    });
  }

  void _addFish() {
    if (fishList.length < 10) { // Limit to 10 fish
      setState(() {
        // Generate random position for the fish within the aquarium
        double randomX = Random().nextDouble() * 280; // 280 to keep fish within the bounds
        double randomY = Random().nextDouble() * 280; // 280 to keep fish within the bounds
        
        fishList.add(Fish(color: selectedColor, speed: selectedSpeed, positionX: randomX, positionY: randomY));
      });
    }
  }

  void _saveSettings() async {
    // Save color as an integer (Color.value)
    await DatabaseHelper().insertSettings(fishList.length, selectedSpeed, selectedColor.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aquarium')),
      body: Center(
        child: Column(
          children: [
            Container(
              width: 300,
              height: 300,
              color: Colors.blue[900], // Aquarium background
              child: Stack(
                children: fishList.map((fish) {
                  return Positioned(
                    left: fish.positionX,
                    top: fish.positionY,
                    child: Container(
                      width: 20, // Fish width
                      height: 20, // Fish height
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: fish.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _addFish,
              child: Text('Add Fish'),
            ),
            // Slider for fish speed
            Text('Speed: ${selectedSpeed.toStringAsFixed(2)}'),
            Slider(
              value: selectedSpeed,
              min: 0.5,
              max: 5.0,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  selectedSpeed = value;
                });
              },
            ),
            // Dropdown for fish color
            DropdownButton<Color>(
              value: selectedColor,
              items: [
                DropdownMenuItem(value: Colors.yellow, child: Text('Yellow')),
                DropdownMenuItem(value: Colors.red, child: Text('Red')),
                DropdownMenuItem(value: Colors.green, child: Text('Green')),
                DropdownMenuItem(value: Colors.blue, child: Text('Blue')),
              ],
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    selectedColor = value;
                  }
                });
              },
            ),

            ElevatedButton(
              onPressed: _saveSettings,
              child: Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
