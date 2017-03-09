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
            avgScore = averageScore(obj);
            obj.iterationArray = [1 time avgScore];
        end

        function obj = addIteration(mem, time)
            iterationNum = numOfIterations(mem) + 1;
            avgScore = averageScore(mem);
            newRow = [iterationNum time avgScore];
            mem.iterationArray = [mem.iterationArray; newRow];
            obj = mem;
        end
        
        function obj = updateBest(mem,v, score)
            mem.startingVector = v;
            mem.vectorScore = score;
            obj = mem;
        end
        
        function num = averageScore(mem)
           [sh, sw] = size(mem.vectorScore);
           totalScore = sum(reshape(mem.vectorScore, 1,sh*sw));
           num = totalScore/(sh*sw);
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
        
        function array = iterationTimePlot(mem)
            it = mem.iterationArray(:,1);
            times = mem.iterationArray(:,2);
            array = [it times];
        end
        
        function array = iterationScorePlot(mem)
            it = mem.iterationArray(:,1);
            scores = mem.iterationArray(:,3);
            array = [it scores];
        end
        
    end
    
end