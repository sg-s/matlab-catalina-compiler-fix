% attempts to fix the mess Apple created
% in Catalina 
function fixBigSurCompiler()

if ~ismac
	disp('[abort] Not running on macOS')
	return

end

mex -setup c++

[~,a] = system('system_profiler SPSoftwareDataType');

if ~any(strfind(a,'macOS 11.'))
	disp('[abort] Not running on macOS Big Sur')
	return
end


m = mex.getCompilerConfigurations('C++');


lines = strsplit(fileread(m.MexOpt),'\n','CollapseDelimiters',false);
txt = lines(:);


bad_strings = {'10.15','10.15.1','10.15.2','10.15.3','10.15.4','10.15.5','10.15.6','10.15.sdk','$SDKVER','10.15.4.4','11.0'};


[status,good_string] = system('xcrun -sdk macosx --show-sdk-version');
assert(status==0,'Something went wrong running xcrun. Cannot proceed. Please report this bug. ')
good_string = strtrim(good_string);

for i = 1:length(bad_strings)
	for j = 1:length(txt)
		txt{j} = strrep(txt{j},bad_strings{i},good_string);
	end
end



fileID = fopen(m.MexOpt,'w');

for i = 1:length(txt)
	this_line = strrep(txt{i},'%','%%');
	this_line = strrep(this_line,'\','\\');
	fprintf(fileID, [this_line '\n']);
end

fclose(fileID);


