# LEDMatrix for MATLAB and Arduino UNO R4 WiFi

A MATLAB add-on for controlling the built-in **12×8 LED matrix on the Arduino UNO R4 WiFi**.

LEDMatrix extends the MATLAB Support Package for Arduino Hardware to provide access to the LED matrix built into the Arduino UNO R4 WiFi. The add-on allows MATLAB users to display custom patterns, graphics, and other content directly on the 96-pixel LED matrix.

The project was developed primarily for classroom use, allowing students using MATLAB and Arduino UNO R4 WiFi boards to access the onboard LED matrix through MATLAB without needing to write a separate Arduino sketch.

## Features

- Control the built-in **8-row × 12-column LED matrix** from MATLAB
- Display custom 8×12 bitmap patterns
- Turn individual LEDs on and off
- Clear the display
- Create simple graphics and animations
- Create scrolling displays
- Use patterns based on output from the Arduino LED Matrix Editor
- Works with MATLAB's standard `arduino()` interface
- Designed for straightforward installation in teaching laboratories
- No separate Arduino sketch needs to be uploaded manually

## Hardware Requirements

- **Arduino UNO R4 WiFi**

This add-on is specifically designed for the LED matrix built into the UNO R4 WiFi.

The matrix contains 96 LEDs arranged as:

- 12 columns
- 8 rows

## Software Requirements

You will need:

- MATLAB
- MATLAB Support Package for Arduino Hardware
- A supported Arduino UNO R4 WiFi connection
- This LEDMatrix add-on

If MATLAB can already communicate with your Arduino using:

```matlab
a = arduino();
```

then the basic MATLAB-to-Arduino connection is working.

## Installation

Download or clone this repository.

```text
https://github.com/poweredbycoal/LEDMatrix
```

The LEDMatrix MATLAB and Arduino support files must be installed in the appropriate `+arduinoioaddons` package structure used by the MATLAB Support Package for Arduino Hardware.

The project includes the MATLAB-side add-on and the corresponding Arduino-side C++ implementation required by MATLAB.

If you are distributing this add-on to students, an installer can be used to place these files in the correct location automatically.

## Connecting to the Arduino

Connect the Arduino UNO R4 WiFi to the computer using USB.

In MATLAB, create the Arduino connection:

```matlab
a = arduino();
```

MATLAB will detect the connected board and COM port.

If the LEDMatrix library needs to be specified explicitly during initial programming, the connection can also be created using the library name:

```matlab
a = arduino("COM5", "UnoR4WiFi", ...
    Libraries="LEDMatrix/LEDMatrix");
```

Replace `"COM5"` with the COM port assigned to your Arduino.

After the Arduino has been programmed with the required MATLAB server firmware, subsequent connections may only require:

```matlab
a = arduino();
```

## Creating the LED Matrix Object

After connecting to the Arduino, create the LEDMatrix object:

```matlab
matrix = addon(a, "LEDMatrix/LEDMatrix");
```

You can then control the display using the methods provided by the LEDMatrix class.

## Your First Image

The matrix is represented in MATLAB as an **8×12 array**.

For example:

```matlab
frame = zeros(8,12);
```

Each element corresponds to one LED.

A value of:

```text
0 = LED off
1 = LED on
```

Set some LEDs:

```matlab
frame(3,4) = 1;
frame(3,5) = 1;
frame(3,6) = 1;
```

Then send the frame to the matrix:

```matlab
matrix.write(frame);
```

## Example: Simple Pattern

You can create graphics using normal MATLAB matrix operations.

```matlab
frame = zeros(8,12);

frame(2:7,3) = 1;
frame(2:7,10) = 1;
frame(4,3:10) = 1;

matrix.write(frame);
```

Because the display is represented as an MATLAB array, rows and columns can be manipulated using familiar MATLAB indexing.

## Example: Sad Face

For example, a simple face can be constructed directly as a matrix:

```matlab
frame = zeros(8,12);

% Eyes
frame(3,4) = 1;
frame(3,9) = 1;

% Mouth
frame(6,4) = 1;
frame(5,5) = 1;
frame(5,6) = 1;
frame(5,7) = 1;
frame(5,8) = 1;
frame(6,9) = 1;

matrix.write(frame);
```

Patterns like this can easily be modified by changing the corresponding matrix elements.

## Clearing the Display

Clear the LED matrix with:

```matlab
matrix.clear();
```

## Creating Animations

Animation can be created by repeatedly sending frames to the display.

For example:

```matlab
for col = 1:12

    frame = zeros(8,12);

    frame(4,col) = 1;

    matrix.write(frame);

    pause(0.1);

end
```

This moves a single illuminated LED across the display.

## Scrolling Graphics

A graphic wider than 12 pixels can be stored in a larger MATLAB matrix and displayed by moving a 12-column window across it.

For example:

```matlab
message = zeros(8,30);

% Add your image or text to message here.

for col = 1:(size(message,2)-11)

    frame = message(:,col:col+11);

    matrix.write(frame);

    pause(0.12);

end
```

This technique can be used to create scrolling text, symbols, logos, or animations.

## Example: Scrolling Small Text

Small fonts work particularly well on the 8×12 display.

For example, a 3×5 representation of the letter `B` can be defined as:

```matlab
B = [
    1 1 0
    1 0 1
    1 1 0
    1 0 1
    1 1 0
];
```

A message can then be assembled from character matrices with blank columns between letters.

