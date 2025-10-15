% Add GStreamer to MATLAB's path
gstreamer_path = ['C:\gstreamer\1.0\msvc_x86' ...
    '\bin'];
current_path = getenv('PATH');
if ~contains(current_path, gstreamer_path)
    setenv('PATH', [gstreamer_path ';' current_path]);
end