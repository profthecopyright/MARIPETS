function analyze(obj)

  if ~obj.status.manual_override

      for id = 1 : obj.eye_num

          [height, width] = size(obj.masks{id});
          
          obj.masks{id}(:) = obj.accumulate_images{id} > 0.5 * obj.status.MAX_COUNT;
          
          total = sum(obj.masks{id}(:));

          CC = bwconncomp(obj.masks{id});

          for ind = 1 : length(CC.PixelIdxList)

              comp = CC.PixelIdxList{ind};

              if length(comp) < 0.4 * total
                  obj.masks{id}(comp) = 0;
              else
                  %[ys, xs] = ind2sub(CC.ImageSize, comp);
              end          
          end
                 
          obj.masks{id}(:) = obj.masks{id}...
              + [obj.masks{id}(21 : height, :); zeros(20, width)]...
              + [zeros(20, width); obj.masks{id}(1 : height - 20, :)];
          
          obj.masks{id}(:) = obj.masks{id} > 0;
          
          obj.status.eyelid_threshold(id) = ceil(obj.status.accumulate_eyelid_threshold(id) / obj.status.MAX_COUNT);
      end
   end
end

