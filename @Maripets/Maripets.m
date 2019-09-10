classdef Maripets < handle
    %MARIPETS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        eye_num
        roi_range
        pupil_range
        
        frame_width
        frame_height
        
        status
        output
        
        bright_pupil_frac
        dark_pupil_frac
        eyelid_hist
        eyelid_cumsum
        
        eyelid_starts
        eyelid_ends
        eyelid_images
        frame_image
        accumulate_images
        masks
    end
    
    methods       
        detect(obj)
               
        eyelid_detect(obj)
        pupil_detect(obj)
        repaint(obj)
        
        calc_auto_eyelid_threshold(obj)
        calc_eyelid_height(obj)
        
        update_record_status(obj)

        analyze(obj)
        refresh(obj)
        
        function obj = Maripets()
            obj.eye_num = 2;
            
            obj.frame_width = 752;
            obj.frame_height = 480;
            
%             obj.roi_range.ori_x = [40 300];
%             obj.roi_range.ori_y = [5 5];
            obj.roi_range.ori_x = [156 416];
            obj.roi_range.ori_y = 50*[1 1];
%             obj.roi_range.ori_y = [170 170];
            obj.roi_range.width = [180 180];
            obj.roi_range.height = [140 140];

            obj.pupil_range.ori_x = [156 416];
            obj.pupil_range.ori_y = [170 170];
            obj.pupil_range.width = [180 180];
            obj.pupil_range.height = [140 140];

            obj.pupil_range.min_radius = [20 20];
            obj.pupil_range.max_radius = [40 40];
            
            obj.pupil_range.lower_bound = [20 20];
            obj.pupil_range.upper_bound = [40 40];

            obj.pupil_range.min_opening = [20 20]; % min eyelid height for pupil detect
            
            obj.bright_pupil_frac = [0.06 0.06];
            obj.dark_pupil_frac = [0.06 0.06];
            obj.eyelid_hist = zeros(1, 256);
            obj.eyelid_cumsum = zeros(1, 256);
            
            obj.status.manual_override = 0;

            obj.status.eyelid_threshold = [50 50];
            obj.status.accumulate_eyelid_threshold = [0 0];
            obj.status.bright_pupil = [0 0];
            
            obj.status.id = 1;  % current eye
            obj.status.frame_counter = 0;
            obj.status.counter_enabled = 0;
            obj.status.analyzed = 0;
            obj.status.MAX_COUNT = 100;

            obj.status.MAX_TIME_SEC = 10;
            
            obj.status.record_flag = 0;
            obj.status.last_record_flag = 0;
            
            obj.status.last_pupil_detected = [0 0];
            obj.status.last_pupil_abs_x = [1 1];
            obj.status.last_pupil_abs_y = [1 1];
            obj.status.last_pupil_r = [30 30];
            
            obj.output.pupil_center_x = [1 1];
            obj.output.pupil_center_y = [1 1];
            obj.output.pupil_radius = [30 30];
            obj.output.pupil_metric = [0.5 0.5];
            obj.output.eyelid_start_y = [0 0];
            obj.output.eyelid_height = [1 1];
            
            
            
            obj.frame_image = zeros(obj.frame_height, obj.frame_width, 'uint8');
            obj.accumulate_images = cell(1, obj.eye_num);
            obj.masks = cell(1, obj.eye_num);
            
            for id = 1 : obj.eye_num
                obj.eyelid_starts{id} = zeros(1, obj.roi_range.width(id));
                obj.eyelid_ends{id} = zeros(1, obj.roi_range.width(id));
                obj.eyelid_images{id} = zeros(obj.roi_range.height(id), obj.roi_range.width(id));
                obj.accumulate_images{id} = zeros(obj.roi_range.height(id), obj.roi_range.width(id));
                obj.masks{id} = zeros(obj.roi_range.height(id), obj.roi_range.width(id));
            end
        end
    end
end

