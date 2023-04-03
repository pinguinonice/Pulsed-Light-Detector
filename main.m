clc
clear all
close all

% Load the video file
v = VideoReader("fl7.mov");

% Get video properties
nframes = v.NumFrames; % number of frames
h = v.Height; % height of frames
w = v.Width; % width of frames
fps = nframes / v.Duration; % frames per second

% Define window size and step
win_size = 16; % number of frames in a window
win_step = 8; % number of frames to step between windows

% Define downscaled size
downscale_factor = 0.5; % percentage of original size to downscale to
% (e.g., 0.5 downscales to half the original size)

% Define frequency
f = 8; % frequency of interest in Hz
f_idx = round(f / fps * win_size) + 1; % index of the frequency of interest


% Loop over the video frames
for i = 1:win_step:nframes-win_size
    i
    
    % Read a 1-second window from the video
    frames_rgb = read(v, [i i+win_size-1]);
    
    % Downscale the frames
    frames_rgb = imresize(frames_rgb, downscale_factor, "box");
    
    % Convert to grayscale
    frames_gray = double(squeeze(frames_rgb(:,:,2,:)));

   
    % Compute the FFT of the pixel intensities over time
    frames_gray_list = reshape(frames_gray, [size(frames_gray,1)*size(frames_gray,2), win_size]); % reshape into a 2D matrix with pixels as rows and time as columns
    frames_list_spec = fft(normalize(frames_gray_list, 1, "center"), [], 2); % compute the FFT of the pixel intensities, normalized along the columns
    frames_spec = reshape(abs(frames_list_spec), [size(frames_gray,1), size(frames_gray,2), win_size]); % reshape back into 3D matrix with frames as 3rd dimension
    f_range = linspace(0, fps/2, win_size/2+1); % frequency range of FFT
    
    % calculate the image
    snr_threshold=2;
    frame=(frames_spec(:,:,f_idx)./mean(frames_spec(:,:,2:end),3));

    % Display the spectrum of a pixel over time
    figure(1);
    subplot(2,1,1); plot(frames_gray_list(10000,:));
    xlabel('Time (frames)'); ylabel('Pixel Intensity');
    
    subplot(2,1,2); hold off; plot(f_range, log(abs(frames_list_spec(10000,1:win_size/2+1)))); hold on; plot(f_range(f_idx),log(abs(frames_list_spec(10000,f_idx))),'ro')
    xlabel('Frequency (Hz)'); ylabel('Magnitude (log)');
    set(gcf,'color','w');

    
    %Display the magnitude spectrum and original frame
    figure(2)
    subplot(1,2,1);imagesc(frame); axis image
    title('Detection')
    colormap('jet')
    caxis([1.5,2.5])
    xlabel('X pixel'); ylabel('Y pixel');
    subplot(1,2,2); imshow(uint8(frames_rgb(:,:,:,1))); axis image
        title('Input Video')

    xlabel('X pixel'); ylabel('Y pixel');
    
    % Pause to display the image
    drawnow
end
