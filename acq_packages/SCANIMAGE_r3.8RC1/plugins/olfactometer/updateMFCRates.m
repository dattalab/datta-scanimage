    function updateMFCRates(flowRate)
        global state
        if nargin<1
            carrierRate = 1000;
            odorRate = 60;
        end
        
        if nargin == 1
        %--0.5 lpm-- 1:10 odor:carrier
            %mfc1-4:40
            %mfc5-8:130
        %--1 lpm-- default 1:10 odor:carrier
            %mfc1-4:55
            %mfc5-8:245
        %--2 lpm -- 1:10 odor:carrier
            %mfc1-4:90
            %mfc5-8:475
            if flowRate== 0.5
            carrierRate = 130; % should yield 450 ml/min
            odorRate = 40; % should yield 50 ml/min
            end
               
             if flowRate==1
            carrierRate = 245; % should yield 900 ml/min
            odorRate = 55;     % should yield 100 ml/min
      
             end 
       
             if flowRate== 2
            carrierRate = 475;  % should yield 1800 ml/min
            odorRate = 50; % should yield 200 ml/min
             end
        end
    
        mfc1 = odorRate;
        mfc2 = odorRate;
        mfc3 = odorRate;
        mfc4 = odorRate;  
       
        mfc5 = carrierRate;
        mfc6 = carrierRate;
        mfc7 = carrierRate;
        mfc8 = carrierRate;
     
       
        %mfc1 = odor;
        %mfc2 = odor;
        %mfc3 = odor;
        %mfc4 = odor;
        %mfc5 = carrier;
        %mfc6 = carrier;
        %mfc7 = carrier;  
        %mc8 = carrier;
        
        sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write BankFlow1_Actuator ' num2str(mfc1)]);
        sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write BankFlow2_Actuator ' num2str(mfc2)]);
        %sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write BankFlow3_Actuator ' num2str(mfc3)]);
        %sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write BankFlow4_Actuator ' num2str(mfc4)]);
        %
        sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write Carrier1_Actuator ' num2str(mfc5)]);
        sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write Carrier2_Actuator ' num2str(mfc6)]);
        %sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write Carrier3_Actuator ' num2str(mfc7)]);
        %sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write Carrier4_Actuator ' num2str(mfc8)]);
        
        return;
        
    end
