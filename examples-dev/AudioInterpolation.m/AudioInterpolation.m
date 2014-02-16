
%% Audio Application

N = 20;

%% Create two ordered sequences in time.
% We'll let r be more or less regularly spaced, and q be a somewhat more
% irregularly spaced sequence.

r =  cumsum(2*rand(N,1));  % (1:20)' + 0.1*randn(N,1);
q = cumsum(2*rand(N,1));

%% Plot q and r

plot(r,1*ones(N,1),'b.',q,2*ones(N,1),'r.','Markersize',25);
axis([0 max([q;r]) 0.5 2.5]);

%% Compute a least squares interpolation

% Norm weighting

W = diag(1./diff(q));

% Create D2
D = [eye(N-1),zeros(N-1,1)] - [zeros(N-1,1),eye(N-1)];
D2 = D'*W*D;

% Solve for interpolate for various values of alph
I = eye(N);

hold on;

for phi = 0.01:0.01:0.99;
    alpha = phi/(1-phi);
    sopt = (I+alpha*D2)\(r+alpha*D2*q);
    plot(sopt,(1+phi)*ones(N,1),'k.','Markersize',8);
end

hold off








