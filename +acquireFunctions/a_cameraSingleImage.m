classdef a_cameraSingleImage < acquireFunctions.cameraSingleImage_template
	methods
		function this = cameraSingleImage()
			
		end
		function [imageOut,timeOut] = getImages(this)

			% Start Acquisition thread
			CAM_width = 320;
			CAM_height = 256;
			imageSequenceNumber = 17;
			numImages = imageSequenceNumber + 1;
			[~,~] = pleoraAcquireFunctions.pleora_acquireMultipleImagesPersistent_v3(uint16(CAM_width),uint16(CAM_height),uint16(numImages));
			pause(0.2);
			
			% Get the images
			[collectedImageArray,timestampOut] = pleoraAcquireFunctions.pleora_acquireMultipleImagesPersistent_v3();
			timestamp = double(timestampOut).*480e-6/4;
			indBkg = find(abs(diff(timestamp)-3) < 0.1)+1;
			indBkg = mod(indBkg(1)-1,imageSequenceNumber)+1;
			indRef = mod(indBkg,imageSequenceNumber)+1;
			indSig = mod(indBkg+1,imageSequenceNumber)+1;
			
			collectedImageArray = double(reshape(collectedImageArray,[CAM_width CAM_height numImages]));
			
			bkgImage = collectedImageArray(:,:,indBkg)';
			if strcmp(this.referenceType,'kineticsReference')
				this.referenceImage = collectedImageArray(:,:,indRef)'-bkgImage;
			end
			sigImage = collectedImageArray(:,:,indSig)';
			
			% Find the indices of the bad pixels
			badPixelIndcs = find(double(bkgImage)<0.75*mean(bkgImage(:)) | double(bkgImage)>1.5*mean(bkgImage(:)));
			
			bkgImage(badPixelIndcs) = NaN;
			sigImage(badPixelIndcs) = NaN;
			
			imageOut = sigImage - bkgImage;
			
			% Normalize by variance of background image stripes
			%imageOut = imageOut./repmat(nanvar(bkgImage,0,1),256,1);
			
			timeOut = 0;
			acquireTypeOut = 'image';
			referenceImagesBoolean = false;
			
        end
    end
end