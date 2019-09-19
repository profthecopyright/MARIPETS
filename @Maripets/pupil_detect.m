function pupil_detect(obj)

    id = obj.status.id;

    if obj.output.eyelid_height(id) < obj.pupil_range.min_opening(id)  
        obj.output.pupil_center_x(id) = 0;
        obj.output.pupil_center_y(id) = 0;
        obj.output.pupil_radius(id) = 0;
        obj.output.pupil_metric(id) = 0;
        obj.status.last_pupil_detected(id) = 0; 
    else
           
        if obj.status.last_pupil_detected(id)
            obj.pupil_range.ori_x(id) = obj.status.last_pupil_abs_x(id) - 50;
            obj.pupil_range.ori_y(id) = obj.status.last_pupil_abs_y(id) - 50;
            
            if obj.pupil_range.ori_x(id) < 1
                obj.pupil_range.ori_x(id) = 1;
            elseif obj.pupil_range.ori_x(id) > obj.frame_width - 100
                obj.pupil_range.ori_x(id) = obj.frame_width - 100;
            end

            if obj.pupil_range.ori_y(id) < 1
                obj.pupil_range.ori_y(id) = 1;
            elseif obj.pupil_range.ori_y(id) > obj.frame_height - 100
                obj.pupil_range.ori_y(id) = obj.frame_height - 100;
            end
            
            obj.pupil_range.width(id) = 100;
            obj.pupil_range.height(id) = 100;
            obj.pupil_range.min_radius(id) = max(floor(obj.status.last_pupil_r(id) - 5), obj.pupil_range.lower_bound(id));
            obj.pupil_range.max_radius(id) = min(ceil(obj.status.last_pupil_r(id) + 5), obj.pupil_range.upper_bound(id));  
        end
            
        xmin = obj.pupil_range.ori_x(id) + 1;
        xmax = obj.pupil_range.ori_x(id) + obj.pupil_range.width(id);
        ymin = obj.pupil_range.ori_y(id) + 1;
        ymax = obj.pupil_range.ori_y(id) + obj.pupil_range.height(id);
        
        [Gx, Gy] = imgradientxy(obj.frame_image(ymin:ymax, xmin:xmax), 'prewitt');
        Gmag = sqrt(Gx .* Gx + Gy .* Gy);
        
        max_mag = max(Gmag(:));
        Gmag(:) = Gmag / max_mag;
        mean_mag = mean(Gmag(:));
        
        Gmag(:) = Gmag > (mean_mag + 0.01);
        
        [centers, radii, metric] =...
        imfindcircles(logical(Gmag), [obj.pupil_range.min_radius(id) obj.pupil_range.max_radius(id)],...
        'ObjectPolarity', 'dark',...
        'Sensitivity', 0.9);

        if ~isempty(radii)
            obj.output.pupil_radius(id) = radii(1);
            obj.output.pupil_center_x(id) = centers(1, 1);
            obj.output.pupil_center_y(id) = centers(1, 2);
            obj.output.pupil_metric(id) = metric(1);

            rel_px = floor(obj.output.pupil_center_x(id));
            rel_py = floor(obj.output.pupil_center_y(id));
  
            obj.status.last_pupil_detected(id) = 1;
            obj.status.last_pupil_abs_x(id) = rel_px + obj.pupil_range.ori_x(id);
            obj.status.last_pupil_abs_y(id) = rel_py + obj.pupil_range.ori_y(id);
            obj.status.last_pupil_r(id) = obj.output.pupil_radius(id);     
        else
            obj.output.pupil_radius(id) = 0;
            obj.output.pupil_center_x(id) = 0;
            obj.output.pupil_center_y(id) = 0;
            obj.output.pupil_metric(id) = 0;
            obj.status.last_pupil_detected(id) = 0; 
        end
    end
end