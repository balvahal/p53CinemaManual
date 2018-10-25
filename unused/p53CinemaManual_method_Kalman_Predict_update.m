%%
% * A = the model described by difference equations
% * B = the control input equation
% * H = the measurement equation
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
function kf = cellularGPSTracking_Kalman_Predict_update(kf)
kf.Xpri = kf.Xpost;
kf.Ppri = kf.Ppost;
end