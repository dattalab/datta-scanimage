% @SCOPEOBJECT/removeChannel - Remove a channel from being displayed on this scope.
%
% SYNTAX
%  setChannelList(this)
%
% USAGE:This function is added to update the channel lists in the GUI.
% There are two popdown channel lists in the GUI. Once we perform the
% addChannel or removeChannel functions, the popdown channel lists should
% be updated with this function
%
% NOTES
%
% CHANGES
%
% Created 07/01/2007 Jinyang Liu
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005   

function setchannellist(this,varargin)
      global scopeObjects;
          Yh = findobj(scopeObjects(this.ptr).figure,...
               'Tag','YChanellistbox');
          Th= findobj(scopeObjects(this.ptr).figure,...
               'Tag','TChanellistbox');
          index = size(scopeObjects(this.ptr).bindings, 1);
          
          for i=1:index
            aa{i} = scopeObjects(this.ptr).bindings{i, 1};
          end;
          
          if index
              set( Yh, 'string', aa);
              set( Th,'string', aa);
          else
              set(Yh,'string','None');
              set(Th,'string','None');
          end
    end