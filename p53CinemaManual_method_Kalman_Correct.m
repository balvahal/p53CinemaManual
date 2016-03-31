%%
% * A = the model described by difference equations
% * B = the control input equation
% * H = the measurement equation
% * I = identity matrix the size of the model
% * K = the Kalman gain% 
% * Ppri = a priori estimate error covariance
% * Ppredict = the predicted estimate error covariance
% * Ppost = a posteriori estimate error covariance
% * Q = the measurement noise covariance
% * R = the process noise covariance
% * U = the control input
% * Xpri = the current state
% * Xpredict = the predicted state
% * Xpost = the updated prediction
% * Z = the measured state to be compared to the predicted state
%
% update the measured state, Z
function kf = cellularGPSTracking_Kalman_Correct(kf)
kf.K = kf.Ppredict*transpose(kf.H)/(kf.H*kf.Ppredict*transpose(kf.H) + kf.R); %the division symbol is a matrix inverse operation in this case
kf.Xpost = kf.Xpredict + kf.K*(kf.Z - kf.H*kf.Xpredict);
kf.Ppost = (kf.I - kf.K*kf.H)*kf.Ppredict;
end