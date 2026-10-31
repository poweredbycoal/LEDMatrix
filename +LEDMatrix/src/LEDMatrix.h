#ifndef LEDMATRIX_H
#define LEDMATRIX_H

#include "LibraryBase.h"
#include <Arduino_LED_Matrix.h>
#include <string.h>

class LEDMatrix : public LibraryBase
{
public:

    LEDMatrix(MWArduinoClass& a)
    {
        libName = "LEDMatrix/LEDMatrix";
        a.registerLibrary(this);

        memset(frame, 0, sizeof(frame));
        initialized = false;
    }

    void commandHandler(
        byte cmdID,
        byte* dataIn,
        unsigned int dataInSize)
    {
        switch (cmdID)
        {
            case MATRIX_BEGIN:
                beginMatrix();
                break;

            case MATRIX_WRITE:
                writeFrame(dataIn, dataInSize);
                break;

            case MATRIX_CLEAR:
                clearMatrix();
                break;

            case MATRIX_SET_PIXEL:
                setPixel(dataIn, dataInSize);
                break;

            case MATRIX_FILL:
                fillMatrix();
                break;

            case MATRIX_END:
                // Do nothing.
                // Keep the matrix subsystem initialized.
                break;

            default:
                break;
        }

        // Every sendCommand from MATLAB needs an acknowledgement.
        sendResponseMsg(cmdID, 0, 0);
    }

private:

    static const byte MATRIX_BEGIN     = 0x00;
    static const byte MATRIX_WRITE     = 0x01;
    static const byte MATRIX_CLEAR     = 0x02;
    static const byte MATRIX_SET_PIXEL = 0x03;
    static const byte MATRIX_FILL      = 0x04;
    static const byte MATRIX_END       = 0x05;

    ArduinoLEDMatrix matrix;

    uint8_t frame[8][12];

    bool initialized;


    void beginMatrix()
    {
        if (!initialized)
        {
            matrix.begin();
            initialized = true;

            memset(frame, 0, sizeof(frame));
            updateDisplay();
        }
    }


    void writeFrame(
        byte* dataIn,
        unsigned int dataInSize)
    {
        if (dataInSize != 96)
            return;

        ensureInitialized();

        unsigned int index = 0;

        for (uint8_t row = 0; row < 8; row++)
        {
            for (uint8_t column = 0; column < 12; column++)
            {
                frame[row][column] =
                    dataIn[index++] ? 1 : 0;
            }
        }

        updateDisplay();
    }


    void setPixel(
        byte* dataIn,
        unsigned int dataInSize)
    {
        if (dataInSize != 3)
            return;

        ensureInitialized();

        uint8_t row = dataIn[0];
        uint8_t column = dataIn[1];

        if (row >= 8 || column >= 12)
            return;

        frame[row][column] =
            dataIn[2] ? 1 : 0;

        updateDisplay();
    }


    void clearMatrix()
    {
        ensureInitialized();

        memset(frame, 0, sizeof(frame));

        updateDisplay();
    }


    void fillMatrix()
    {
        ensureInitialized();

        memset(frame, 1, sizeof(frame));

        updateDisplay();
    }


    void ensureInitialized()
    {
        if (!initialized)
        {
            matrix.begin();
            initialized = true;
        }
    }


    void updateDisplay()
    {
        matrix.renderBitmap(frame, 8, 12);
    }
};

#endif