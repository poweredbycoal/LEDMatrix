# LEDMatrix MATLAB Add-On for Arduino UNO R4 WiFi

A MATLAB add-on for controlling the built-in 12 × 8 LED matrix on the Arduino UNO R4 WiFi using the MATLAB Support Package for Arduino Hardware.

The MATLAB Arduino support package supports the UNO R4 WiFi, but it does not directly expose the board's built-in LED matrix. This project adds that functionality through a custom MATLAB Arduino library.

## Features

The add-on allows MATLAB users to:

* Turn individual LEDs on and off
* Display an 8 × 12 MATLAB array on the matrix
* Clear the display
* Fill the entire display
* Draw rows and columns
* Invert a displayed image
* Shift images left, right, up, and down
* Create scrolling displays and simple animations
* Convert output from the Arduino LED Matrix Editor for use in MATLAB

The interface is intended to be simple enough for classroom use while still giving students direct access to the LED matrix as a MATLAB array.

## Requirements

* Arduino UNO R4 WiFi
* MATLAB
* MATLAB Support Package for Arduino Hardware
* USB connection to the Arduino

## Repository Structure

The MATLAB custom library uses the following directory structure:

```text
+arduinoioaddons
└── +LEDMatrix
    ├── LEDMatrix.m
    └── src
        └── LEDMatrix.h
```

`LEDMatrix.m` provides the MATLAB interface.

`LEDMatrix.h` contains the C++ code that runs as part of the MATLAB Arduino server firmware on the UNO R4 WiFi.

## Installation

Clone or download this repository and add the directory containing `+arduinoioaddons` to your MATLAB path.

For example:

```matlab
addpath("C:\Users\YourName\Documents\MATLAB")
```

Confirm that MATLAB can see the library:

```matlab
listArduinoLibraries
```

You should see:

```text
LEDMatrix/LEDMatrix
```

## Programming the Arduino

The first time the library is used, the UNO R4 WiFi must be programmed with firmware containing the LEDMatrix add-on.

Replace `COM5` with the port used by your Arduino:

```matlab
a = arduino("COM5","UnoR4WiFi", ...
    Libraries="LEDMatrix/LEDMatrix", ...
    ForceBuildOn=true);
```

Create the LED matrix object:

```matlab
matrix = addon(a,"LEDMatrix/LEDMatrix");
```

Once the appropriate firmware has been programmed onto the Arduino, subsequent MATLAB sessions can normally reconnect without rebuilding the firmware:

```matlab
a = arduino();
matrix = addon(a,"LEDMatrix/LEDMatrix");
```

## Quick Start

### Clear the Matrix

```matlab
matrix.clear();
```

### Turn On All LEDs

```matlab
matrix.fill();
```

### Turn On a Single Pixel

Rows are numbered 1 through 8 and columns 1 through 12.

```matlab
matrix.setPixel(4,6,true);
```

Turn it back off:

```matlab
matrix.setPixel(4,6,false);
```

### Display an Image

Images are represented in MATLAB as an 8 × 12 matrix.

For example, this displays a simple face:

```matlab
frame = [
    0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0
    0 0 1 0 0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 1 0 0 0 0 1 0 0 0
    0 0 0 0 1 1 1 1 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0
];

matrix.write(frame);
```

A `1` turns the corresponding LED on and a `0` turns it off. This makes it straightforward to create patterns using normal MATLAB matrix operations.

### Scrolling Text and Images

The matrix can also be used for simple animations.

For example, a larger image can be moved through the 12-column display:

```matlab
while true
    frame = [frame(:,2:end) frame(:,1)];
    matrix.write(frame);
    pause(0.15);
end
```

Press `Ctrl+C` to stop the loop.

The add-on also includes methods for shifting the current image:

```matlab
matrix.shiftLeft();
matrix.shiftRight();
matrix.shiftUp();
matrix.shiftDown();
```

### Arduino LED Matrix Editor

Arduino provides an LED Matrix Editor that can be used to draw patterns visually.

The editor's compact frame representation uses three 32-bit values to represent the 96 LEDs. A MATLAB conversion function can be used to convert the editor's exported frame into the 8 × 12 representation expected by this add-on.

For example:

```matlab
code = """
0x3184a444,
0x42081100,
0xa0040000
""";

frame = arduinoMatrixConvert(code);
matrix.write(frame);
```

This provides an easy workflow for students who would rather draw their image than construct it manually as a MATLAB array.

## How It Works

The project consists of two parts.

### MATLAB Side

`LEDMatrix.m` inherits from MATLAB's Arduino custom library framework and provides user-facing commands such as:

```matlab
matrix.write(frame);
matrix.setPixel(row,column,state);
matrix.clear();
matrix.fill();
```

MATLAB converts these operations into commands and sends them to the UNO R4 WiFi.

### Arduino Side

`LEDMatrix.h` receives those commands on the Arduino and interfaces with the UNO R4 WiFi's built-in matrix through:

```cpp
#include <Arduino_LED_Matrix.h>
```

The MATLAB and Arduino portions communicate using command identifiers defined by both sides of the library.

For a complete frame, MATLAB sends 96 pixel values corresponding to the 8 rows and 12 columns of the display.

## Classroom Use

This project was developed primarily for using the Arduino UNO R4 WiFi in courses that teach MATLAB and embedded computing.

Representing the physical LED display as an ordinary MATLAB matrix provides a useful introduction to:

* Arrays and matrices
* Matrix indexing
* Logical values
* Loops
* Functions
* Image representation
* Data serialization
* MATLAB-to-microcontroller communication
* Simple animation
* Embedded programming

Students can begin with operations as simple as:

```matlab
frame(4,6) = 1;
```

and immediately see the corresponding change on physical hardware.

## Contributing

Bug reports, improvements, examples, and additional functionality are welcome.

Potential future enhancements include:

* Built-in 3 × 5 character font
* Text display
* Scrolling text
* Animation playback
* Additional Arduino LED Matrix Editor compatibility
* Example MATLAB Live Scripts for classroom exercises

## License

Copyright (c) 2026 Steven J. Schafrik

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for the full license text.

## Acknowledgments

This project uses the `Arduino_LED_Matrix` functionality provided for the Arduino UNO R4 WiFi and MATLAB's custom Arduino library framework.