function out=tokenize(line, varargin)
%TOKENIZE   - Delimits input based on white spaces.
% 	TOKENIZE(line) will take the input string line and use white spaces (except
% 	those at the trailign ends which are removed with DEBLANK) to delimit the
% 	string tokens in line.  The output is a cell array of strings, each one
% 	being one of the tokens from the input line.
% 
% 	Ex:  out=tokenize('  aa aaa aaa  ')
% 
% 	out = 
%   	 'aa'    'aaa'    'aaa'
%
%   TOKENIZE(line, delimiter) - Tokenize based on a custom delimiter. (TO022706D).
%
%  
% See also STRTOK, DEBLANK
%
% Changes:
% 	TPMOD1 (2/4/04) - Commented Function.
%   TPMOD2 (3/23/04) - Added delimiter option.
%   TO022706D: Optimization(s). Complete rewrite. -- Tim O'Connor 2/27/06

% if isempty(varargin)
%     delimiterIndices = find(isspace(line));
% else
%     if length(varargin{1}) > 1
%         error('Delimiters may only be one character in length.');
%     end
%     delimiterIndices = find(line == varargin{1});
% end
% 
% delimiterIndices = [1 delimiterIndices(find(diff([1 delimiterIndices]) ~= 1))];
% 
% out = {};
% for i = 1 : 2 : length(delimiterIndices) - 1
%     out{i} = line(delimiterIndices(i) : delimiterIndices(i + 1) - 1);
% end
% 
% out{:}
% 
% return;

if nargin == 1
    delimiter = [9:13 32]; % White space characters;
else
    delimiter = varargin{1};
end

out={};
line=deblank(line);
line=fliplr(deblank(fliplr(line)));
while (length(line)>0)
	[token, line]=getToken(line,delimiter);
	if (length(token)>0)
		out{length(out)+1}=token;
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [token, remLine]=getToken(line,delimiter)
[token, remLine]=strtok(line,delimiter);
if length(token)==0
	return
end

if any(findstr(token,'''')) 
	while (length(remLine)>0) & (token(length(token))~='''') 
		[tok2, remLine]=strtok(remLine,delimiter);
		remLine=remLine(2:length(remLine));
		token=[token ' ' tok2];
	end
	if token(1)=='''' & token(length(token))==''''
		token=token(2:length(token)-1);
	end
end