function orientationFilterCamera60fps()
    clear all; clc; close all;
    rng('default');
    
    %% User-configurable parameters (easy to modify)
    % Camera settings - VERIFIED 60FPS CONFIGURATION (Fixed for your camera)
    CAM_WIDTH = 960;               % Camera resolution width (fixed to match your setup)
    CAM_HEIGHT = 540;              % Camera resolution height (fixed to match your setup)
    FOV_HORIZONTAL_DEG = 30;       % Camera horizontal field of view in degrees
    FOV_VERTICAL_DEG = 20;         % Camera vertical field of view in degrees
    
    % Display settings optimized for 60fps
    DISPLAY_UPDATE_INTERVAL = 3;   % Update display every N frames (higher values = faster but less responsive)
    PLOT_UPDATE_INTERVAL = 15;     % Update heavy plots less frequently
    USE_GPU = true;                % Set to false to disable GPU acceleration
    
    % Initialize 60fps camera
    hasWebcam = false;
    camera_type = 'none';
    
    % GPU availability check
    useGPU = USE_GPU && (gpuDeviceCount > 0);
    
    % Try 60fps camera setup first - FIXED TO MATCH YOUR WORKING SETUP
    try
        imaqreset;
        vid = videoinput('winvideo', 1, 'MJPG_960x540');  % Changed to your working resolution
        src = getselectedsource(vid);
        set(src, 'FrameRate', '60.0002');  % Changed to your working frame rate
        fprintf('Camera set to: %s fps\n', get(src, 'FrameRate'));
        
        % Image dimensions (fixed for this configuration)
        height = 540;
        width = 960;
        channels = 3;
        fprintf('Camera: %s\nResolution: %dx%d\nChannels: %d\n', ...
            vid.Name, width, height, channels);
        
        % Set continuous acquisition for high-speed capture
        set(vid, 'FramesPerTrigger', Inf);
        set(vid, 'TriggerRepeat', Inf);
        set(vid, 'ReturnedColorSpace', 'rgb');
        
        hasWebcam = true;
        camera_type = '60fps_imaq';
        fprintf('60fps camera initialized successfully\n');
    catch ME
        fprintf('60fps camera initialization failed: %s\n', ME.message);
        % Fallback to regular webcam
        try
            cam = webcam();
            try
                cam.Resolution = [num2str(CAM_WIDTH) 'x' num2str(CAM_HEIGHT)];
                fprintf("Fallback webcam resolution supported\n");
            catch
                fprintf("Fallback webcam resolution not supported, using default\n");
            end
            hasWebcam = true;
            camera_type = 'webcam';
        catch ME2
            fprintf('Webcam fallback failed: %s\n', ME2.message);
            warning('No webcam available. Will use a test image instead.');
            camera_type = 'none';
        end
    end
    
    % Filter parameters struct with enhanced controls
    params = struct('sigma', 19.9*(pi/180), 'filter_type', 1, 'enable_butterworth', 0, ...
                    'center_sf', 1, 'sf_low', 2/3, 'sf_high', 4, 'butterworth_order', 2, ...
                    'horizontal_angle', 0, 'vertical_angle', 90, 'oblique_angle', 45, ...
                    'running', true);
    
    % Create main figure with enhanced layout for 60fps
    fig = figure('Name', 'Real-time 60fps Orientation Filter', 'NumberTitle', 'off', ...
        'Position', [50, 50, 1600, 1000], 'MenuBar', 'none', 'ToolBar', 'none', ...
        'CloseRequestFcn', @closeRequestCallback, 'Color', [0.94, 0.94, 0.94]);
    
    % Controls Panel - Enhanced for 60fps monitoring
    panel = uipanel('Parent', fig, 'Position', [0.01, 0.01, 0.22, 0.98], ...
        'Title', '60fps Filter Controls', 'FontSize', 12, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % Performance monitoring section
    control_height = 850;
    uicontrol(panel, 'Style', 'text', 'String', 'Performance Monitor', ...
              'Position', [10, control_height, 180, 25], 'HorizontalAlignment', 'left', ...
              'FontSize', 11, 'FontWeight', 'bold', 'BackgroundColor', [0.95, 0.95, 0.95]);
    
    fps_text = uicontrol(panel, 'Style', 'text', 'String', 'FPS: --', ...
        'Position', [15, control_height-25, 180, 20], 'HorizontalAlignment', 'left', ...
        'FontSize', 9, 'BackgroundColor', [0.95, 0.95, 0.95]);
    
    frame_text = uicontrol(panel, 'Style', 'text', 'String', 'Frames: 0', ...
        'Position', [15, control_height-45, 180, 20], 'HorizontalAlignment', 'left', ...
        'FontSize', 9, 'BackgroundColor', [0.95, 0.95, 0.95]);
    
    processing_text = uicontrol(panel, 'Style', 'text', 'String', 'Processing: GPU', ...
        'Position', [15, control_height-65, 180, 20], 'HorizontalAlignment', 'left', ...
        'FontSize', 9, 'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % SIGMA CONTROLS
    control_height = 750;
    uicontrol(panel, 'Style', 'text', 'String', 'Filter Width (σ)', ...
              'Position', [10, control_height, 180, 25], 'HorizontalAlignment', 'left', ...
              'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', [0.95, 0.95, 0.95]);
    
    sigma_value_text = uicontrol(panel, 'Style', 'text', ...
              'Position', [150, control_height-30, 60, 20], ...
              'String', [num2str(round(params.sigma * (180/pi),1)) '°'], ...
              'HorizontalAlignment', 'right', 'BackgroundColor', [0.95, 0.95, 0.95]);
    
    sigma_slider = uicontrol(panel, 'Style', 'slider', 'Min', 5, 'Max', 60, ...
              'Value', params.sigma * (180/pi), 'Position', [10, control_height-30, 130, 25], ...
              'Callback', @(src,~) setSigma(src.Value));
    
    % Filter type selection
    control_height = control_height - 70;
    uicontrol(panel, 'Style', 'text', 'String', 'Filter Orientation', ...
              'Position', [10, control_height, 180, 25], 'HorizontalAlignment', 'left', ...
              'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', [0.95, 0.95, 0.95]);
    
    h_radio = uicontrol(panel, 'Style', 'radiobutton', 'String', 'Horizontal', ...
              'Position', [20, control_height-30, 65, 25], 'Value', params.filter_type == 1, ...
              'Callback', @(src,~) setFilterType(1), 'BackgroundColor', [0.95, 0.95, 0.95]);
              
    o_radio = uicontrol(panel, 'Style', 'radiobutton', 'String', 'Oblique', ...
              'Position', [90, control_height-30, 55, 25], 'Value', params.filter_type == 3, ...
              'Callback', @(src,~) setFilterType(3), 'BackgroundColor', [0.95, 0.95, 0.95]);
              
    v_radio = uicontrol(panel, 'Style', 'radiobutton', 'String', 'Vertical', ...
              'Position', [150, control_height-30, 55, 25], 'Value', params.filter_type == 2, ...
              'Callback', @(src,~) setFilterType(2), 'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % Butterworth filter controls
    control_height = control_height - 70;
    butterworth_cb = uicontrol(panel, 'Style', 'checkbox', 'String', 'Enable Spatial Frequency Filter', ...
                'Position', [10, control_height, 200, 25], 'Value', params.enable_butterworth, ...
                'Callback', @(src,~) enableButterworth(src.Value), 'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % Center spatial frequency controls
    control_height = control_height - 40;
    uicontrol(panel, 'Style', 'text', 'String', 'Center Frequency (cycles/deg)', ...
              'Position', [10, control_height, 180, 20], 'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.95, 0.95, 0.95]);
    
    center_sf_text = uicontrol(panel, 'Style', 'text', ...
              'Position', [150, control_height-30, 60, 20], ...
              'String', num2str(params.center_sf), ...
              'HorizontalAlignment', 'right', 'BackgroundColor', [0.95, 0.95, 0.95]);
              
    center_sf_slider = uicontrol(panel, 'Style', 'slider', 'Min', 0.1, 'Max', 10, ...
              'Value', params.center_sf, 'Position', [10, control_height-30, 130, 25], ...
              'Callback', @(src,~) setCenterSF(src.Value));
    
    % Bandwidth controls
    control_height = control_height - 60;
    uicontrol(panel, 'Style', 'text', 'String', 'Bandwidth (cycles/deg)', ...
              'Position', [10, control_height, 180, 20], 'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.95, 0.95, 0.95]);
              
    bandwidth_text = uicontrol(panel, 'Style', 'text', ...
              'Position', [150, control_height-30, 60, 20], ...
              'String', [num2str(params.sf_low) '-' num2str(params.sf_high)], ...
              'HorizontalAlignment', 'right', 'BackgroundColor', [0.95, 0.95, 0.95]);
              
    bandwidth_slider = uicontrol(panel, 'Style', 'slider', 'Min', 0.5, 'Max', 10, ...
              'Value', params.sf_high - params.sf_low, 'Position', [10, control_height-30, 130, 25], ...
              'Callback', @(src,~) setBandwidth(src.Value));
    
    % Butterworth order controls
    control_height = control_height - 60;
    uicontrol(panel, 'Style', 'text', 'String', 'Filter Order', ...
              'Position', [10, control_height, 180, 20], 'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.95, 0.95, 0.95]);
              
    order_text = uicontrol(panel, 'Style', 'text', ...
              'Position', [150, control_height-30, 60, 20], ...
              'String', num2str(params.butterworth_order), ...
              'HorizontalAlignment', 'right', 'BackgroundColor', [0.95, 0.95, 0.95]);
              
    order_slider = uicontrol(panel, 'Style', 'slider', 'Min', 1, 'Max', 10, ...
              'Value', params.butterworth_order, 'Position', [10, control_height-30, 130, 25], ...
              'Callback', @(src,~) setOrder(src.Value));
    
    % Orientation angle controls
    control_height = control_height - 80;
    uicontrol(panel, 'Style', 'text', 'String', 'Orientation Angles', ...
              'Position', [10, control_height, 180, 25], 'HorizontalAlignment', 'left', ...
              'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % Horizontal angle
    control_height = control_height - 30;
    uicontrol(panel, 'Style', 'text', 'String', 'Horizontal:', ...
              'Position', [10, control_height, 70, 20], 'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.95, 0.95, 0.95]);
              
    h_angle_text = uicontrol(panel, 'Style', 'text', ...
              'Position', [150, control_height, 50, 20], ...
              'String', [num2str(params.horizontal_angle) '°'], ...
              'HorizontalAlignment', 'right', 'BackgroundColor', [0.95, 0.95, 0.95]);
              
    h_angle_slider = uicontrol(panel, 'Style', 'slider', 'Min', -90, 'Max', 90, ...
              'Value', params.horizontal_angle, 'Position', [80, control_height, 65, 20], ...
              'Callback', @(src,~) setHorizontalAngle(src.Value));
    
    % Vertical angle
    control_height = control_height - 30;
    uicontrol(panel, 'Style', 'text', 'String', 'Vertical:', ...
              'Position', [10, control_height, 70, 20], 'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.95, 0.95, 0.95]);
              
    v_angle_text = uicontrol(panel, 'Style', 'text', ...
              'Position', [150, control_height, 50, 20], ...
              'String', [num2str(params.vertical_angle) '°'], ...
              'HorizontalAlignment', 'right', 'BackgroundColor', [0.95, 0.95, 0.95]);
              
    v_angle_slider = uicontrol(panel, 'Style', 'slider', 'Min', 0, 'Max', 180, ...
              'Value', params.vertical_angle, 'Position', [80, control_height, 65, 20], ...
              'Callback', @(src,~) setVerticalAngle(src.Value));
    
    % Oblique angle
    control_height = control_height - 30;
    uicontrol(panel, 'Style', 'text', 'String', 'Oblique:', ...
              'Position', [10, control_height, 70, 20], 'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.95, 0.95, 0.95]);
              
    o_angle_text = uicontrol(panel, 'Style', 'text', ...
              'Position', [150, control_height, 50, 20], ...
              'String', [num2str(params.oblique_angle) '°'], ...
              'HorizontalAlignment', 'right', 'BackgroundColor', [0.95, 0.95, 0.95]);
              
    o_angle_slider = uicontrol(panel, 'Style', 'slider', 'Min', 0, 'Max', 180, ...
              'Value', params.oblique_angle, 'Position', [80, control_height, 65, 20], ...
              'Callback', @(src,~) setObliqueAngle(src.Value));
    
    % Create preset buttons
    control_height = control_height - 70;
    uicontrol(panel, 'Style', 'pushbutton', 'String', 'Horizontal Edge', ...
              'Position', [10, control_height, 90, 30], ...
              'Callback', @(~,~) setPreset('h_edge'));
              
    uicontrol(panel, 'Style', 'pushbutton', 'String', 'Vertical Edge', ...
              'Position', [105, control_height, 90, 30], ...
              'Callback', @(~,~) setPreset('v_edge'));
              
    uicontrol(panel, 'Style', 'pushbutton', 'String', 'Oblique Edge', ...
              'Position', [10, control_height-40, 90, 30], ...
              'Callback', @(~,~) setPreset('o_edge'));
              
    uicontrol(panel, 'Style', 'pushbutton', 'String', 'Lowpass', ...
              'Position', [105, control_height-40, 45, 30], ...
              'Callback', @(~,~) setPreset('lowpass'));
              
    uicontrol(panel, 'Style', 'pushbutton', 'String', 'Highpass', ...
              'Position', [155, control_height-40, 45, 30], ...
              'Callback', @(~,~) setPreset('highpass'));
    
    % Control visibility function
    function updateControlsVisibility()
        enableState = 'off';
        if params.enable_butterworth
            enableState = 'on';
        end
        set([center_sf_slider, center_sf_text, bandwidth_slider, bandwidth_text, order_slider, order_text], ...
            'Enable', enableState);
    end
    
    % Performance monitoring
    frameCount = 0;
    tic_start = tic;
    
    function updatePerformanceMetrics()
        elapsed = toc(tic_start);
        if elapsed > 1
            fps = frameCount / elapsed;
            set(fps_text, 'String', sprintf('FPS: %.1f', fps));
            set(frame_text, 'String', sprintf('Frames: %d', frameCount));
            set(processing_text, 'String', sprintf('Processing: %s', ...
                ternary(useGPU, 'GPU', 'CPU')));
            tic_start = tic;
            frameCount = 0;
        end
    end
    
    % Callback functions
    function setSigma(val)
        val = round(val * 10) / 10;
        params.sigma = val * (pi/180);
        set(sigma_value_text, 'String', [num2str(val) '°']);
        updateFilter();
    end
    
    function setFilterType(type)
        params.filter_type = type;
        set(h_radio, 'Value', type == 1);
        set(v_radio, 'Value', type == 2);
        set(o_radio, 'Value', type == 3);
        updateFilter();
    end
    
    function enableButterworth(val)
        params.enable_butterworth = val;
        updateControlsVisibility();
        updateFilter();
    end
    
    function setCenterSF(val)
        params.center_sf = val;
        set(center_sf_text, 'String', num2str(round(val*10)/10));
        updateFilter();
    end
    
    function setBandwidth(val)
        params.sf_low = max(0.1, params.center_sf - val/2);
        params.sf_high = params.center_sf + val/2;
        set(bandwidth_text, 'String', [num2str(round(params.sf_low*10)/10) '-' num2str(round(params.sf_high*10)/10)]);
        updateFilter();
    end
    
    function setOrder(val)
        params.butterworth_order = round(val);
        set(order_text, 'String', num2str(params.butterworth_order));
        updateFilter();
    end
    
    function setHorizontalAngle(val)
        params.horizontal_angle = round(val);
        set(h_angle_text, 'String', [num2str(params.horizontal_angle) '°']);
        updateFilter();
    end
    
    function setVerticalAngle(val)
        params.vertical_angle = round(val);
        set(v_angle_text, 'String', [num2str(params.vertical_angle) '°']);
        updateFilter();
    end
    
    function setObliqueAngle(val)
        params.oblique_angle = round(val);
        set(o_angle_text, 'String', [num2str(params.oblique_angle) '°']);
        updateFilter();
    end
    
    function setPreset(preset_name)
        switch preset_name
            case 'h_edge'
                setFilterType(1); setSigma(15); enableButterworth(1);
                setCenterSF(3); setBandwidth(5); setOrder(2);
            case 'v_edge'
                setFilterType(2); setSigma(15); enableButterworth(1);
                setCenterSF(3); setBandwidth(5); setOrder(2);
            case 'o_edge'
                setFilterType(3); setSigma(15); enableButterworth(1);
                setCenterSF(3); setBandwidth(5); setOrder(2);
            case 'lowpass'
                setFilterType(1); setSigma(60); enableButterworth(1);
                setCenterSF(1); setBandwidth(2); setOrder(2);
            case 'highpass'
                setFilterType(1); setSigma(60); enableButterworth(1);
                setCenterSF(5); setBandwidth(8); setOrder(2);
        end
    end
    
    % Create enhanced subplot layout
    ax_orig = subplot('Position', [0.25 0.75 0.18 0.2]);
    title('Original 60fps Feed', 'FontSize', 10, 'FontWeight', 'bold');
    
    ax_orig_spectrum = subplot('Position', [0.45 0.75 0.18 0.2]);
    title('Original Spectrum', 'FontSize', 10, 'FontWeight', 'bold');
    
    ax_filter = subplot('Position', [0.65 0.75 0.18 0.2]);
    title('Filter Visualization', 'FontSize', 10, 'FontWeight', 'bold');
    
    ax_filtered = subplot('Position', [0.25 0.5 0.18 0.2]);
    title('Filtered Result', 'FontSize', 10, 'FontWeight', 'bold');
    
    ax_filtered_spectrum = subplot('Position', [0.45 0.5 0.18 0.2]);
    title('Filtered Spectrum', 'FontSize', 10, 'FontWeight', 'bold');
    
    ax_orientation_energy_orig = subplot('Position', [0.65 0.5 0.18 0.2]);
    title('Original Energy by Angle', 'FontSize', 10, 'FontWeight', 'bold');
    
    ax_orientation_energy_filtered = subplot('Position', [0.25 0.25 0.18 0.2]);
    title('Filtered Energy by Angle', 'FontSize', 10, 'FontWeight', 'bold');
    
    ax_orientation_energy_combined = subplot('Position', [0.45 0.25 0.38 0.2]);
    title('Orientation Energy Comparison', 'FontSize', 10, 'FontWeight', 'bold');
    
    % Get initial image
    if strcmp(camera_type, 'none')
        scene = imread('peppers.png');
        scene = im2double(scene);
    else
        if strcmp(camera_type, '60fps_imaq')
            start(vid);
            % Wait for camera to stabilize
            pause(0.1);
            test_frame = getdata(vid, 1);
            if size(test_frame, 4) > 0
                test_frame = test_frame(:,:,:,end);
            end
        elseif strcmp(camera_type, 'webcam')
            test_frame = snapshot(cam);
        end
        scene = im2double(test_frame);
    end
    
    % Pre-allocate matrices
    [rows, cols, channels] = size(scene);
    scene_filtered = zeros(size(scene), 'like', scene);
    
    % Pre-compute filter parameters optimized for 60fps
    u = -floor(cols/2):floor((cols-1)/2);
    v = -floor(rows/2):floor((rows-1)/2);
    [U, V] = meshgrid(u, v);
    U_cpd = U / (cols/FOV_HORIZONTAL_DEG);
    V_cpd = V / (rows/FOV_VERTICAL_DEG);
    sf = sqrt(U_cpd.^2 + V_cpd.^2);
    theta = atan2(V, U);
    
    % Move to GPU if available
    if useGPU
        U = gpuArray(U); V = gpuArray(V);
        U_cpd = gpuArray(U_cpd); V_cpd = gpuArray(V_cpd);
        sf = gpuArray(sf); theta = gpuArray(theta);
        fprintf('GPU acceleration enabled for 60fps processing\n');
    end
    
    H_filter = [];
    
    % Orientation analysis setup
    orientation_angles_deg = 0:5:180;
    num_orientations = length(orientation_angles_deg);
    orientation_angles = orientation_angles_deg * (pi/180);
    orientation_energy_orig = zeros(1, num_orientations);
    orientation_energy_filtered = zeros(1, num_orientations);
    
    % Utility function
    function result = ternary(condition, true_val, false_val)
        if condition
            result = true_val;
        else
            result = false_val;
        end
    end
    
    % Filter update function
    function updateFilter()
        if params.filter_type == 1
            % Horizontal filter (covers both horizontal orientations)
            angle_rad = params.horizontal_angle * (pi/180);
            H_orientation = exp(-(cos(theta - angle_rad).^2) / (2 * params.sigma^2));
        elseif params.filter_type == 2
            % Vertical filter (covers both vertical orientations)
            angle_rad = params.vertical_angle * (pi/180);
            H_orientation = exp(-(sin(theta - angle_rad).^2) / (2 * params.sigma^2));
        else
            % Oblique filter (covers both diagonal orientations) - FIXED
            angle_rad = params.oblique_angle * (pi/180);
            H_orientation = exp(-(cos(2*(theta - angle_rad)).^2) / (2 * params.sigma^2));
        end
        
        if params.enable_butterworth
            sf_filter = 1 ./ (1 + ((sf - params.center_sf) ./ ((params.sf_high - params.sf_low)/2)).^(2*params.butterworth_order));
            H_filter = H_orientation .* sf_filter;
        else
            H_filter = H_orientation;
        end
        
        % Force immediate plot refresh when filter changes
        refreshPlots();
    end
    
    % Optimized orientation energy calculation
    function energy = calculateOrientationEnergy(gray_img)
        if ~isa(gray_img, 'double')
            gray_img = im2double(gray_img);
        end
        
        F = fft2(gray_img);
        F_shifted = fftshift(F);
        energy = zeros(1, num_orientations);
        
        orientation_sigma = 15 * (pi/180);
        
        for i = 1:num_orientations
            angle = orientation_angles(i);
            
            if params.filter_type == 1
                % Horizontal orientation analysis
                angle_rad = params.horizontal_angle * (pi/180);
                orientation_filter = exp(-((theta - (angle_rad + angle)).^2) / (2 * orientation_sigma^2));
            elseif params.filter_type == 2
                % Vertical orientation analysis
                angle_rad = params.vertical_angle * (pi/180);
                orientation_filter = exp(-((theta - (angle_rad + angle)).^2) / (2 * orientation_sigma^2));
            else
                % Oblique orientation analysis
                angle_rad = params.oblique_angle * (pi/180);
                orientation_filter = exp(-((theta - (angle_rad + angle)).^2) / (2 * orientation_sigma^2));
            end
            
            if params.enable_butterworth
                sf_filter = 1 ./ (1 + ((sf - params.center_sf) ./ ((params.sf_high - params.sf_low)/2)).^(2*params.butterworth_order));
                orientation_filter = orientation_filter .* sf_filter;
            end
            
            F_filtered = F_shifted .* orientation_filter;
            energy(i) = sum(abs(F_filtered(:)).^2);
        end
        
        energy = energy / max(energy);
    end
    
    % Function to refresh all plots immediately
    function refreshPlots()
        if exist('scene', 'var') && ~isempty(scene)
            % Update filter visualization immediately
            axes(ax_filter); 
            imshow(mat2gray(gather(H_filter))); 
            title('Filter Visualization');
            
            % Recalculate and update orientation energy plots with current scene
            if useGPU
                gray_img = rgb2gray(scene);
                if exist('scene_filtered', 'var') && ~isempty(scene_filtered)
                    gray_filtered = rgb2gray(scene_filtered);
                else
                    gray_filtered = gray_img; % Fallback if filtered scene not available
                end
            else
                gray_img = rgb2gray(scene);
                if exist('scene_filtered', 'var') && ~isempty(scene_filtered)
                    gray_filtered = rgb2gray(scene_filtered);
                else
                    gray_filtered = gray_img; % Fallback if filtered scene not available
                end
            end
            
            orientation_energy_orig = calculateOrientationEnergy(gray_img);
            orientation_energy_filtered = calculateOrientationEnergy(gray_filtered);
            
            % Update combined orientation energy plot
            axes(ax_orientation_energy_combined);
            cla; % Clear the axes to remove old data
            bar_width = 0.35;
            x_positions = orientation_angles_deg;
            
            hold on;
            bar(x_positions - bar_width/2, orientation_energy_orig, bar_width, ...
                'FaceColor', [0.4 0.6 0.8], 'EdgeColor', 'none', 'DisplayName', 'Original');
            bar(x_positions + bar_width/2, orientation_energy_filtered, bar_width, ...
                'FaceColor', [0.8 0.4 0.4], 'EdgeColor', 'none', 'DisplayName', 'Filtered');
            hold off;
            
            title('Orientation Energy: Original vs Filtered'); 
            xlabel('Angle (°)'); 
            ylabel('Energy');
            legend('Original', 'Filtered', 'Location', 'best');
            ylim([0 1.05]); 
            xlim([0 180]); 
            grid on;
            
            % Update individual energy plots
            axes(ax_orientation_energy_orig);
            cla;
            bar(orientation_angles_deg, orientation_energy_orig, 'FaceColor', [0.4 0.6 0.8]);
            title('Original Energy by Angle'); 
            xlabel('Angle (°)'); 
            ylabel('Energy');
            ylim([0 1.05]); 
            xlim([0 180]); 
            grid on;
            
            axes(ax_orientation_energy_filtered);
            cla;
            bar(orientation_angles_deg, orientation_energy_filtered, 'FaceColor', [0.8 0.4 0.4]);
            title('Filtered Energy by Angle'); 
            xlabel('Angle (°)'); 
            ylabel('Energy');
            ylim([0 1.05]); 
            xlim([0 180]); 
            grid on;
            
            drawnow;
        end
    end
    
    % Initialize
    updateFilter();
    updateControlsVisibility();
    
    % Main 60fps processing loop
    frame_count = 0;
    
    while params.running && isvalid(fig)
        % High-speed frame acquisition
        if ~strcmp(camera_type, 'none')
            if strcmp(camera_type, '60fps_imaq')
                frame = getdata(vid, 1);
                if size(frame, 4) > 0
                    frame = frame(:,:,:,end);
                end
            elseif strcmp(camera_type, 'webcam')
                frame = snapshot(cam);
            end
            scene = im2double(frame);
        end
        
        frame_count = frame_count + 1;
        frameCount = frameCount + 1;
        
        % GPU-accelerated filtering
        if useGPU
            scene_gpu = gpuArray(scene);
            scene_filtered = zeros(size(scene), 'gpuArray');
            
            for c = 1:channels
                F = fft2(scene_gpu(:,:,c));
                F_shifted = fftshift(F);
                F_filtered = F_shifted .* H_filter;
                scene_filtered(:,:,c) = real(ifft2(ifftshift(F_filtered)));
                
                if c == 1
                    filtered_spectrum_raw = F_filtered;
                end
            end
            
            min_val = min(scene_filtered(:));
            max_val = max(scene_filtered(:));
            scene_filtered = (scene_filtered - min_val) / (max_val - min_val + eps);
            scene_filtered = gather(scene_filtered);
        else
            for c = 1:channels
                F = fft2(scene(:,:,c));
                F_shifted = fftshift(F);
                F_filtered = F_shifted .* H_filter;
                scene_filtered(:,:,c) = real(ifft2(ifftshift(F_filtered)));
                
                if c == 1
                    filtered_spectrum_raw = F_filtered;
                end
            end
            
            min_val = min(scene_filtered(:));
            max_val = max(scene_filtered(:));
            scene_filtered = (scene_filtered - min_val) / (max_val - min_val + eps);
        end
        
        % Update performance metrics
        updatePerformanceMetrics();
        
        % Update displays at optimized intervals for 60fps
        if mod(frame_count, DISPLAY_UPDATE_INTERVAL) == 0
            axes(ax_orig); imshow(scene); title('Original 60fps Feed');
            axes(ax_filtered); imshow(scene_filtered); title('Filtered Result');
            axes(ax_filter); imshow(mat2gray(gather(H_filter))); title('Filter');
            
            % Update heavy plots less frequently
            if mod(frame_count, PLOT_UPDATE_INTERVAL) == 0
                % Calculate spectrums and energy plots
                if useGPU
                    gray_img = rgb2gray(gather(scene_gpu));
                    gray_filtered = rgb2gray(scene_filtered);
                else
                    gray_img = rgb2gray(scene);
                    gray_filtered = rgb2gray(scene_filtered);
                end
                
                F_orig = fft2(gray_img);
                orig_spectrum_vis = mat2gray(log(abs(fftshift(F_orig))+1));
                filtered_spectrum_vis = mat2gray(log(abs(gather(filtered_spectrum_raw))+1));
                
                orientation_energy_orig = calculateOrientationEnergy(gray_img);
                orientation_energy_filtered = calculateOrientationEnergy(gray_filtered);
                
                % Update spectrum plots
                axes(ax_orig_spectrum); imshow(orig_spectrum_vis); title('Original Spectrum');
                axes(ax_filtered_spectrum); imshow(filtered_spectrum_vis); title('Filtered Spectrum');
                
                % Update individual energy plots
                axes(ax_orientation_energy_orig);
                bar(orientation_angles_deg, orientation_energy_orig, 'FaceColor', [0.4 0.6 0.8]);
                title('Original Energy by Angle'); 
                xlabel('Angle (°)'); 
                ylabel('Energy');
                ylim([0 1.05]); 
                xlim([0 180]); 
                grid on;
                
                axes(ax_orientation_energy_filtered);
                bar(orientation_angles_deg, orientation_energy_filtered, 'FaceColor', [0.8 0.4 0.4]);
                title('Filtered Energy by Angle'); 
                xlabel('Angle (°)'); 
                ylabel('Energy');
                ylim([0 1.05]); 
                xlim([0 180]); 
                grid on;
                
                % Combined orientation energy plot with side-by-side bars
                axes(ax_orientation_energy_combined);
                bar_width = 0.35;
                x_positions = orientation_angles_deg;
                
                hold on;
                bar(x_positions - bar_width/2, orientation_energy_orig, bar_width, ...
                    'FaceColor', [0.4 0.6 0.8], 'EdgeColor', 'none', 'DisplayName', 'Original');
                bar(x_positions + bar_width/2, orientation_energy_filtered, bar_width, ...
                    'FaceColor', [0.8 0.4 0.4], 'EdgeColor', 'none', 'DisplayName', 'Filtered');
                hold off;
                
                title('Orientation Energy: Original vs Filtered'); 
                xlabel('Angle (°)'); 
                ylabel('Energy');
                legend('Original', 'Filtered', 'Location', 'best');
                ylim([0 1.05]); 
                xlim([0 180]); 
                grid on;
            end
            
            drawnow;
        end
        
        if strcmp(camera_type, 'none'), pause(0.033); end % ~30fps fallback for test image
    end
    
    % Cleanup
    if strcmp(camera_type, 'webcam') && exist('cam', 'var')
        clear cam;
    elseif strcmp(camera_type, '60fps_imaq') && exist('vid', 'var')
        stop(vid); delete(vid);
    end
    
    function closeRequestCallback(~, ~)
        params.running = false;
        delete(fig);
    end
end