function [beta, fittedY] = LinearArrayFit( dataXin, dataYin, fitArray )
% LinearArrayFit - This function will fit an X and Y array to interpolated
% arrays defined in fitArrays. fitArrays should be a cell object
% containing X and Y values for all of the fit functions. beta contains the
% coefficients of the fitArrays functions.
%
% Example: fitArrays = {fitArray1_x, fitArray1_y, fitArray2_x, fitArray2_y}
%    to fit two functions to the data.
%
% If the x values of the fit do not match the x values of the data, the fit
%  function will be interpolated to match the data
%
% Jan 10, 2013  BJB

% Check the input parameters
if (size(fitArray,1) ~= 1 || mod(size(fitArray,2),2) ~= 0 || ~iscell(fitArray))
    error('The fitArray parameter is the wrong size. It should be a 1xn cell with n an even integer.');
end

fitindcs = find(~isnan(dataXin) & ~isnan(dataYin));
dataX = dataXin(fitindcs);
theMean = mean(dataYin(fitindcs));
dataY = dataYin(fitindcs)-theMean;

% Generate the fitting arrays, interpolating if necessary
numFitFuns = size(fitArray,2)/2;
fitMatrix = zeros(length(dataX),numFitFuns);
for i = 1:numFitFuns
   if length(fitArray{2*i}) == 1
      fitY = fitArray{2*1}(1)*ones(size(dataX));
   elseif all(size(fitArray{2*i-1}) == size(dataX)) && all(fitArray{2*i-1} == dataX)
      fitY = fitArray{2*i};
   else
      fitY = spline(fitArray{2*i-1},fitArray{2*i},dataX);
   end
   fitMatrix(:,i) = reshape(fitY,length(dataX),1);
end

% Normalize the stdev if necessary
stdNormFactor = std(fitMatrix,0,1);
stdNormFactor(isnan(stdNormFactor)) = 1;
stdNormFactor(stdNormFactor == 0) = 1;

% Perform the matrix division
beta = mldivide(fitMatrix./repmat(stdNormFactor,size(fitMatrix,1),1),reshape(dataY/std(dataY),length(dataX),1)).*std(dataY)./stdNormFactor';

% Construct the fitted array
fittedY = zeros(size(dataYin));
fittedY(fitindcs) = fitMatrix*beta+theMean;

end

