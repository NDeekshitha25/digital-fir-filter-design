%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIR Window Design
% Window-based FIR low-pass filter implementation and analysis in MATLAB.
% Includes custom FFT/IFFT, FIR convolution, frequency-response analysis,
% and comparison of multiple window functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;

N = 64;
k = (N)/2;
wc = pi/8;

%% Ideal LPF impulse response
h_d = zeros(1,N);
for i = 1:N
    j=i-1;
    if j == k 
        h_d(i) = wc/pi;
    else
        h_d(i) = (sin(wc*(j-k)))/(pi*(j-k));
    end
end

%% Defining the window functions
n = 0:N-1;
w_rect  = ones(1,N);
w_tri   = 1 - 2*abs(n-(N-1)/2)/(N-1);
w_hann  = 0.5 - 0.5*cos(2*pi*n/(N-1));
w_hamm  = 0.54 - 0.46*cos(2*pi*n/(N-1));
w_black = 0.42 - 0.5*cos(2*pi*n/(N-1)) + 0.08*cos(4*pi*n/(N-1));   

function [X]=FFT_Iterative(X_n,m)        % Iterative FFT function
    N = 2^m;
    rev=bitrevorder(1:N);
    X=X_n(rev);
    for s=1:m
        M=2^s;
        WM = exp((-1j)*(2*pi)/M);
        for k=1:M:N
            w=1;
            for p=0:(M/2)-1
                t=w*X(k+p+M/2);
                u=X(k+p);
                X(k+p)=u+t;
                X(k+p+M/2) = u-t;
                w = w*WM;
            end
        end
    end
    return;
end

function h_n=ifft(Y)            %% inverse fast fourier transformation
    N= length(Y);
    m = log2(N);
    h_n = conj(FFT_Iterative(Y,m))/N;
    return;
end

%% Apply window to get FIR filter coefficients
h_rect  = h_d .* w_rect;
h_tri   = h_d .* w_tri;
h_hann  = h_d .* w_hann;
h_hamm  = h_d .* w_hamm;
h_black = h_d .* w_black;
m = log2(N);

H_D = FFT_Iterative(h_d,m);
W_rect = FFT_Iterative(w_rect,m);
W_tri = FFT_Iterative(w_tri,m);
W_hann = FFT_Iterative(w_hann,m);
W_hamm = FFT_Iterative(w_hamm,m);
W_black = FFT_Iterative(w_black,m);

%% Convolution in frequency domain
H_rect = H_D.*W_rect;
H_tri = H_D.*W_tri;
H_hann = H_D.*W_hann;
H_hamm = H_D.*W_hamm;
H_black = H_D.*W_black;

h_fft_rect = real(ifft(H_rect));
h_fft_tri = real(ifft(H_tri));
h_fft_hann = real(ifft(H_hann));
h_fft_hamm = real(ifft(H_hamm));
h_fft_black = real(ifft(H_black));

%% Defining the input signal and adding noise to it
fs = 2000;
m = 0:1/fs:1e-1;  % cut-off = 125Hz as wc = pi/8
f1 = 50;   % inside passband
f2 = 120;  % clode to the cut-off, transition region behaviour
f3 = 300;  % stopband
x = sin(2*pi*f1*m) + sin(2*pi*f2*m) + sin(2*pi*f3*m);
noise_mean = 0;
noise_variance = 5;
noise = noise_mean + sqrt(noise_variance)*randn(size(x));
sig = x +noise;

function y = my_filter(h, x)
    N = length(h);      % filter length
    L = length(x);      % input length
    y = zeros(1, L);    % output init

    % FIR filtering (convolution sum)
    for n = 1:L
        for k = 1:N
            if (n-k+1) > 0
                y(n) = y(n) + h(k) * x(n-k+1);
            end
        end
    end
end


%% Output signal using each window function
output_rect = my_filter(h_rect,sig);
output_tri = my_filter(h_tri,sig);
output_hann = my_filter(h_hann,sig);
output_hamm = my_filter(h_hamm,sig);
output_black = my_filter(h_black,sig);

