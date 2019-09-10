function eyelid_detect(obj)
    id = obj.status.id;
           
    xmin = obj.roi_range.ori_x(id) + 1;
    xmax = obj.roi_range.ori_x(id) + obj.roi_range.width(id);
    ymin = obj.roi_range.ori_y(id) + 1;
    ymax = obj.roi_range.ori_y(id) + obj.roi_range.height(id);
    
    obj.eyelid_images{id}(:) = obj.frame_image(ymin:ymax, xmin:xmax);
    
    if ~obj.status.manual_override && obj.status.counter_enabled
        obj.calc_auto_eyelid_threshold();
    end
    
    obj.eyelid_images{id}(:) = obj.eyelid_images{id} < obj.status.eyelid_threshold(id);
    
    if ~obj.status.manual_override && obj.status.analyzed
        obj.eyelid_images{id}(:) = min(obj.eyelid_images{id}, obj.masks{id});
    end
    
    % ================================= CLEAN =============================
    
    total = sum(obj.eyelid_images{id}(:));
    
    if total <= 120
        obj.output.eyelid_start_y(id) = 0;
        obj.output.eyelid_height(id) = 0;
        return
    end
    
    seh = strel('line', 15, 0);
    sev = strel('line', 5, 90);
    
    obj.eyelid_images{id}(:) = imclose(obj.eyelid_images{id}, seh);
    obj.eyelid_images{id}(:) = imclose(obj.eyelid_images{id}, sev);
    
    CC = bwconncomp(obj.eyelid_images{id});

    for ind = 1 : length(CC.PixelIdxList)

        comp = CC.PixelIdxList{ind};

        if length(comp) < 0.1 * total
            obj.eyelid_images{id}(comp) = 0;
        else
            %[ys, xs] = ind2sub(CC.ImageSize, comp);
        end          
    end

    % =============================== HULL =============================
    
    
    
    if obj.status.record_flag && ~obj.status.counter_enabled
        obj.eyelid_images{id}(:) = bwconvhull(obj.eyelid_images{id});
    else
        obj.eyelid_images{id}(:) = bwconvhull(obj.eyelid_images{id}, 'objects');
    end
    
    % ============================== OUTPUT =============================
    
    [obj.output.eyelid_height(id), ind] = max(sum(obj.eyelid_images{id}, 1));
    
    for i = 1 : obj.roi_range.height(id)
        if obj.eyelid_images{id}(i, ind) == 1
            break
        end
    end
    
    obj.output.eyelid_start_y(id) = i;
    
    if ~obj.status.manual_override && obj.status.counter_enabled
         obj.accumulate_images{id} = obj.accumulate_images{id} + obj.eyelid_images{id};
         obj.status.accumulate_eyelid_threshold(id) = obj.status.accumulate_eyelid_threshold(id) + obj.status.eyelid_threshold(id);
    end
end