function server_testimage()
    % Local Debugging Tool: RGB Camera Filter Before/After Comparison
    % Displays original and filtered images side-by-side at 60fps
    % No external connection - purely for filter visualization
    
    % First open parameter selection window
    if ~openParameterSelectionWindow()
        return; % User cancelled
    end
    
    % If we get here, user clicked "Start" - proceed with filter testing
    startFilterTesting();
end

function proceed = openParameterSelectionWindow()
    % Create parameter selection window
    paramFig = figure('Name', 'Filter Parameters - Local Debugging', ...
        'NumberTitle', 'off', 'Position', [200, 200, 400, 750], ...
        'MenuBar', 'none', 'ToolBar', 'none', 'Resize', 'off', ...
        'Color', [0.94, 0.94, 0.94]);
    
    % Initialize parameters with defaults
    params = struct('sigma', 25*(pi/180), 'filter_type', 1, 'enable_butterworth', 0, ...
                    'center_sf', 1, 'sf_low', 2/3, 'sf_high', 4, 'butterworth_order', 2, ...
                    'horizontal_angle', 0, 'vertical_angle', 0, 'oblique_angle', 135, ...
                    'showPreview', true, 'maxBufferFrames', 1);
    
    proceed = false; % Will be set to true if user clicks "Start Debugging"
    
    % Title
    uicontrol(paramFig, 'Style', 'text', 'String', 'Configure Filter Parameters', ...
        'Position', [20, 700, 360, 30], 'FontSize', 14, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    % Filter Width Control
    control_height = 650;
    uicontrol(paramFig, 'Style', 'text', 'String', 'Filter Width (σ)', ...
        'Position', [20, control_height, 360, 25], 'HorizontalAlignment', 'left', ...
        'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    sigma_value_text = uicontrol(paramFig, 'Style', 'text', ...
        'Position', [300, control_height-30, 80, 20], ...
        'String', [num2str(round(params.sigma * (180/pi),1)) '°'], ...
        'HorizontalAlignment', 'right', 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    sigma_slider = uicontrol(paramFig, 'Style', 'slider', 'Min', 5, 'Max', 60, ...
        'Value', params.sigma * (180/pi), 'Position', [30, control_height-30, 260, 25], ...
        'Callback', @(src,~) setSigma(src.Value));
    
    % Filter Type Selection
    control_height = control_height - 70;
    uicontrol(paramFig, 'Style', 'text', 'String', 'Filter Orientation', ...
        'Position', [20, control_height, 360, 25], 'HorizontalAlignment', 'left', ...
        'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    h_radio = uicontrol(paramFig, 'Style', 'radiobutton', 'String', 'Horizontal', ...
        'Position', [30, control_height-30, 80, 25], 'Value', params.filter_type == 1, ...
        'Callback', @(src,~) setFilterType(1), 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    v_radio = uicontrol(paramFig, 'Style', 'radiobutton', 'String', 'Vertical', ...
        'Position', [120, control_height-30, 80, 25], 'Value', params.filter_type == 2, ...
        'Callback', @(src,~) setFilterType(2), 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    o_radio = uicontrol(paramFig, 'Style', 'radiobutton', 'String', 'Oblique', ...
        'Position', [210, control_height-30, 80, 25], 'Value', params.filter_type == 3, ...
        'Callback', @(src,~) setFilterType(3), 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    % Butterworth Filter Controls
    control_height = control_height - 70;
    butterworth_cb = uicontrol(paramFig, 'Style', 'checkbox', 'String', 'Enable Spatial Frequency Filter', ...
        'Position', [20, control_height, 300, 25], 'Value', params.enable_butterworth, ...
        'Callback', @(src,~) enableButterworth(src.Value), 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    % Center Frequency
    control_height = control_height - 40;
    uicontrol(paramFig, 'Style', 'text', 'String', 'Center Frequency:', ...
        'Position', [30, control_height, 120, 20], 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.94, 0.94, 0.94]);
    
    center_sf_text = uicontrol(paramFig, 'Style', 'text', ...
        'Position', [320, control_height, 60, 20], ...
        'String', num2str(params.center_sf), ...
        'HorizontalAlignment', 'right', 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    center_sf_slider = uicontrol(paramFig, 'Style', 'slider', 'Min', 0.1, 'Max', 10, ...
        'Value', params.center_sf, 'Position', [150, control_height, 160, 20], ...
        'Callback', @(src,~) setCenterSF(src.Value));
    
    % Bandwidth
    control_height = control_height - 40;
    uicontrol(paramFig, 'Style', 'text', 'String', 'Bandwidth:', ...
        'Position', [30, control_height, 120, 20], 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.94, 0.94, 0.94]);
    
    bandwidth_text = uicontrol(paramFig, 'Style', 'text', ...
        'Position', [300, control_height, 80, 20], ...
        'String', [num2str(params.sf_low) '-' num2str(params.sf_high)], ...
        'HorizontalAlignment', 'right', 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    bandwidth_slider = uicontrol(paramFig, 'Style', 'slider', 'Min', 0.5, 'Max', 10, ...
        'Value', params.sf_high - params.sf_low, 'Position', [150, control_height, 160, 20], ...
        'Callback', @(src,~) setBandwidth(src.Value));
    
    % Filter Order
    control_height = control_height - 40;
    uicontrol(paramFig, 'Style', 'text', 'String', 'Filter Order:', ...
        'Position', [30, control_height, 120, 20], 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.94, 0.94, 0.94]);
    
    order_text = uicontrol(paramFig, 'Style', 'text', ...
        'Position', [320, control_height, 60, 20], ...
        'String', num2str(params.butterworth_order), ...
        'HorizontalAlignment', 'right', 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    order_slider = uicontrol(paramFig, 'Style', 'slider', 'Min', 1, 'Max', 10, ...
        'Value', params.butterworth_order, 'Position', [150, control_height, 160, 20], ...
        'Callback', @(src,~) setOrder(src.Value));
    
    % Orientation Angles
    control_height = control_height - 60;
    uicontrol(paramFig, 'Style', 'text', 'String', 'Orientation Angles', ...
        'Position', [20, control_height, 360, 25], 'HorizontalAlignment', 'left', ...
        'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    % Horizontal Angle
    control_height = control_height - 30;
    uicontrol(paramFig, 'Style', 'text', 'String', 'Horizontal (0° = dim horizontal):', ...
        'Position', [30, control_height, 220, 20], 'HorizontalAlignment', 'left', ...
        'FontSize', 9, 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    h_angle_text = uicontrol(paramFig, 'Style', 'text', ...
        'Position', [320, control_height, 60, 20], ...
        'String', [num2str(params.horizontal_angle) '°'], ...
        'HorizontalAlignment', 'right', 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    h_angle_slider = uicontrol(paramFig, 'Style', 'slider', 'Min', -90, 'Max', 90, ...
        'Value', params.horizontal_angle, 'Position', [110, control_height, 200, 20], ...
        'Callback', @(src,~) setHorizontalAngle(src.Value));
    
    % Vertical Angle
    control_height = control_height - 30;
    uicontrol(paramFig, 'Style', 'text', 'String', 'Vertical (0° = dim vertical bars):', ...
        'Position', [30, control_height, 200, 20], 'HorizontalAlignment', 'left', ...
        'FontSize', 9, 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    v_angle_text = uicontrol(paramFig, 'Style', 'text', ...
        'Position', [280, control_height, 100, 20], ...
        'String', [num2str(params.vertical_angle) '°'], ...
        'HorizontalAlignment', 'right', 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    v_angle_slider = uicontrol(paramFig, 'Style', 'slider', 'Min', 0, 'Max', 180, ...
        'Value', params.vertical_angle, 'Position', [30, control_height-22, 240, 20], ...
        'Callback', @(src,~) setVerticalAngle(src.Value));
    
    % Oblique Angle
    control_height = control_height - 30;
    uicontrol(paramFig, 'Style', 'text', 'String', 'Oblique (fixed FFT 135° axis; σ=width):', ...
        'Position', [30, control_height, 280, 20], 'HorizontalAlignment', 'left', ...
        'FontSize', 9, 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    o_angle_text = uicontrol(paramFig, 'Style', 'text', ...
        'Position', [320, control_height, 60, 20], ...
        'String', [num2str(params.oblique_angle) '°'], ...
        'HorizontalAlignment', 'right', 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    o_angle_slider = uicontrol(paramFig, 'Style', 'slider', 'Min', 0, 'Max', 180, ...
        'Value', params.oblique_angle, 'Position', [110, control_height, 200, 20], ...
        'Callback', @(src,~) setObliqueAngle(src.Value));
    
    % Control visibility function
    function updateControlsVisibility()
        enableState = 'off';
        if params.enable_butterworth
            enableState = 'on';
        end
        set([center_sf_slider, center_sf_text, bandwidth_slider, bandwidth_text, order_slider, order_text], ...
            'Enable', enableState);
    end
    
    % Action Buttons
    control_height = control_height - 80;
    uicontrol(paramFig, 'Style', 'pushbutton', 'String', 'Start Debugging', ...
    'Position', [50, 50, 150, 40], 'FontSize', 12, 'FontWeight', 'bold', ...
    'BackgroundColor', [0.4, 0.8, 0.4], 'ForegroundColor', 'white', ...
    'Callback', @(~,~) startDebug());
    
    uicontrol(paramFig, 'Style', 'pushbutton', 'String', 'Cancel', ...
        'Position', [220, control_height, 100, 40], 'FontSize', 12, ...
        'BackgroundColor', [0.8, 0.4, 0.4], 'ForegroundColor', 'white', ...
        'Callback', @(~,~) cancelSetup());
    
    % Preset Buttons
    control_height = control_height - 60;
    uicontrol(paramFig, 'Style', 'text', 'String', 'Quick Presets:', ...
        'Position', [20, control_height+20, 120, 20], 'HorizontalAlignment', 'left', ...
        'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', [0.94, 0.94, 0.94]);
    
    uicontrol(paramFig, 'Style', 'pushbutton', 'String', 'H-Edge', ...
        'Position', [20, control_height, 60, 25], ...
        'Callback', @(~,~) setPreset('h_edge'));
    
    uicontrol(paramFig, 'Style', 'pushbutton', 'String', 'V-Edge', ...
        'Position', [85, control_height, 60, 25], ...
        'Callback', @(~,~) setPreset('v_edge'));
    
    uicontrol(paramFig, 'Style', 'pushbutton', 'String', 'O-Edge', ...
        'Position', [150, control_height, 60, 25], ...
        'Callback', @(~,~) setPreset('o_edge'));
    
    uicontrol(paramFig, 'Style', 'pushbutton', 'String', 'Lowpass', ...
        'Position', [215, control_height, 60, 25], ...
        'Callback', @(~,~) setPreset('lowpass'));
    
    uicontrol(paramFig, 'Style', 'pushbutton', 'String', 'Highpass', ...
        'Position', [280, control_height, 60, 25], ...
        'Callback', @(~,~) setPreset('highpass'));
    
    % Initialize visibility
    updateControlsVisibility();
    
    % Callback functions
    function setSigma(val)
        val = round(val * 10) / 10;
        params.sigma = val * (pi/180);
        set(sigma_value_text, 'String', [num2str(val) '°']);
    end
    
    function setFilterType(type)
        params.filter_type = type;
        set(h_radio, 'Value', type == 1);
        set(v_radio, 'Value', type == 2);
        set(o_radio, 'Value', type == 3);
    end
    
    function enableButterworth(val)
        params.enable_butterworth = val;
        updateControlsVisibility();
    end
    
    function setCenterSF(val)
        params.center_sf = val;
        set(center_sf_text, 'String', num2str(round(val*10)/10));
    end
    
    function setBandwidth(val)
        params.sf_low = max(0.1, params.center_sf - val/2);
        params.sf_high = params.center_sf + val/2;
        set(bandwidth_text, 'String', [num2str(round(params.sf_low*10)/10) '-' num2str(round(params.sf_high*10)/10)]);
    end
    
    function setOrder(val)
        params.butterworth_order = round(val);
        set(order_text, 'String', num2str(params.butterworth_order));
    end
    
    function setHorizontalAngle(val)
        params.horizontal_angle = round(val);
        set(h_angle_text, 'String', [num2str(params.horizontal_angle) '°']);
    end
    
    function setVerticalAngle(val)
        params.vertical_angle = round(val);
        set(v_angle_text, 'String', [num2str(params.vertical_angle) '°']);
    end
    
    function setObliqueAngle(val)
        params.oblique_angle = round(val);
        set(o_angle_text, 'String', [num2str(params.oblique_angle) '°']);
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
    
    function startDebug()
        proceed = true;
        % Store params in base workspace for access by main function
        assignin('base', 'testFilterParams', params);
        if isvalid(paramFig)
            uiresume(paramFig);
            delete(paramFig);
        end
    end
    
    function cancelSetup()
        proceed = false;
        if isvalid(paramFig)
            uiresume(paramFig);
            delete(paramFig);
        end
    end
    
    % Wait for user decision
    uiwait(paramFig);
end

function startFilterTesting()
    % Get parameters from base workspace
    if ~evalin('base', 'exist(''testFilterParams'', ''var'')')
        error('Parameters not found. Please run parameter setup first.');
    end
    params = evalin('base', 'testFilterParams');
    
    % Camera setup - VERIFIED 60FPS CONFIGURATION (but running at 1FPS for analysis)
    imaqreset;
    vid = videoinput('winvideo', 1, 'MJPG_640x480');
    src = getselectedsource(vid);
    
    % Set to your camera's 60fps mode (internally, but we'll display at 1FPS)
    try
        set(src, 'FrameRate', '60.0002');
    catch
        % If 60fps not available, use default
        fprintf('Could not set 60fps, using default frame rate\n');
    end
    fprintf('Camera set to: %s fps\n', get(src, 'FrameRate'));
    
    % Increase timeout for getsnapshot
    vid.Timeout = 10; % 10 second timeout
    
    % Image dimensions (fixed for this configuration)
    width = 640;
    height = 480;
    channels = 3;
    
    fprintf('Camera: %s\nResolution: %dx%d\nChannels: %d\n', ...
        vid.Name, width, height, channels);
    
    % GPU / CPU setup
    useGPU = false;
    try
        gpu = gpuDevice();
        useGPU = true;
        fprintf('Using GPU: %s\n', gpu.Name);
    catch
        warning('No compatible GPU found. Falling back to CPU processing.');
    end
    
    % Pre-compute frequency domain coordinates
    u = single(-floor(width/2):floor((width-1)/2));
    v = single(-floor(height/2):floor((height-1)/2));
    [U, V] = meshgrid(u, v);
    if useGPU
        U = gpuArray(U);
        V = gpuArray(V);
    end
    theta = atan2(V, U);
    
    % Create figure with comprehensive display
    f = figure('Name', 'Filter Testing - Images & Analysis', ...
        'NumberTitle', 'off', ...
        'Position', [100, 100, 1800, 900], ...
        'CloseRequestFcn', @(src, event) closeApp(), ...
        'Color', [0.94, 0.94, 0.94]);
    
    % ===== TOP ROW: Images =====
    % Original image panel
    originalPanel = uipanel(f, 'Position', [0.02, 0.50, 0.32, 0.48], ...
        'Title', 'Original Image', 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.98, 0.98, 0.98]);
    ax_original = axes('Parent', originalPanel, 'Position', [0.05, 0.05, 0.9, 0.9]);
    
    % Filtered image panel
    filteredPanel = uipanel(f, 'Position', [0.35, 0.50, 0.32, 0.48], ...
        'Title', 'Filtered Image', 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.98, 0.98, 0.98]);
    ax_filtered = axes('Parent', filteredPanel, 'Position', [0.05, 0.05, 0.9, 0.9]);
    
    % Filter Response visualization
    filterPanel = uipanel(f, 'Position', [0.68, 0.50, 0.30, 0.48], ...
        'Title', 'Active Filter Response', 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.98, 0.98, 0.98]);
    ax_filter = axes('Parent', filterPanel, 'Position', [0.10, 0.10, 0.85, 0.85]);
    
    % ===== BOTTOM ROW: Analysis Plots =====
    % Energy by orientation (original)
    energyOrigPanel = uipanel(f, 'Position', [0.02, 0.02, 0.32, 0.46], ...
        'Title', 'Energy by Orientation (Original)', 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.98, 0.98, 0.98]);
    ax_energy_orig = axes('Parent', energyOrigPanel, 'Position', [0.12, 0.10, 0.82, 0.85]);
    
    % Energy by orientation (filtered)
    energyFiltPanel = uipanel(f, 'Position', [0.35, 0.02, 0.32, 0.46], ...
        'Title', 'Energy by Orientation (Filtered)', 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.98, 0.98, 0.98]);
    ax_energy_filt = axes('Parent', energyFiltPanel, 'Position', [0.12, 0.10, 0.82, 0.85]);
    
    % Comparison plot
    comparisonPanel = uipanel(f, 'Position', [0.68, 0.02, 0.30, 0.46], ...
        'Title', 'Before vs After Comparison', 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.98, 0.98, 0.98]);
    ax_comparison = axes('Parent', comparisonPanel, 'Position', [0.12, 0.10, 0.82, 0.85]);
    
    % Take initial snapshot for display
    preview(vid);
    pause(1); % Give camera time to stabilize
    img = getsnapshot(vid);
    stoppreview(vid);
    pause(0.5); % Brief pause to ensure camera is ready
    
    imgDisplay_original = imshow(img, 'Parent', ax_original);
    title(ax_original, sprintf('Original RGB (%dx%d @ 60fps)', width, height), ...
        'FontSize', 10, 'FontWeight', 'bold');
    
    imgDisplay_filtered = imshow(img, 'Parent', ax_filtered);
    title(ax_filtered, sprintf('Filtered Output (%dx%d @ 60fps)', width, height), ...
        'FontSize', 10, 'FontWeight', 'bold');
    
    % Initialize plot handles
    plot_handle_energy_orig = [];
    plot_handle_energy_filt = [];
    plot_handle_comparison = [];
    plot_handle_filter = [];
    
    % Pre-allocate angle array for analysis (0 to 180 degrees)
    analysis_angles = 0:2:180;
    
    % Initialize variables
    H_orientation = [];
    frameCount = 0;
    tic; % Start timing for FPS calculation
    running = true;
    
    % Utility function
    function result = ternary(condition, true_val, false_val)
        if condition
            result = true_val;
        else
            result = false_val;
        end
    end
    
    % Update filter based on selected parameters
    function updateFilter()
        % Horizontal / vertical: single FFT notch via image line angle -> freq axis mod(line+90,180).
        % Oblique: narrow notch on FFT line at 135° / -45° only (see d_line below; avoids dimming H/V).
        notch_floor = single(0.12);
        ic = floor(height/2) + 1;
        jc = floor(width/2) + 1;
        
        if params.filter_type == 3
            % cos(theta-135°) is NOT zero at theta=0° or 90°, so H/V frequencies were still dimmed.
            % Notch only the undirected line through 135° and -45°: angular distance d_line in [0, pi/2],
            % then (1 - exp(-(d_line/sigma_eff)^4)) is ~0 on that line and ~1 at 0°, 45°, 90° for narrow sigma_eff.
            alpha = single(45 * (pi/180));
            d = theta - alpha;
            d = atan2(sin(d), cos(d));
            d_line = abs(d);
            d_line = min(d_line, single(pi) - d_line);
            sigma_eff = max(params.sigma * single(0.4), single(4 * pi / 180));
            k = exp(-((d_line ./ sigma_eff).^4));
            H_orientation = notch_floor + (1 - notch_floor) .* (1 - k);
        else
            if params.filter_type == 1
                image_line_deg = params.horizontal_angle;
            else
                % 0° = dim vertical bars; 90° = dim horizontal bars (tilt in between)
                image_line_deg = mod(90 - params.vertical_angle, 180);
            end
            angle_freq_deg = mod(image_line_deg + 90, 180);
            angle_rad_freq = single(angle_freq_deg * (pi/180));
            c = cos(theta - angle_rad_freq);
            % cos^4 vs cos^2: at 45° from notch axis cos^2=0.5 still kills obliques; cos^4 is much
            % smaller there so horizontal/vertical notches stay off 45°/135° diagonals.
            gauss = exp(-(c.^4) / (2 * params.sigma^2));
            H_orientation = notch_floor + (1 - notch_floor) * gauss;
        end
        H_orientation(ic, jc) = 1;
        
        if params.enable_butterworth
            U_cpd = U / (width/30);  % Assuming 30 deg FOV
            V_cpd = V / (height/20); % Assuming 20 deg FOV  
            sf = sqrt(U_cpd.^2 + V_cpd.^2);
            sf_filter = 1 ./ (1 + ((sf - params.center_sf) ./ ((params.sf_high - params.sf_low)/2)).^(2*params.butterworth_order));
            H_orientation = H_orientation .* sf_filter;
            H_orientation(ic, jc) = 1;
        end
    end
    
    function closeApp()
        running = false;
        delete(f);
    end
    
    function updatePerformanceMetrics()
        elapsed = toc;
        if elapsed > 1 % Update every second
            fps = frameCount / elapsed;
            fprintf('FPS: %.1f | Frames: %d\n', fps, frameCount);
            tic; % Reset timer
            frameCount = 0;
        end
    end
    
    % Function to compute energy at different orientations (OPTIMIZED)
    function energy_response = computeEnergyByOrientation(img_gpu, angles, theta_grid)
        % Compute the frequency domain representation - simplified for speed
        if isa(img_gpu, 'gpuArray')
            img_cpu = gather(img_gpu);
        else
            img_cpu = img_gpu;
        end
        
        % Convert to grayscale if RGB
        if size(img_cpu, 3) == 3
            img_gray = rgb2gray(uint8(img_cpu * 255));
        else
            img_gray = uint8(img_cpu * 255);
        end
        
        % Compute FFT once
        F = fft2(double(img_gray));
        F_shifted = fftshift(F);
        magnitude = abs(F_shifted);
        
        % Simplified energy computation - sample only key angles
        energy_response = zeros(1, length(angles), 'single');
        sigma_local = 15 * pi / 180; % Fixed orientation bandwidth
        
        % Get theta grid from parameter (not closure)
        if isa(theta_grid, 'gpuArray')
            theta_cpu = gather(theta_grid);
        else
            theta_cpu = theta_grid;
        end
        
        % Compute energy at each angle - vectorized
        for i = 1:length(angles)
            angle_rad = angles(i) * pi / 180;
            % Gaussian orientation selectivity
            H_orient = exp(-(cos(theta_cpu - angle_rad).^2) / (2 * sigma_local^2));
            
            % Compute energy for this orientation (simplified)
            filtered_mag = magnitude .* H_orient;
            energy_response(i) = sum(filtered_mag(:));
        end
        
        % Normalize
        max_energy = max(energy_response);
        if max_energy > 0
            energy_response = energy_response / max_energy;
        end
    end
    
    % Function to visualize filter response (SIMPLIFIED)
    function visualizeFilterResponse(H_filt, ax)
        if isa(H_filt, 'gpuArray')
            H_cpu = gather(H_filt);
        else
            H_cpu = H_filt;
        end
        
        % Simple 2D visualization of filter magnitude
        cla(ax);
        
        % Get center slices
        center_y = floor(size(H_cpu, 1) / 2) + 1;
        center_x = floor(size(H_cpu, 2) / 2) + 1;
        
        h_horz = H_cpu(center_y, :);
        h_vert = H_cpu(:, center_x);
        
        % Normalize for display
        x_axis = linspace(-180, 180, length(h_horz));
        y_axis = linspace(-180, 180, length(h_vert));
        
        plot(ax, x_axis, h_horz, 'b-', 'LineWidth', 2);
        hold(ax, 'on');
        plot(ax, y_axis, h_vert, 'r-', 'LineWidth', 2);
        
        grid(ax, 'on');
        set(ax, 'GridAlpha', 0.3);
        legend(ax, 'Horizontal', 'Vertical', 'FontSize', 8);
        title(ax, 'Filter Response', 'FontSize', 9, 'FontWeight', 'bold');
        ylabel(ax, 'Magnitude', 'FontSize', 8);
        set(ax, 'YLim', [0 1.1]);
        hold(ax, 'off');
    end
    
    % Initialize filter
    updateFilter();
    
    % OPTIMIZED Camera configuration for low computational load
    set(vid, 'FramesPerTrigger', 1);  % Get one frame at a time
    set(vid, 'TriggerRepeat', Inf);
    
    % Set buffers for reliability
    triggerconfig(vid, 'immediate');
    set(vid, 'TimerFcn', '');  % Remove any timer callbacks
    set(vid, 'TimerPeriod', 0.1);  % Relaxed timer period
    
    % Don't use preview in main loop - start camera fresh
    start(vid);
    
    % Brief warmup time
    pause(2);
    
    % Clear any initial frames
    while vid.FramesAvailable > 0
        getdata(vid, vid.FramesAvailable);
    end
    
    % Main loop - display both original and filtered at 1 FPS with analysis
    fprintf('Starting filter testing at 1 FPS (reduced for analysis)...\n');
    lastDisplayUpdate = tic;
    lastAnalysisUpdate = tic;
    frame_display_interval = 1; % Display every 1 second (1 FPS)
    analysis_display_interval = 2; % Analysis every 2 seconds
    
    while running
        try
            % Get frame from camera
            if isrunning(vid) && vid.FramesAvailable > 0
                % Get the most recent frame
                if vid.FramesAvailable > 1
                    oldFrames = getdata(vid, vid.FramesAvailable);
                    img = oldFrames(:,:,:,end);  % Keep only the most recent
                else
                    img = getdata(vid, 1);
                    if size(img, 4) > 0
                        img = img(:,:,:,end);
                    end
                end
                
                frameCount = frameCount + 1;

                % GPU-accelerated or CPU fallback RGB processing
                if useGPU
                    imgGPU = gpuArray(single(img) / 255);
                else
                    imgGPU = single(img) / 255;
                end

                % Apply orientation filter to each RGB channel separately
                filtered_img = applyOrientationFilterRGB(imgGPU, H_orientation);
                
                % Update display images at 1 FPS
                if toc(lastDisplayUpdate) > frame_display_interval
                    % Update original image
                    set(imgDisplay_original, 'CData', img);
                    
                    % Update filtered image
                    if useGPU
                        display_img_filtered = gather(filtered_img);
                    else
                        display_img_filtered = filtered_img;
                    end
                    set(imgDisplay_filtered, 'CData', display_img_filtered);
                    
                    % Update analysis plots less frequently (every 3 seconds)
                    if toc(lastAnalysisUpdate) > 3.0
                        try
                            % Compute energy by orientation (pass theta as parameter)
                            energy_orig = computeEnergyByOrientation(imgGPU, analysis_angles, theta);
                            energy_filt = computeEnergyByOrientation(filtered_img, analysis_angles, theta);
                            
                            % Get active angle
                            % Angle in image plane of the family being dimmed (for plot marker)
                            if params.filter_type == 1
                                active_angle = params.horizontal_angle;
                            elseif params.filter_type == 2
                                active_angle = mod(90 - params.vertical_angle, 180);
                            else
                                active_angle = 135;
                            end
                            
                            % Plot original energy
                            cla(ax_energy_orig);
                            bar(ax_energy_orig, analysis_angles, energy_orig, 'FaceColor', [0.2 0.6 1], 'EdgeColor', 'none', 'BarWidth', 0.95);
                            hold(ax_energy_orig, 'on');
                            line(ax_energy_orig, [active_angle active_angle], [0 1], 'Color', 'r', 'LineWidth', 2, 'LineStyle', '--');
                            hold(ax_energy_orig, 'off');
                            set(ax_energy_orig, 'XLim', [-5 185], 'YLim', [0 1.05]);
                            xlabel(ax_energy_orig, 'Orientation (degrees)', 'FontSize', 8);
                            ylabel(ax_energy_orig, 'Normalized Energy', 'FontSize', 8);
                            grid(ax_energy_orig, 'on');
                            set(ax_energy_orig, 'GridAlpha', 0.3);
                            
                            % Plot filtered energy
                            cla(ax_energy_filt);
                            bar(ax_energy_filt, analysis_angles, energy_filt, 'FaceColor', [0.2 0.8 0.2], 'EdgeColor', 'none', 'BarWidth', 0.95);
                            hold(ax_energy_filt, 'on');
                            line(ax_energy_filt, [active_angle active_angle], [0 1], 'Color', 'r', 'LineWidth', 2, 'LineStyle', '--');
                            hold(ax_energy_filt, 'off');
                            set(ax_energy_filt, 'XLim', [-5 185], 'YLim', [0 1.05]);
                            xlabel(ax_energy_filt, 'Orientation (degrees)', 'FontSize', 8);
                            ylabel(ax_energy_filt, 'Normalized Energy', 'FontSize', 8);
                            grid(ax_energy_filt, 'on');
                            set(ax_energy_filt, 'GridAlpha', 0.3);
                            
                            % Plot comparison
                            cla(ax_comparison);
                            plot(ax_comparison, analysis_angles, energy_orig, 'b-', 'LineWidth', 2, 'DisplayName', 'Original');
                            hold(ax_comparison, 'on');
                            plot(ax_comparison, analysis_angles, energy_filt, 'g-', 'LineWidth', 2, 'DisplayName', 'Filtered');
                            line(ax_comparison, [active_angle active_angle], [0 1], 'Color', 'r', 'LineWidth', 2, 'LineStyle', '--', 'DisplayName', 'Active');
                            hold(ax_comparison, 'off');
                            set(ax_comparison, 'XLim', [-5 185], 'YLim', [0 1.05]);
                            xlabel(ax_comparison, 'Orientation (degrees)', 'FontSize', 8);
                            ylabel(ax_comparison, 'Normalized Energy', 'FontSize', 8);
                            legend(ax_comparison, 'FontSize', 7, 'Location', 'NorthEast');
                            grid(ax_comparison, 'on');
                            set(ax_comparison, 'GridAlpha', 0.3);
                            
                            % Visualize the filter response
                            visualizeFilterResponse(H_orientation, ax_filter);
                            
                            fprintf('Analysis updated - Frame %d\n', frameCount);
                            lastAnalysisUpdate = tic;
                        catch analysis_error
                            fprintf('Analysis error: %s\n', analysis_error.message);
                        end
                    end
                    
                    lastDisplayUpdate = tic;
                    fprintf('Display updated - Frame %d\n', frameCount);
                end
                
                % Explicitly clear GPU memory to prevent accumulation
                clear imgGPU filtered_img;
                
                % Update performance metrics
                if mod(frameCount, 10) == 0
                    updatePerformanceMetrics();
                end
            else
                % No new frame available, yield briefly
                pause(0.1);
            end
            
            % Update display with error handling
            try
                drawnow limitrate; % Update display without blocking
            catch
                % If drawnow fails (e.g., GPU memory exhaustion), continue gracefully
            end
        catch exception
            if ~running || ~ishandle(f), break; end
            fprintf('Main loop error: %s\n', exception.message);
            pause(1);
        end
    end

    % Cleanup
    if exist('vid', 'var') && isvalid(vid)
        if isrunning(vid)
            stop(vid);
        end
        delete(vid);
    end
    if useGPU
        gpuDevice([]);
    end
    
    % Clean up base workspace
    evalin('base', 'clear testFilterParams');
    fprintf('Filter testing stopped.\n');
    
    % End of startFilterTesting function
end

function filtered_img = applyOrientationFilterRGB(imgRGB, H_orientation)
    % Apply orientation filter to each RGB channel separately
    % Input: imgRGB is HxWx3 on GPU or CPU
    % Output: filtered_img is HxWx3 on the same device as imgRGB
    
    % Pre-allocate output
    if isa(imgRGB, 'gpuArray')
        filtered_img = zeros(size(imgRGB), 'single', 'gpuArray');
    else
        filtered_img = zeros(size(imgRGB), 'single');
    end
    
    % Process each channel independently
    for channel = 1:3
        % Extract single channel
        single_channel = imgRGB(:,:,channel);
        
        % Apply frequency domain filtering
        F = fft2(single_channel);
        F_shifted = fftshift(F);
        F_filtered = F_shifted .* H_orientation;
        filtered_channel = real(ifft2(ifftshift(F_filtered)));
        
        % Normalize each channel independently
        ch_min = min(filtered_channel(:));
        ch_max = max(filtered_channel(:));
        filtered_channel = (filtered_channel - ch_min) / (ch_max - ch_min + eps('single'));
        
        % Store in output
        filtered_img(:,:,channel) = filtered_channel;
    end
end
