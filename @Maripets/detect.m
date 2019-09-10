function detect(obj)
global Xin
    obj.update_record_status();
    
    for id = 1 : obj.eye_num
        obj.status.id = id;
        obj.eyelid_detect();
        
        obj.pupil_detect();
        
        obj.repaint();
    end

    Xin.D.Sys.PointGreyCam(1).DispImgOO(:) = obj.frame_image;
    
end

