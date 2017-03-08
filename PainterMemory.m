classdef PainterMemory %this should be a value class....
    properties
        startingVector;
        vectorScore;
        iterationArray;
    end
    
    methods
        function obj = PainterMemory(vector, score, time)
            obj.startingVector = vector;
            obj.vectorScore = score;
            obj.iterationArray = [1 time];
        end

        function obj = addIteration(mem, time)
            iterationNum = numOfIterations(mem) + 1;
            newRow = [iterationNum time];
            mem.iterationArray = [mem.iterationArray; newRow];
            obj = mem;
        end
        
        function obj = updateBest(mem,v, score)
            mem.startingVector = v;
            mem.vectorScore = score;
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
        
    end
    
end