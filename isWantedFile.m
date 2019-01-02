function isWanted = isWantedFile(f_name)
% Returns, whether input file name is valid or not

isWanted = 1;

% Set condition statement
c_statement = strcmp(f_name, '.') == 1 || strcmp(f_name, '..') || strcmp(f_name, '.DS_Store') || strcmp(f_name, '.info');

if c_statement == 1
    isWanted = 0;
end

end

