function update_record_status(obj)
global Xin

    obj.status.last_record_flag = obj.status.record_flag;
    obj.status.record_flag = Xin.D.Ses.Status;
    obj.frame_image(:) = Xin.D.Sys.PointGreyCam(1).DispImgOO;
    
    if ~obj.status.last_record_flag && obj.status.record_flag       % rec starts
        obj.status.counter_enabled = 1;
        obj.status.analyzed = 0;
        obj.status.frame_counter = 0;
        
        for id = 1 : obj.eye_num
            obj.masks{id}(:) = 0;
        end
        
    elseif ~obj.status.record_flag && obj.status.last_record_flag   % rec stops
        obj.status.counter_enabled = 0;
        obj.status.frame_counter = 0;
        
        for id = 1 : obj.eye_num
            obj.status.accumulate_eyelid_threshold(id) = 0;
            obj.accumulate_images{id}(:) = 0;    
        end
        
    else
        % as it is
    end
    
    if obj.status.counter_enabled
        if Xin.D.Ses.Load.DurCurrent > obj.status.MAX_TIME_SEC
        	obj.status.MAX_COUNT = obj.status.frame_counter;
            disp(obj.status.MAX_COUNT);
            obj.status.frame_counter = 0;
            obj.status.counter_enabled = 0;
            
            obj.analyze();
            obj.status.analyzed = 1;    % mask can be used
        else
            obj.status.frame_counter = obj.status.frame_counter + 1;
        end
    else
        % do nothing
    end
end

