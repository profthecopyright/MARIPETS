function calc_eyelid_height(obj) % deprecated
    id = obj.status.id;

    width = obj.roi_range.width(id);
    height = obj.roi_range.height(id);
    
    obj.eyelid_starts{id}(:) = 1;
    obj.eyelid_ends{id}(:) = 1;
    
    for i = 1 : width
        max_pw = 0;

        is_in_eye = obj.eyelid_images{id}(1, i);

        for j = 2 : height
            if obj.eyelid_images{id}(j, i) == 1 && j ~= height
               if ~is_in_eye    % ascending edge detected
                   is_in_eye = 1;
                   obj.eyelid_starts{id}(i) = j;
               end
            elseif j == height
               continue;
            else % roi_BW(j, i) == 0 && j ~= height
               if is_in_eye
                   is_in_eye = 0;
                   obj.eyelid_ends{id}(i) = j;
                   current_w = obj.eyelid_ends{id}(i) - obj.eyelid_starts{id}(i);

                   if current_w > max_pw
                       max_pw = current_w;
                   end
               end
            end         
        end

    end

    [max_h, eyelid_start_x] = max(obj.eyelid_ends{id} - obj.eyelid_starts{id});
    obj.output.eyelid_start_y(id) = obj.eyelid_starts{id}(eyelid_start_x);
    obj.output.eyelid_height(id) = max_h; 
end