For example:

```matlab
B = [
    1 1 0
    1 0 1
    1 1 0
    1 0 1
    1 1 0
];

N = [
    1 0 1
    1 1 1
    1 1 1
    1 0 1
    1 0 1
];

message = [
    zeros(5,12), ...
    B, zeros(5,1), ...
    B, zeros(5,1), ...
    N, ...
    zeros(5,12)
];

scrollFrame = zeros(8,size(message,2));

scrollFrame(2:6,:) = message;

for col = 1:(size(scrollFrame,2)-11)

    frame = scrollFrame(:,col:col+11);

    matrix.write(frame);

    pause(0.12);

end

matrix.clear();
```

This scrolls `BBN` across the display.

## Arduino LED Matrix Editor

Arduino provides an LED Matrix Editor that makes it convenient to design graphics for the UNO R4 WiFi's LED matrix.

Patterns produced with the editor can be converted into an 8×12 MATLAB representation and displayed using LEDMatrix.

Conceptually, a pattern such as:

```matlab
pattern = [
    0 0 0 1 1 0 0 1 1 0 0 0
    0 0 1 0 0 1 1 0 0 1 0 0
    0 0 1 0 0 0 0 0 0 1 0 0
    0 0 0 1 0 0 0 0 1 0 0 0
    0 0 0 0 1 0 0 1 0 0 0 0
    0 0 0 1 0 0 0 0 1 0 0 0
    0 0 1 0 0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 0 0 0 0 0
];

matrix.write(pattern);
```

can be displayed directly.

This makes it possible to design graphics visually and then use them from MATLAB.

## MATLAB Matrix Representation

One useful feature of the add-on is that the physical LED display is represented as a standard MATLAB matrix:

```text
       Column
       1  2  3  ...  12
Row 1
Row 2
Row 3
 .
 .
 .
Row 8
```

For example:

```matlab
frame(1,1) = 1;
```

controls the LED corresponding to row 1, column 1.

This representation makes the display particularly useful for teaching because normal MATLAB concepts such as:

- arrays
- matrix indexing
- loops
- logical operations
- image manipulation
- animation
- functions

can be demonstrated using physical hardware.

## Example Classroom Exercise

Students can create their own 8×12 image:

```matlab
frame = zeros(8,12);

% Student code goes here

matrix.write(frame);
```

More advanced exercises can involve:

- creating symbols
- creating letters
- designing a font
- scrolling text
- animation
- displaying sensor states
- visualizing data
- creating simple games
- converting images to binary matrices

The LED matrix therefore provides a simple way to connect MATLAB programming concepts with a physical output device.

## Project Structure

The add-on uses the MATLAB custom Arduino library architecture.

A typical installation contains:

```text
+arduinoioaddons
└── +LEDMatrix
    ├── LEDMatrix.m
    └── src
        └── LEDMatrix.h
```

`LEDMatrix.m` provides the MATLAB interface.

`LEDMatrix.h` contains the Arduino-side C++ implementation used by the MATLAB Arduino server.

The two components communicate through the MATLAB Support Package for Arduino Hardware custom library interface.

## Troubleshooting

### MATLAB cannot find LEDMatrix

Check that the add-on directory is installed in the correct `+arduinoioaddons/+LEDMatrix` structure.

You can check whether MATLAB can locate the class with:

```matlab
which arduinoioaddons.LEDMatrix.LEDMatrix -all
```

There should normally be only one active copy.

### MATLAB cannot connect to the Arduino

First verify that MATLAB can establish a normal Arduino connection:

```matlab
a = arduino();
```

If that fails, resolve the Arduino connection before troubleshooting LEDMatrix.

### Wrong COM port

Allow MATLAB to detect the Arduino automatically:

```matlab
a = arduino();
```

or inspect the Arduino connection after it has been created.

### Changes to the C++ file do not appear

MATLAB may already have Arduino server firmware compiled for the board.

When developing the add-on, forcing MATLAB to rebuild the Arduino firmware may be necessary after modifying the C++ portion of the library.

## Intended Use

This project was created primarily for **education and classroom use**.

The Arduino UNO R4 WiFi includes an excellent 12×8 LED matrix, but the matrix is not directly exposed through the normal high-level MATLAB Arduino interface. This project bridges that gap so students can control the display while remaining within MATLAB.

It is particularly useful for courses involving:

- engineering computing
- introductory programming
- MATLAB programming
- Arduino
- embedded systems
- sensors and instrumentation
- robotics
- automation

## Contributing

Bug reports, improvements, examples, and additional functionality are welcome.

If you discover an issue, please open an Issue in this GitHub repository.

Potential future improvements include:

- built-in character fonts
- text display functions
- automatic scrolling text
- additional animation functions
- Arduino LED Matrix Editor import
- brightness and animation controls where supported
- additional classroom examples

## License

This project is released under the **MIT License**.

See the [LICENSE](LICENSE) file for details.

## Author

**Steven J. Schafrik**

University of Kentucky  
Department of Mining Engineering

## Repository

GitHub:

https://github.com/poweredbycoal/LEDMatrix

## Acknowledgments

This project is built for use with:

- MATLAB
- MATLAB Support Package for Arduino Hardware
- Arduino UNO R4 WiFi

MATLAB is a product of Mathworks
Arduino and Arduino UNO R4 WiFi are trademarks of Arduino.

This project is independently developed and is not an official MathWorks or Arduino product.
