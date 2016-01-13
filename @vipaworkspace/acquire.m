function acquire(obj)
    h = msgbox('Acquiring Spectra','Acquiring...');%,'modal');
    
    n = 0;
    while ishandle(h)
        [images,time,acquireType] = obj.acquireFunction();
        
        % Send the image to the appropriate image object
        if ~strcmp(obj.acquiretab.imageDestTextField.Text,'none')
            imageobjid = {obj.acquiretab.imageDestTextField.Text};
            if ~strcmp(imageobjid,'none')
                switch obj.acquireOperation
                    case 'add'
                        obj.ImagesList.addImages(imageobjid,images,time);
                    case 'replace'
                        obj.ImagesList.setImages(imageobjid,images,time);
                    case 'average'
                        %obj.ImagesList.averageImages(imageobjid,images,time);
                    case 'averageWithRestart'
                        if n == 0
                            obj.ImagesList.clearImages(imageobjid,images,time);
                        end
                        obj.ImagesList.averageImages(imageobjid,images,time);
                    otherwise
                        error('Acquire Operation Not Defined')
                end
            end
        end
        
        if ~strcmp(obj.acquiretab.calibrationTextField.Text,'none')
            % Pass the image through the appropriate calibration object
            [wavenum,spectra] = obj.CalibrationList.createSpectra(1,images);

            % Send the image to the appropriate spectra object
            if ~strcmp(obj.acquiretab.spectraDestTextField.Text,'none')
                spectraobjid = {obj.acquiretab.spectraDestTextField.Text};
                switch obj.acquireOperation
                    case 'add'
                        obj.SpectraList.addSpectra(spectraobjid,spectra,time);
                    case 'replace'
                        obj.SpectraList.setSpectra(spectraobjid,spectra,time);
                    case 'average'
                        obj.SpectraList.averageSpectra(spectraobjid,wavenum,spectra,time);
                    case 'averageWithRestart'
                        if n == 0
                            obj.SpectraList.clearSpectra(spectraobjid,spectra,time);
                        end
                        obj.SpectraList.averageSpectra(spectraobjid,spectra,time);
                    otherwise
                        error('Acquire Operation Not Defined')
                end
            end
        end
        
        pause(0.1);
        disp(n);
        n = n+1;
    end
end