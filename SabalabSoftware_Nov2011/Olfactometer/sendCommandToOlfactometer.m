    function sendCommandToOlfactometer(olfactometerConn, command)
        global state gh;
        
        if isempty(olfactometerConn)
            connectToOlfactometer();
            olfactometerConn = state.olfactometer.olfactometerConnection;
            %No connection available (maybe the host has not been set).
            if isempty(olfactometerConn)
                return;
            end
        end
        
        pnet(olfactometerConn, 'printf', [command 10]);%Terminate with '\n'
        
        state.olfactometer.lastCommand = command;
        updateGUIByGlobal('state.olfactometer.lastCommand');
        
        % fprintf(1, 'OlfactoTrig/sendCommand: ''%s''\n', command);
        try
            response = pnet(olfactometerConn, 'readline');
            state.olfactometer.lastResponse = response;
            updateGUIByGlobal('state.olfactometer.lastResponse');
            
            if ~strcmpi(response, 'OK')
                set(gh.olfactometer.lastResponse, 'ForegroundColor', [1, 0, 0]);
            else
                set(gh.olfactometer.lastResponse, 'ForegroundColor', [0, 0, 0]);
            end
        catch
            fprintf(2, 'Failed to read response from Olfactometer: ''%s''\n', lasterr);
        end
        
        return;
    end
