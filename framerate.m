function listCameraFormats()
    % List all available camera formats (resolution and framerate)
    % This helps you find the correct format string for your camera
    
    fprintf('\n========================================\n');
    fprintf('Camera Format Detection Tool\n');
    fprintf('========================================\n\n');
    
    % Reset and detect camera
    imaqreset;
    
    try
        % Try to detect camera (winvideo adapter, device 1)
        hwinfo = imaqhwinfo('winvideo');
        
        if isempty(hwinfo.DeviceIDs)
            error('No camera detected!');
        end
        
        fprintf('Found %d camera(s):\n\n', length(hwinfo.DeviceIDs));
        
        % List all detected cameras
        for devIdx = 1:length(hwinfo.DeviceIDs)
            fprintf('Camera %d: %s\n', devIdx, hwinfo.DeviceInfo(devIdx).DeviceName);
        end
        
        fprintf('\n========================================\n');
        fprintf('Detailed Format Information\n');
        fprintf('========================================\n\n');
        
        % For each camera, list all available formats
        for devIdx = 1:length(hwinfo.DeviceIDs)
            fprintf('\n--- Camera %d: %s ---\n\n', devIdx, hwinfo.DeviceInfo(devIdx).DeviceName);
            
            formats = hwinfo.DeviceInfo(devIdx).SupportedFormats;
            
            if isempty(formats)
                fprintf('  No formats available\n');
                continue;
            end
            
            fprintf('Total formats available: %d\n\n', length(formats));
            fprintf('%-5s %-30s %-15s %-10s\n', 'No.', 'Format String', 'Resolution', 'Type');
            fprintf('%-5s %-30s %-15s %-10s\n', '---', '-----------------------------', '--------------', '----------');
            
            % Parse and display each format
            for i = 1:length(formats)
                formatStr = formats{i};
                
                % Parse format string (e.g., "RGB24_640x480", "MJPEG_1920x1080")
                parts = strsplit(formatStr, '_');
                
                if length(parts) >= 2
                    colorType = parts{1};
                    resolution = parts{2};
                    
                    % Extract width x height
                    resParts = strsplit(resolution, 'x');
                    if length(resParts) == 2
                        width = resParts{1};
                        height = resParts{2};
                        resDisplay = sprintf('%sx%s', width, height);
                    else
                        resDisplay = resolution;
                    end
                else
                    colorType = formatStr;
                    resDisplay = 'N/A';
                end
                
                fprintf('%-5d %-30s %-15s %-10s\n', i, formatStr, resDisplay, colorType);
            end
            
            % Now test framerates for common formats
            fprintf('\n--- Testing Framerates for Popular Formats ---\n\n');
            
            % Find RGB and high-resolution formats to test
            testFormats = {};
            for i = 1:length(formats)
                formatStr = formats{i};
                % Look for RGB formats or high-res formats
                if contains(formatStr, 'RGB') || contains(formatStr, '1920x1080') || ...
                   contains(formatStr, '1280x720') || contains(formatStr, '960x540') || ...
                   contains(formatStr, 'MJPEG')
                    testFormats{end+1} = formatStr;
                end
            end
            
            % Limit to 10 most relevant formats to test
            if length(testFormats) > 10
                testFormats = testFormats(1:10);
            end
            
            fprintf('Testing %d format(s) for available framerates...\n\n', length(testFormats));
            fprintf('%-30s %-15s %-20s\n', 'Format', 'Resolution', 'Available Framerates');
            fprintf('%-30s %-15s %-20s\n', '-----------------------------', '--------------', '--------------------');
            
            for i = 1:length(testFormats)
                formatStr = testFormats{i};
                
                try
                    % Create videoinput to check framerates
                    vid = videoinput('winvideo', devIdx, formatStr);
                    src = getselectedsource(vid);
                    
                    % Get available framerates
                    framerateInfo = propinfo(src, 'FrameRate');
                    
                    % Parse resolution from format
                    parts = strsplit(formatStr, '_');
                    if length(parts) >= 2
                        resolution = parts{2};
                    else
                        resolution = 'N/A';
                    end
                    
                    if isfield(framerateInfo, 'ConstraintValue')
                        framerates = framerateInfo.ConstraintValue;
                        framerateStr = strjoin(framerates, ', ');
                    else
                        framerateStr = 'Not available';
                    end
                    
                    fprintf('%-30s %-15s %s\n', formatStr, resolution, framerateStr);
                    
                    delete(vid);
                catch
                    fprintf('%-30s %-15s %s\n', formatStr, 'N/A', 'Error reading');
                end
            end
        end
        
        fprintf('\n========================================\n');
        fprintf('Quick Usage Guide\n');
        fprintf('========================================\n\n');
        fprintf('To use a specific format in your code:\n\n');
        fprintf('  vid = videoinput(''winvideo'', DEVICE_ID, ''FORMAT_STRING'');\n');
        fprintf('  src = getselectedsource(vid);\n');
        fprintf('  set(src, ''FrameRate'', ''FRAMERATE_VALUE'');\n\n');
        fprintf('Example:\n');
        fprintf('  vid = videoinput(''winvideo'', 1, ''RGB24_1920x1080'');\n');
        fprintf('  src = getselectedsource(vid);\n');
        fprintf('  set(src, ''FrameRate'', ''30.0000'');\n\n');
        fprintf('========================================\n\n');
        
    catch ME
        fprintf('Error: %s\n', ME.message);
        fprintf('\nTroubleshooting:\n');
        fprintf('1. Make sure your camera is connected\n');
        fprintf('2. Check that Image Acquisition Toolbox is installed\n');
        fprintf('3. Try running: imaqhwinfo to see detected adapters\n');
    end
    
    imaqreset;
end

listCameraFormats()
