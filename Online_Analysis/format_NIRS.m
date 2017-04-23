function [on_NIRS] = format_NIRS(data)  

 switch subj
            case 'MRA' %-----------------------------------------------------------
                % Dataset 001 -----------------------------------------------------
                    [RH_001, LH_001, F_001, ~] = nirx_channels(data);            

                    % C3_RH
                        RH_C3_001 = RH_001(:,[2,4]); % Reject channels C5, C9
                    % Cz_F
                        F_Cz_001 = [mean(F_001(:,1:2),2), F_001(:,4)]; % Reject channel C11     
                    % C4_LH
                        LH_C4_001 = [LH_001(:,4), LH_001(:,4)]; % Reject channels C15, C16, C19 
                                                                % Max 2 channels for all MRA datasets
            case 'JK' %------------------------------------------------------------
                % Dataset 001 -----------------------------------------------------
                    [RH_001, LH_001, F_001, ~] = nirx_channels(data);

                    % C3_RH
                        RH_C3_001 = [mean(RH_001(:,1:2),2), mean(RH_001(:,3:4),2)];     
                    % Cz_F
                        F_Cz_001 = [mean(F_001(:,1:2),2), mean(F_001(:,3:4),2)];             
                    % C4_LH   
                        LH_C4_001 = [mean(LH_001(:,1:2),2), mean(LH_001(:,3:4),2)]; 
            case 'NC' %------------------------------------------------------------
                % Dataset 001 -----------------------------------------------------
                    [RH_001, LH_001, F_001, ~] = nirx_channels(data);

                    % C3_RH
                        RH_C3_001 = [RH_001(:,4), RH_001(:,4)]; % Reject channels C5, C6, C9             
                                                                % Max 2 channels for all NC datasets
                    % Cz_F0
                        F_Cz_001 = F_001(:,[1,4]); % Reject channels C2, C11               
                    % C4_LH
                        LH_C4_001 = LH_001(:,[3,4]); % Reject channels C15, C16
 
            case 'SC' %------------------------------------------------------------
                % Dataset 001 -----------------------------------------------------
                    [RH_001, LH_001, F_001, ~] = nirx_channels(data);

                    % C3_RH
                        RH_C3_001 = [mean(RH_001(:,1:2),2), mean(RH_001(:,3:4),2)];           
                                                                
                    % Cz_F
                        F_Cz_001 = [mean(F_001(:,1:2),2), mean(F_001(:,3:4),2)];              
                    % C4_LH
                        LH_C4_001 = [mean(LH_001(:,1:2),2), mean(LH_001(:,3:4),2)];                      
        end

        % Create large matrices for each movement
        LH = single(LH_C4_001);
        F = single(F_Cz_001);
        RH = single(RH_C3_001);



end

