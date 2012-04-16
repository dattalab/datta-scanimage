    function updateMFCRates()
        global state
        
        mfc1 = 100;
        mfc2 = 100;
        mfc3 = 100;
        mfc4 = 100;
        mfc5 = 500;
        mfc6 = 500;
        mfc7 = 500;
        mfc8 = 500;
        
        sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write BankFlow1_Actuator ' num2str(mfc1)]);
        sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write BankFlow2_Actuator ' num2str(mfc2)]);
        sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write BankFlow3_Actuator ' num2str(mfc3)]);
        sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write BankFlow4_Actuator ' num2str(mfc4)]);
        %
        sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write Carrier1_Actuator ' num2str(mfc5)]);
        sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write Carrier2_Actuator ' num2str(mfc6)]);
        sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write Carrier3_Actuator ' num2str(mfc7)]);
        sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write Carrier4_Actuator ' num2str(mfc8)]);
        
        return;
        
    end
