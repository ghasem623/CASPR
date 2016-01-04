classdef CableSegmentKinematics < handle
    %CABLEKINEMATICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        numLinks = -1
    end
    
    properties
        r_OA = {}                   % Cell array of absolute attachment locations ^kr_{OA_{ijk}} for cable i segment j in local frame
        r_GA = {}                   % Cell array of relative attachment locations ^kr_{G_kA_{ijk}} from COG to attachment location for cable i segment j in local frame
        r_PA = {}                   % Cell array of relative attachment locations ^kr_{P_kA_{ijk}} from joint to attachment location for cable i segment j in local frame
%         attachmentsLocal = {}       % Cell array of relative attachment locations ^kr_{G_kA_{ijk}} for cable i segment j in local frame
%         attachmentsAbs = {}         % Cell array of absolute attachment locations ^kr_{OA_{ijk}} for cable i segment j in local frame
        segmentVector = []          % vectors \mathbf{l}_{ij} in frame {0}
        CRM = []                    % Cable Routing Matrix for this cable and segment
    end
    
    properties (Dependent)
        length
    end
        
    methods
        function ck = CableSegmentKinematics(numLinks, sLink, sLoc, eLink, eLoc, bodiesKin, attachmentRefType)
            assert(sLink <= numLinks+1, '"sLink" exceeds total number of links');
            assert(eLink <= numLinks+1, '"eLink" exceeds total number of links');
            
            ck.numLinks = numLinks;
            ck.segmentVector = [0;0;0];
            ck.CRM = zeros(1, numLinks+1);
            ck.r_PA = cell(1, numLinks+1);
            ck.r_PA(:) = {[0;0;0]};
            ck.r_GA = cell(1, numLinks+1);
            ck.r_GA(:) = {[0;0;0]};
            ck.r_OA = cell(1, numLinks+1);
            ck.r_OA(:) = {[0;0;0]};
            
            ck.CRM(sLink+1) = -1;
            ck.CRM(eLink+1) = 1;
            
            switch attachmentRefType
                case CableAttachmentReferenceType.COM
                    ck.r_GA{sLink+1} = sLoc;
                    ck.r_GA{eLink+1} = eLoc;
                    if sLink == 0
                        ck.r_PA{sLink+1} = ck.r_GA{sLink+1};
                    else
                        ck.r_PA{sLink+1} = bodiesKin.bodies{sLink}.r_G + ck.r_GA{sLink+1};
                    end
                    if eLink == 0
                        ck.r_PA{eLink+1} = ck.r_GA{eLink+1};
                    else
                        ck.r_PA{eLink+1} = bodiesKin.bodies{eLink}.r_G + ck.r_GA{eLink+1};
                    end
                case CableAttachmentReferenceType.JOINT
                    ck.r_PA{sLink+1} = sLoc;
                    ck.r_PA{eLink+1} = eLoc;
                    if sLink == 0
                        ck.r_GA{sLink+1} = ck.r_PA{sLink+1};
                    else
                        ck.r_GA{sLink+1} = -bodiesKin.bodies{sLink}.r_G + ck.r_PA{sLink+1};
                    end
                    if eLink == 0
                        ck.r_GA{eLink+1} = ck.r_PA{eLink+1};
                    else
                        ck.r_GA{eLink+1} = -bodiesKin.bodies{eLink}.r_G + ck.r_PA{eLink+1};
                    end
                otherwise
                    error('CableAttachmentReferenceType type is not defined');
            end
%             ck.attachmentsLocal{sLink+1} = sLoc;
%             ck.attachmentsLocal{eLink+1} = eLoc;
        end
        
        function c_k = getCRMTerm(obj, k)
            assert(k <= obj.numLinks+1, 'Invalid link number.');
            
            c_k = obj.CRM(k);
        end
        
        % NOT SURE HOW THIS IS USED YET, but just a demo of what can be
        % done
        function clear(obj)
            obj.CRM = zeros(1, obj.numLinks+1);
            obj.r_PA(:) = {[0;0;0]};
            obj.r_GA(:) = {[0;0;0]};
            obj.r_OA(:) = {[0;0;0]};
        end
        
        function value = get.length(obj)
            value = sqrt(sum(obj.segmentVector.^2));
%             value = norm(obj.segmentVector);
        end
    end
    
end