%% Expected output
expected_out = sin(2*pi*f1*m)+sin(2*pi*f2*m);

[h_freq_rect,w_freq_rect] = freqz(h_rect,1,1024,fs);
[h_freq_tri,w_freq_tri] = freqz(h_tri,1,1024,fs);
[h_freq_hann,w_freq_hann] = freqz(h_hann,1,1024,fs);
[h_freq_hamm,w_freq_hamm] = freqz(h_hamm,1,1024,fs);
[h_freq_black,w_freq_black] = freqz(h_black,1,1024,fs);

%% Transition width
Hmag = abs(h_freq_hamm)/max(abs(h_freq_hamm));
% --- find -3 dB point (idx3)
% find main-lobe peak index (should be near DC)
% find main-lobe peak index (near DC)
[~, idx_main] = max(Hmag);

% find all peaks in the normalized magnitude
[pks_all, locs_all] = findpeaks(Hmag);

% keep only peaks that lie to the right (higher frequency) of the main lobe
locs_after = locs_all(locs_all > idx_main);
pks_after  = pks_all(locs_all > idx_main);

if isempty(locs_after)
    disp('No side-lobe peaks found after main lobe.');
    first_sidelobe = NaN;
    first_sidelobe_dB = NaN;
    first_idx = NaN;
else
    % first side-lobe is the first peak after main lobe
    first_idx = locs_after(1);
    first_sidelobe = Hmag(first_idx);                % linear
    first_sidelobe_dB = 20*log10(first_sidelobe);    % dB relative to main
end

% compute -3 dB cutoff: first index where Hmag <= 1/sqrt(2)
idx3 = find(Hmag <= 1/sqrt(2),1);
if isempty(idx3)
    f3dB = NaN;
else
    f3dB = w_freq_black(idx3);
end

% find first null (local minimum) that lies between main peak and first side-lobe
% locate minima by finding peaks of -Hmag
[~, minima_locs] = findpeaks(-Hmag);
min_between = minima_locs(minima_locs > idx_main & minima_locs < first_idx);
if isempty(min_between)
    fnull = NaN;
else
    fnull = w_freq_hamm(min_between(1));
end

% Transition width
if isnan(f3dB) || isnan(fnull)
    TW = NaN;
else
    TW = fnull - f3dB;
end

% Max stopband attenuation = largest magnitude after the first side-lobe (converted to dB)
if isnan(first_idx)
    max_stopband_att = NaN;
else
    if first_idx+1 <= length(Hmag)
        max_stop = max(Hmag(first_idx+1:end));
    else
        max_stop = 0;
    end
    if max_stop == 0
        max_stopband_att = Inf;
    else
        max_stopband_att = -20*log10(max_stop);
    end
end


%% Signal & noise amplitude 
clean_out = filter(h_hamm,1,x);    % only cleans sinusoid, not noise
residual_noise = output_hamm - clean_out;
A_signal = max(abs(clean_out));    % amplitude of desired sinusoid
A_noise = max(abs(residual_noise));  % amplitude of unwanted part

%% snr
if A_noise == 0
    snr = Inf;
else
    snr = 20*log10(A_signal / A_noise);
end

%% Plot for magnitude response
figure;
plot(w_freq_rect,20*log10(abs(h_freq_rect))); hold on;
plot(w_freq_tri,20*log10(abs(h_freq_tri)));
plot(w_freq_hann,20*log10(abs(h_freq_hann)));
plot(w_freq_hamm,20*log10(abs(h_freq_hamm)));
plot(w_freq_black,20*log10(abs(h_freq_black)));
legend('Rectangular','Triangular','Hanning','Hamming','Blackman');
title('Magnitude Responses of the windows');
xlabel('Frequency (Hz)'); 
ylabel('Magnitude(dB)');
grid on;

%% Plot for ideal impulse response
figure;
stem(0:N-1,h_d);
title('Ideal Impulse Response (causal)');
xlabel('n'); ylabel('h_d(n)');
grid on;

