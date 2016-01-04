classdef XmlOperations
    %CELLOPERATIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Static)
        % childNodes is a java type and hence is a handle class (no need to
        % return the childNodes again)
        function RemoveIndentNodes(childNodes)
            numNodes = childNodes.getLength;
            remList = [];
            for i = numNodes:-1:1
                theChild = childNodes.item(i-1);
                if (theChild.hasChildNodes)
                    XmlOperations.RemoveIndentNodes(theChild.getChildNodes);
                else
                    if ( theChild.getNodeType == theChild.TEXT_NODE && ...
                            ~isempty(char(theChild.getData()))         && ...
                            all(isspace(char(theChild.getData()))))
                        remList(end+1) = i-1; % java indexing
                    end
                end
            end
            for i = 1:length(remList)
                childNodes.removeChild(childNodes.item(remList(i)));
            end
        end
        
        function xmlobj = XmlReadRemoveIndents(filename)
            xmlobj = xmlread(filename);
            XmlOperations.RemoveIndentNodes(xmlobj);
        end
        
        function r = StringToVector3(string)
            array = regexp(string, ' ', 'split');
            assert(length(array) == 3, sprintf('Array string should contain 3 elements: %s', string));
            r = size(3, 1);
            for i = 1:3
                r(i,1) = str2double(array(i));
            end
        end
        
        function r = StringToVector(string)
            array = regexp(string, ' ', 'split');
            r = size(length(array), 1);
            for i = 1:length(array)
                r(i,1) = str2double(array(i));
            end
        end
    end
end
