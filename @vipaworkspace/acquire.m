function acquire(obj)
    h = msgbox('Acquiring Spectra','Acquiring...');%,'modal');
    
    n = 0;
    lastAcquire = now;
    while ishandle(h)
        [images,time,acquireType,refImagesBoolean] = obj.acquireFunction();
        acqTimeDiff = now - lastAcquire;
        lastAcquire = now;
        
        % Send the image to the appropriate image object
        if ~strcmp(obj.acquiretab.imageDestTextField.Text,'none')
            imageobjid = {obj.acquiretab.imageDestTextField.Text};
            if ~strcmp(imageobjid,'none')
                switch obj.acquireOperation
                    case 'add'
                        obj.ImagesList.addImages(imageobjid,images,time,refImagesBoolean);
                    case 'replace'
                        obj.ImagesList.setImages(imageobjid,images,time,refImagesBoolean);
                    case 'average'
                        obj.ImagesList.averageImages(imageobjid,images,time,refImagesBoolean);
                    case 'averageWithRestart'
                        if n == 0
                            obj.ImagesList.clearImages(imageobjid);
                        end
                        obj.ImagesList.averageImages(imageobjid,images,time,refImagesBoolean);
                    otherwise
                        error('Acquire Operation Not Defined')
                end
            end
        end
        
        if ~strcmp(obj.acquiretab.calibrationTextField.Text,'none')
            % Pass the image through the appropriate calibration object
            [wavenum,spectra,spectraTime] = obj.CalibrationList.createSpectra(1,images,time,refImagesBoolean);

            % Send the image to the appropriate spectra object
            if ~strcmp(obj.acquiretab.spectraDestTextField.Text,'none')
                spectraobjid = {obj.acquiretab.spectraDestTextField.Text};
                switch obj.acquireOperation
                    case 'add'
                        obj.SpectraList.addSpectra(spectraobjid,wavenum,spectra,[],spectraTime);
                    case 'replace'
                        obj.SpectraList.setSpectra(spectraobjid,wavenum,spectra,[],spectraTime);
                    case 'average'
                        obj.SpectraList.averageSpectra(spectraobjid,wavenum,spectra,[],spectraTime);
                    case 'averageWithRestart'
                        if n == 0
                            obj.SpectraList.clearSpectra(spectraobjid);
                        end
                        obj.SpectraList.averageSpectra(spectraobjid,wavenum,spectra,[],spectraTime);
                    otherwise
                        error('Acquire Operation Not Defined')
                end
            end
        end
        
        pause(0.1);
        if ishandle(h)
            h.Children(2).Children.String = sprintf('Acquired %i Spectra, %.1f Hz...',n,1/(acqTimeDiff*24*3600));
        end
        n = n+1;
    end
end