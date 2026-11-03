% LEDMatrix MATLAB Add-On for Arduino UNO R4 WiFi
%
% Copyright (c) 2026 Steven Schafrik, Ph.D.
% Thanks to https://github.com/dfpsoeew/AccelStepperAddon 
% for a complete guide for how to connect these add-ons
%
% This project provides MATLAB support for controlling the built-in
% 12x8 LED matrix on the Arduino UNO R4 WiFi using the MATLAB
% Support Package for Arduino Hardware.
%
% This software is licensed under the MIT License.
% See the LICENSE file in the project repository for the full license text.
%
% SPDX-License-Identifier: MIT

classdef LEDMatrix < matlabshared.addon.LibraryBase
    % LEDMatrix Control the built-in LED matrix on an Arduino UNO R4 WiFi.
    %
    % The UNO R4 WiFi contains an 8-row by 12-column LED matrix.
    %
    % Create the Arduino connection:
    %
    %   a = arduino("COM5", "UnoR4WiFi", ...
    %       Libraries="LEDMatrix/LEDMatrix", ...
    %       ForceBuildOn=true);
    %
    % Create the matrix object:
    %
    %   matrix = addon(a, "LEDMatrix/LEDMatrix");
    %
    % Display an 8-by-12 pattern:
    %
    %   frame = false(8,12);
    %   frame(2:7,3) = true;
    %   frame(2:7,10) = true;
    %   frame(4,3:10) = true;
    %
    %   matrix.write(frame);
    %
    % Individual pixels use MATLAB indexing:
    %
    %   matrix.setPixel(1,1,true);
    %   matrix.show();
    %
    % Rows are numbered 1 through 8.
    % Columns are numbered 1 through 12.

    properties (Access = private, Constant = true)
        % These identifiers must exactly match the command identifiers
        % defined in LEDMatrix.h.

        MATRIX_BEGIN       = hex2dec('00')
        MATRIX_WRITE       = hex2dec('01')
        MATRIX_CLEAR       = hex2dec('02')
        MATRIX_SET_PIXEL   = hex2dec('03')
        MATRIX_FILL        = hex2dec('04')
        MATRIX_END         = hex2dec('05')
    end

    properties (Access = protected, Constant = true)
        % MATLAB custom Arduino library specification.

        LibraryName = 'LEDMatrix/LEDMatrix'

        % No additional MATLAB Arduino libraries are required.
        DependentLibraries = {}

        % Arduino_LED_Matrix.h is included by the C++ side.
        LibraryHeaderFiles = {}

        % Location of the custom C++ header file.
        CppHeaderFile = fullfile( ...
            arduinoio.FilePath(mfilename('fullpath')), ...
            'src', ...
            'LEDMatrix.h')

        % Name of the C++ class defined in LEDMatrix.h.
        CppClassName = 'LEDMatrix'
    end

    properties (SetAccess = private)
        % Frame Local MATLAB copy of the current matrix.
        %
        % Frame is always an 8-by-12 logical array.
        Frame = false(8,12)
    end

    properties (Constant)
        RowCount = 8
        ColumnCount = 12
    end

    methods (Hidden, Access = public)

        function obj = LEDMatrix(parentObj, varargin)
            % LEDMatrix Construct the LED matrix add-on object.
            %
            % This constructor is called by:
            %
            %   matrix = addon(a, "LEDMatrix/LEDMatrix");
            %
            % It should not normally be called directly.

            narginchk(1,1);

            obj.Parent = parentObj;

            try
                % Initialize the matrix in the Arduino firmware.
                sendCommand( ...
                    obj, ...
                    obj.LibraryName, ...
                    obj.MATRIX_BEGIN, ...
                    uint8([]));

                % Initialize the MATLAB-side frame.
                obj.Frame = false(obj.RowCount, obj.ColumnCount);

            catch exception
                throwAsCaller(exception);
            end
        end
    end

    methods (Access = public)

        function write(obj, frame)
            % write Display an entire 8-by-12 frame.
            %
            %   matrix.write(frame)
            %
            % frame must be an 8-by-12 numeric or logical array.
            % Zero values turn LEDs off. Nonzero values turn LEDs on.
            %
            % Example:
            %
            %   frame = zeros(8,12);
            %   frame(:,1) = 1;
            %   frame(:,12) = 1;
            %   matrix.write(frame);

            frame = obj.validateFrame(frame);

            obj.Frame = frame;

            payload = obj.frameToPayload(frame);

            try
                sendCommand( ...
                    obj, ...
                    obj.LibraryName, ...
                    obj.MATRIX_WRITE, ...
                    payload);
            catch exception
                throwAsCaller(exception);
            end
        end

        function show(obj)
            % show Send the locally stored frame to the Arduino.
            %
            % This is useful after calling setPixel with Update=false.
            %
            % Example:
            %
            %   matrix.setPixel(1,1,true,Update=false);
            %   matrix.setPixel(1,2,true,Update=false);
            %   matrix.setPixel(1,3,true,Update=false);
            %   matrix.show();

            payload = obj.frameToPayload(obj.Frame);

            try
                sendCommand( ...
                    obj, ...
                    obj.LibraryName, ...
                    obj.MATRIX_WRITE, ...
                    payload);
            catch exception
                throwAsCaller(exception);
            end
        end

        function setPixel(obj, row, column, state, options)
            % setPixel Set one LED in the matrix.
            %
            %   matrix.setPixel(row,column,state)
            %
            %   matrix.setPixel(row,column,state,Update=false)
            %
            % row:
            %   Integer from 1 through 8.
            %
            % column:
            %   Integer from 1 through 12.
            %
            % state:
            %   true, false, 1, or 0.
            %
            % By default, the Arduino display is updated immediately.
            % Specify Update=false to change several pixels locally before
            % calling show().
            %
            % Example:
            %
            %   matrix.setPixel(4,6,true);
            %
            % Example using a deferred update:
            %
            %   matrix.setPixel(4,6,true,Update=false);
            %   matrix.setPixel(4,7,true,Update=false);
            %   matrix.show();

            arguments
                obj
                row (1,1) double {mustBeInteger, mustBeInRange(row,1,8)}
                column (1,1) double ...
                    {mustBeInteger, mustBeInRange(column,1,12)}
                state (1,1) {mustBeNumericOrLogical}
                options.Update (1,1) logical = true
            end

            state = logical(state);

            obj.Frame(row,column) = state;

            if options.Update
                % Convert MATLAB's one-based indexes to the zero-based
                % indexes expected by the Arduino C++ implementation.
                payload = uint8([row - 1, column - 1, state]);

                try
                    sendCommand( ...
                        obj, ...
                        obj.LibraryName, ...
                        obj.MATRIX_SET_PIXEL, ...
                        payload);
                catch exception
                    throwAsCaller(exception);
                end
            end
        end

        function state = getPixel(obj, row, column)
            % getPixel Return the locally stored state of one pixel.
            %
            %   state = matrix.getPixel(row,column)
            %
            % This returns the value stored in MATLAB. It does not request
            % the pixel state from the Arduino.

            arguments
                obj
                row (1,1) double {mustBeInteger, mustBeInRange(row,1,8)}
                column (1,1) double ...
                    {mustBeInteger, mustBeInRange(column,1,12)}
            end

            state = obj.Frame(row,column);
        end

        function clear(obj)
            % clear Turn off all LEDs.
            %
            %   matrix.clear();

            obj.Frame = false(obj.RowCount, obj.ColumnCount);

            try
                sendCommand( ...
                    obj, ...
                    obj.LibraryName, ...
                    obj.MATRIX_CLEAR, ...
                    uint8([]));
            catch exception
                throwAsCaller(exception);
            end
        end

        function fill(obj)
            % fill Turn on all LEDs.
            %
            %   matrix.fill();

            obj.Frame = true(obj.RowCount, obj.ColumnCount);

            try
                sendCommand( ...
                    obj, ...
                    obj.LibraryName, ...
                    obj.MATRIX_FILL, ...
                    uint8([]));
            catch exception
                throwAsCaller(exception);
            end
        end

        function invert(obj)
            % invert Invert every LED in the current frame.
            %
            %   matrix.invert();

            obj.write(~obj.Frame);
        end

        function drawRow(obj, row, values, options)
            % drawRow Set all 12 LEDs in one row.
            %
            %   matrix.drawRow(row,values)
            %
            % values must contain 12 numeric or logical elements.
            %
            % Example:
            %
            %   matrix.drawRow(4,[0 0 1 1 1 1 1 1 1 1 0 0]);

            arguments
                obj
                row (1,1) double {mustBeInteger, mustBeInRange(row,1,8)}
                values
                options.Update (1,1) logical = true
            end

            validateattributes( ...
                values, ...
                {'numeric','logical'}, ...
                {'vector','numel',12,'finite'}, ...
                'LEDMatrix.drawRow', ...
                'values');

            obj.Frame(row,:) = logical(reshape(values,1,12));

            if options.Update
                obj.show();
            end
        end

        function drawColumn(obj, column, values, options)
            % drawColumn Set all 8 LEDs in one column.
            %
            %   matrix.drawColumn(column,values)
            %
            % values must contain 8 numeric or logical elements.
            %
            % Example:
            %
            %   matrix.drawColumn(6,[0 1 1 1 1 1 1 0]);

            arguments
                obj
                column (1,1) double ...
                    {mustBeInteger, mustBeInRange(column,1,12)}
                values
                options.Update (1,1) logical = true
            end

            validateattributes( ...
                values, ...
                {'numeric','logical'}, ...
                {'vector','numel',8,'finite'}, ...
                'LEDMatrix.drawColumn', ...
                'values');

            obj.Frame(:,column) = logical(reshape(values,8,1));

            if options.Update
                obj.show();
            end
        end

        function shiftLeft(obj, count)
            % shiftLeft Shift the frame left.
            %
            %   matrix.shiftLeft()
            %   matrix.shiftLeft(count)
            %
            % Empty columns are inserted on the right.

            if nargin < 2
                count = 1;
            end

            validateattributes( ...
                count, ...
                {'numeric'}, ...
                {'scalar','integer','nonnegative','finite'}, ...
                'LEDMatrix.shiftLeft', ...
                'count');

            count = min(double(count), obj.ColumnCount);

            if count == 0
                return;
            end

            newFrame = false(obj.RowCount, obj.ColumnCount);

            if count < obj.ColumnCount
                newFrame(:,1:(end-count)) = obj.Frame(:,(count+1):end);
            end

            obj.write(newFrame);
        end

        function shiftRight(obj, count)
            % shiftRight Shift the frame right.
            %
            %   matrix.shiftRight()
            %   matrix.shiftRight(count)
            %
            % Empty columns are inserted on the left.

            if nargin < 2
                count = 1;
            end

            validateattributes( ...
                count, ...
                {'numeric'}, ...
                {'scalar','integer','nonnegative','finite'}, ...
                'LEDMatrix.shiftRight', ...
                'count');

            count = min(double(count), obj.ColumnCount);

            if count == 0
                return;
            end

            newFrame = false(obj.RowCount, obj.ColumnCount);

            if count < obj.ColumnCount
                newFrame(:,(count+1):end) = ...
                    obj.Frame(:,1:(end-count));
            end

            obj.write(newFrame);
        end

        function shiftUp(obj, count)
            % shiftUp Shift the frame upward.
            %
            %   matrix.shiftUp()
            %   matrix.shiftUp(count)
            %
            % Empty rows are inserted at the bottom.

            if nargin < 2
                count = 1;
            end

            validateattributes( ...
                count, ...
                {'numeric'}, ...
                {'scalar','integer','nonnegative','finite'}, ...
                'LEDMatrix.shiftUp', ...
                'count');

            count = min(double(count), obj.RowCount);

            if count == 0
                return;
            end

            newFrame = false(obj.RowCount, obj.ColumnCount);

            if count < obj.RowCount
                newFrame(1:(end-count),:) = obj.Frame((count+1):end,:);
            end

            obj.write(newFrame);
        end

        function shiftDown(obj, count)
            % shiftDown Shift the frame downward.
            %
            %   matrix.shiftDown()
            %   matrix.shiftDown(count)
            %
            % Empty rows are inserted at the top.

            if nargin < 2
                count = 1;
            end

            validateattributes( ...
                count, ...
                {'numeric'}, ...
                {'scalar','integer','nonnegative','finite'}, ...
                'LEDMatrix.shiftDown', ...
                'count');

            count = min(double(count), obj.RowCount);

            if count == 0
                return;
            end

            newFrame = false(obj.RowCount, obj.ColumnCount);

            if count < obj.RowCount
                newFrame((count+1):end,:) = ...
                    obj.Frame(1:(end-count),:);
            end

            obj.write(newFrame);
        end
    end

    %{
    methods (Access = protected)

        function delete(obj)
            % delete Release the matrix when the MATLAB object is deleted.
            %
            % Errors are suppressed because MATLAB may call delete while
            % the Arduino connection is already being destroyed.

            try
                sendCommand( ...
                    obj, ...
                    obj.LibraryName, ...
                    obj.MATRIX_END, ...
                    uint8([]));
            catch
                % Intentionally do not throw an error from a destructor.
            end
        end
    end
    %}
    
    methods (Access = private)

        function frame = validateFrame(obj, frame)
            % validateFrame Validate and normalize a matrix frame.

            validateattributes( ...
                frame, ...
                {'numeric','logical'}, ...
                {'2d','size',[obj.RowCount obj.ColumnCount], ...
                 'real','finite'}, ...
                'LEDMatrix.write', ...
                'frame');

            frame = logical(frame);
        end

        function payload = frameToPayload(obj, frame)
            % frameToPayload Convert an 8-by-12 MATLAB matrix into the
            % row-major byte sequence expected by the C++ class.
            %
            % MATLAB stores arrays in column-major order. Transposing before
            % applying the colon operator produces row-major ordering:
            %
            %   row 1, columns 1-12
            %   row 2, columns 1-12
            %   ...
            %   row 8, columns 1-12

            frame = obj.validateFrame(frame);

            payload = uint8(reshape(frame.',1,[]));
        end
    end
end
