classdef ObjectIdentifierMemory %this should be a value class....
    properties
        colorMap;
        shapeMap;
        colorWeight = 0.5;
        shapeWeight = 0.5;
        iterationArray;
    end
    
    methods
        function obj = ObjectIdentifierMemory(color,shape)
            obj.colorMap = color;
            obj.shapeMap = shape;
            obj.iterationArray = [];
        end
        
        function [newCWeight, newSWeight] = updateWeights(mem, c,s)
            mem.colorWeight = c;
            mem.shapeWeight = s;
            newCWeight = mem.colorWeight;
            newSWeight = mem.shapeWeight;
        end
        
        function obj = addIteration(mem, time)
            %new iteration to add is the size of the iterations array + 1
            iterationNum = numOfIterations(mem) + 1;
            newRow = [iterationNum time];
            mem.iterationArray = [mem.iterationArray; newRow];
            obj = mem;
        end
        
        function num = numOfIterations(mem)
            [L,W] = size(mem.iterationArray);
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