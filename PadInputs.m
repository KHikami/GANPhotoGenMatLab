function [newMap1, newMap2] = PadInputs (map1, map2)

[m1h, m1w, m1d] = size(map1);
[m2h, m2w, m2d] = size(map2);

assert(m1d == m2d);

newMap1 = map1;
newMap2 = map2;

if(m1h < m2h)
    %map 1 has fewer rows
    diff = m2h - m1h;
    zerosRow = zeros(1,m1w,m1d);
    newMap1 = [newMap1; repmat(zerosRow, [diff 1])];
else
    diff = m1h - m2h;
    zerosRow = zeros(1,m2w, m2d);
    newMap2 = [newMap2; repmat(zerosRow, [diff 1])];
end

%need to manipulate based on the new heights!
n1h = size(newMap1,1);
n2h = size(newMap2,1);

if(m1w < m2w)
    %map1 has fewer columns
    diff = m2w - m1w;
    zerosCol = zeros(n1h, 1, m1d);
    newMap1 = [newMap1 repmat(zerosCol, [1 diff])];
else
    diff = m1w - m2w;
    zerosCol = zeros(n2h, 1, m2d);
    newMap2 = [newMap2 repmat(zerosCol, [1 diff])];
end