%% Plot for windowes FIR impulse response
figure;
plot(0:N-1,h_rect, 'DisplayName','Rectangular'); hold on;
plot(0:N-1,h_tri, 'DisplayName','Triangular');
plot(0:N-1,h_hann, 'DisplayName','Hanning');
plot(0:N-1,h_hamm, 'DisplayName','Hamming');
plot(0:N-1,h_black, 'DisplayName','Blackman');
legend show;
title('Windowed FIR Impulse Responses (causal)');
xlabel('n'); ylabel('h(n)');
grid on;

%% Input signal, Expected vs fir output
figure;
subplot(3,1,1);
plot(m,sig);
title('Input Signal');
subplot(3,1,2);
plot(m,expected_out,'DisplayName','Ideal Output'); hold on;
plot(m,output_rect,'DisplayName','Rectangular FIR Output');
legend show;
title('Expected vs FIR Output');
subplot(3,1,3);
delay = (N)/2;
aligned_output = [output_rect(delay+1:end), zeros(1,delay)];
plot(m,expected_out,'DisplayName','Ideal Output'); hold on;
plot(m,aligned_output(1:length(m)),'DisplayName','Aligned output'); 
legend show;
title('Excpected vs FIR Output (Delay alignment)');
grid on;

figure;
subplot(3,1,1);
plot(m,sig);
title('Input Signal');
subplot(3,1,2);
plot(m,expected_out,'DisplayName','Ideal Output'); hold on;
plot(m,output_tri,'DisplayName','Triangular FIR Output');
legend show;
title('Expected vs FIR Output');
subplot(3,1,3);
delay = (N)/2;
aligned_output = [output_tri(delay+1:end), zeros(1,delay)];
plot(m,expected_out,'DisplayName','Ideal Output'); hold on;
plot(m,aligned_output(1:length(m)),'DisplayName','Aligned output'); 
legend show;
title('Excpected vs FIR Output (Delay alignment)');
grid on;

figure;
subplot(3,1,1);
plot(m,sig);
title('Input Signal');
subplot(3,1,2);
plot(m,expected_out,'DisplayName','Ideal Output'); hold on;
plot(m,output_hann,'DisplayName','Hanning FIR Output');
legend show;
title('Expected vs FIR Output');
subplot(3,1,3);
delay = (N)/2;
aligned_output = [output_hann(delay+1:end), zeros(1,delay)];
plot(m,expected_out,'DisplayName','Ideal Output'); hold on;
plot(m,aligned_output(1:length(m)),'DisplayName','Aligned output'); 
legend show;
title('Excpected vs FIR Output (Delay alignment)');
grid on;

figure;
subplot(3,1,1);
plot(m,sig);
title('Input Signal');
subplot(3,1,2);
plot(m,expected_out,'DisplayName','Ideal Output'); hold on;
plot(m,output_hamm,'DisplayName','Hamming FIR Output');
legend show;
title('Expected vs FIR Output');
subplot(3,1,3);
delay = (N)/2;
aligned_output = [output_hamm(delay+1:end), zeros(1,delay)];
plot(m,expected_out,'DisplayName','Ideal Output'); hold on;
plot(m,aligned_output(1:length(m)),'DisplayName','Aligned output'); 
legend show;
title('Excpected vs FIR Output (Delay alignment)');
grid on;

figure;
subplot(3,1,1);
plot(m,sig);
title('Input Signal');
subplot(3,1,2);
plot(m,expected_out,'DisplayName','Ideal Output'); hold on;
plot(m,output_black,'DisplayName','Blackman FIR Output');
legend show;
title('Expected vs FIR Output');
subplot(3,1,3);
delay = (N)/2;
aligned_output = [output_black(delay+1:end), zeros(1,delay)];
plot(m,expected_out,'DisplayName','Ideal Output'); hold on;
plot(m,aligned_output(1:length(m)),'DisplayName','Aligned output'); 
legend show;
title('Excpected vs FIR Output (Delay alignment)');
grid on;
