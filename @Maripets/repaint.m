function repaint(obj)

    id = obj.status.id;

    % ========================== paint roi lines ===================
     
    pupil_ymin = obj.roi_range.ori_y(id) + 1;
    pupil_ymax = obj.roi_range.ori_y(id) + obj.roi_range.height(id);
    
    pupil_xmin = obj.roi_range.ori_x(id) + 1;
    pupil_xmax = obj.roi_range.ori_x(id) + obj.roi_range.width(id);
    
    obj.frame_image(pupil_ymin:pupil_ymax, [pupil_xmin pupil_xmax]) = 0;
    obj.frame_image([pupil_ymin pupil_ymax], pupil_xmin:pupil_xmax) = 0;
     
    % ========================== paint eyelid lines ================

    if obj.status.counter_enabled
        color = 128;
    else
        color = 255;
    end
    
    sy = obj.output.eyelid_start_y(id);
    h = floor(obj.output.eyelid_height(id));

    pupil_ymin = obj.roi_range.ori_y(id) + sy;
    pupil_ymax = obj.roi_range.ori_y(id) + sy + h;
    
    if sy > 0      
        obj.frame_image(pupil_ymin, pupil_xmin:pupil_xmax) = color;
        obj.frame_image(pupil_ymax, pupil_xmin:pupil_xmax) = color;
    end

    % ========================== paint pupil lines =================

    if obj.output.pupil_radius(id) > 0
        
        color = (1 - obj.status.bright_pupil(id)) * 255;
        abs_x = obj.output.pupil_center_x(id) + obj.pupil_range.ori_x(id);
        abs_y = obj.output.pupil_center_y(id) + obj.pupil_range.ori_y(id);
        radius = obj.output.pupil_radius(id);

        pupil_xmin = round(max(abs_x - radius - 2, 1));
        pupil_xmax = round(min(abs_x + radius + 2, obj.frame_width));
        pupil_ymin = round(max(abs_y - radius - 2, 1));
        pupil_ymax = round(min(abs_y + radius + 2, obj.frame_height));
        
        pointer_xmin = round(max(abs_x - 5, 1));
        pointer_xmax = round(min(abs_x + 5, obj.frame_width));
        pointer_ymin = round(max(abs_y - 5, 1));
        pointer_ymax = round(min(abs_y + 5, obj.frame_height));
        
        obj.frame_image(pointer_ymin : pointer_ymax, [pupil_xmin pupil_xmax round(abs_x)]) = color;
        obj.frame_image([pupil_ymin pupil_ymax round(abs_y)], pointer_xmin : pointer_xmax) = color;
        
    end
end

