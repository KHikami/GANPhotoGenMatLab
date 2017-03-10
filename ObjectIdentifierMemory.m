classdef ObjectIdentifierMemory %this should be a value class....
    properties
        colorMap;
        shapeMap;
        iterationArray;
    end
    
    methods
        function obj = ObjectIdentifierMemory(color,shape)
            obj.colorMap = color;
            obj.shapeMap = shape;
            obj.iterationArray = [];
        end
        
        function obj = addIteration(mem, time)
            %new iteration to add is the size of the iterations array + 1
            iterationNum = numOfIterations(mem) + 1;
            newRow = [iterationNum time];
            mem.iterationArray = [mem.iterationArray; newRow];
            obj = mem;
        end
        
        function num = numOfIterations(mem)
            [L,~] =size(mem.iterationArray);
            num = L;
        end
        
        function num = averageIterationTime(mem)
            numOfIt = numOfIterations(mem);
            totalTime = sum(mem.iterationArray(:,2));
            num = totalTime/numOfIt;
        end
        
        function array = iterationPlot(mem)
            array = mem.iterationArray;
        end
        
        function obj = setMaps(mem, color, shape)
            mem.colorMap = color;
            mem.shapeMap = shape;
            obj = mem;
        end
    end
    
end