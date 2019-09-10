function calc_auto_eyelid_threshold(obj)
    
    id = obj.status.id;
    obj.eyelid_hist(:) = 0;
    
    for value = obj.eyelid_images{id}(:)
        ind = value + 1;
        obj.eyelid_hist(ind) = obj.eyelid_hist(ind) + 1;
    end
    
    
    if sum(obj.eyelid_hist) == 0
        obj.status.eyelid_threshold{id} = 0;
    else        

        obj.eyelid_cumsum(:) = cumsum(obj.eyelid_hist);

        for darkest_ind = 1:256
            if obj.eyelid_cumsum(darkest_ind) > 20
                break
            end
        end

        if darkest_ind > 240
            obj.status.eyelid_threshold(id) = 0;
        else
            base_ind = darkest_ind + 10;

            Nbase = obj.eyelid_cumsum(base_ind);

            if obj.status.bright_pupil(id)
                frac = obj.bright_pupil_frac(id);
            else
                frac = obj.dark_pupil_frac(id);
            end
            
            frac = frac + min(2000, Nbase) / 1000 * 0.1;

            Nrange = obj.eyelid_cumsum(end - 1) - obj.eyelid_cumsum(base_ind);
            Nthreshold = obj.eyelid_cumsum(base_ind) + floor(Nrange * frac);      

            for ind = base_ind + 1 : length(obj.eyelid_hist) - 1
                if obj.eyelid_cumsum(ind) >= Nthreshold
                    break
                end
            end

            obj.status.eyelid_threshold(id) = (ind - 1);
        end
    end
end

