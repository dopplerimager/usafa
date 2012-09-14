

;\\ CLEANUP ROUTINES
pro AFA_cleanup, misc, console

	;\\ Close up the com ports
	comms_wrapper, misc.port_map.cal_source.number, misc.dll_name, type = 'moxa', /close, errcode=errcode
	console->log, 'Close Calibration Source Port: ' + string(errcode, f='(i0)'), 'InstrumentSpecific'
	comms_wrapper, misc.port_map.mirror.number, misc.dll_name, type = 'moxa', /close, errcode=res1
	console->log, 'Close Mirror Port: ' + string(errcode, f='(i0)'), 'InstrumentSpecific'
	comms_wrapper, misc.port_map.filter.number, misc.dll_name, type = 'moxa', /close, errcode=res2
	console->log, 'Close Filter Port: ' + string(errcode, f='(i0)'), 'InstrumentSpecific'
	comms_wrapper, misc.port_map.etalon.number, misc.dll_name, type = 'moxa', /close, errcode=res3
	console->log, 'Close Etalon Port: ' + string(errcode, f='(i0)'), 'InstrumentSpecific'

	;\\ Sometimes the ports won't close properly, so use the devcon utility to restart the Moxa device
	if res1 ne 0 or res2 ne 0 or res3 ne 0 then begin
		restart_moxa
	endif
end




;\\ MIRROR ROUTINES
pro AFA_mirror,  drive_to_pos = drive_to_pos, $
				 home_motor = home_motor, $
				 read_pos = read_pos,  $
				 misc, console

	;\\ Stop the camera while we move the mirror:
	   	res = call_external(misc.dll_name, 'uAbortAcquisition')

	;\\ Misc stuff
		port = misc.port_map.mirror.number
		dll_name = misc.dll_name
		tx = string(13B)

	;\\ Set current limits
		comms_wrapper, port, dll_name, type='moxa', /write, data = 'LCC800'  + tx ;\\ set these here to be safe...
		comms_wrapper, port, dll_name, type='moxa', /write, data = 'LPC1200' + tx

	;\\ Drive to sky or cal position:
		if keyword_set(drive_to_pos) then begin
			;\\ Notify that we are changing the mirror position
				base = widget_base(col=1, group=misc.console_id, /floating)
				info = widget_label(base, value='Driving Mirror to ' + string(drive_to_pos, f='(i0)'), font='Ariel*20*Bold')
				widget_control, /realize, base

				res = drive_motor(port, dll_name, drive_to = drive_to_pos, speed = 1500)
				read_pos = drive_motor(port, dll_name, /readpos)

			;\\ Close notification window
				if widget_info(base, /valid) eq 1 then widget_control, base, /destroy
		endif


	;\\ Home to the sky or calibration positions
		if keyword_set(home_motor) then begin

			;\\ Notify that we are homing the mirror
				base = widget_base(col=1, group=misc.console_id, /floating)
				info = widget_label(base, value='Homing Mirror to ' + home_motor, font='Ariel*20*Bold')
				widget_control, /realize, base

		    if strlowcase(home_motor) eq 'sky' then direction = 'forwards'
		    if strlowcase(home_motor) eq 'cal' then direction = 'backwards'

			ntries = 0
			GO_HOME_MOTOR_START:

				pos1 = drive_motor(port, dll_name, /readpos)
				res  = drive_motor(port, dll_name, direction = direction, speed = 800., home_max_spin_time = 3.)
				pos2 = drive_motor(port, dll_name, /readpos)
				ntries = ntries + 1

			if abs(pos2 - pos1)/1000. gt .3 or ntries lt 2 then goto, GO_HOME_MOTOR_START
			read_pos = drive_motor(port, dll_name, /readpos)

			if strlowcase(home_motor) eq 'cal' then	begin
				comms_wrapper, port, dll_name, type='moxa', /write, data = 'HOSP500'  + tx
				res = drive_motor(port, dll_name, /gohix)
				res = drive_motor(port, dll_name, drive_to = read_pos + 3000)
			endif else begin
				res = drive_motor(port, dll_name, drive_to = read_pos - 9000)
			endelse

			;\\ Close notification window
				if widget_info(base, /valid) eq 1 then widget_control, base, /destroy
		endif

	read_pos = drive_motor(port, dll_name, /readpos)

	;\\ Restart the camera
		res = call_external(misc.dll_name, 'uStartAcquisition')

end




;\\ CALIBRATION SWITCH ROUTINES
pro AFA_switch, source, $
				misc, console, $
				home=home

end





;\\ FILTER SELECT ROUTINES
pro AFA_filter, filter_number, $
				log_path = log_path, $
				misc, console

	;\\ ACE Smart FIlter has a zero-based filter position index, 0-5.

	if keyword_set(log_path) then cd, log_path, current = old_dir

	;\\ Stop the camera while we move the filter:
	   	res = call_external(misc.dll_name, 'uAbortAcquisition')

	;\\ Notify that we are changing the filter
		base = widget_base(col=1, group=misc.console_id, /floating)
		info = widget_label(base, value='Selecting Filter ' + string(filter_number, f='(i1)'), font='Ariel*20*Bold')
		widget_control, /realize, base

	;\\ At every call, ensure the serial port is in the correct mode:
		port = misc.port_map.filter.number
		dll = misc.dll_name
		tx = string(13B)
		comms_wrapper, port, dll, type = 'moxa', moxa_setbaud=13

		cmd = string(filter_number, format='(i1)') + ' MV' + tx
		comms_wrapper, port, dll, type = 'moxa', /write, data = cmd

		fin = 0
		while fin eq 0 do begin
			comms_wrapper, port, dll, type='moxa', /read, data=in
			in = strsplit(in, tx, /extract)
			match = where(strmid(in, 0, 2) eq 'W1', nmatch)
			fin = nmatch
			wait, 0.001
		endwhile

		;\\ Query new status
		comms_wrapper, port, dll, type='moxa', /write, data='+'+tx
		wait, 1
		comms_wrapper, port, dll, type='moxa', /read, data=in

		in = strsplit(in, tx, /extract)
		new_filter = fix((strsplit(in[1], '=', /extract))[1])
		fault = fix((strsplit(in[5], '=', /extract))[1])

		if new_filter ne filter_number or fault ne 0 then begin
			;\\ DO WHAT HERE??
			openw, hnd, (console->get_logging_info()).log_directory + 'Filter_Faults.txt', /append, /get
			printf, hnd, systime(/ut) + ' > Requested: ' + string(filter_number, f='(i0)') + $
					', Got: ' + string(new_filter, f='(i0)') + ', Fault=' + string(fault, f='(i0)')
			free_lun, hnd
		endif

	;\\ CLose the message box
		if widget_info(base, /valid) eq 1 then widget_control, base, /destroy

	;\\ Restart the camera
		res = call_external(misc.dll_name, 'uStartAcquisition')

	if keyword_set(log_path) then cd, old_dir
end



;\\ ETALON LEG ROUTINES
pro AFA_etalon, dll, $
				  leg1_voltage, $
				  leg2_voltage, $
				  leg3_voltage, $
				  misc, console

	delay1 = 0.002
	delay2 = 0.008

	cmd = 'E1L1V' + string(leg1_voltage, format='(i4.4)') + string(13B)
	comms_wrapper, misc.port_map.etalon.number, misc.dll_name, type = 'moxa', /write, data = cmd
	wait, delay1 & comms_wrapper, misc.port_map.etalon.number, misc.dll_name, type = 'moxa', /read & wait, delay2

	cmd = 'E1L2V' + string(leg2_voltage, format='(i4.4)') + string(13B)
	comms_wrapper, misc.port_map.etalon.number, misc.dll_name, type = 'moxa', /write, data = cmd
	wait, delay1 & comms_wrapper, misc.port_map.etalon.number, misc.dll_name, type = 'moxa', /read & wait, delay2

	cmd = 'E1L3V' + string(leg3_voltage, format='(i4.4)') + string(13B)
	comms_wrapper, misc.port_map.etalon.number, misc.dll_name, type = 'moxa', /write, data = cmd
	wait, delay1 & comms_wrapper, misc.port_map.etalon.number, misc.dll_name, type = 'moxa', /read & wait, delay2
end




;\\ IMAGE POST PROCESSING ROUTINES
pro AFA_imageprocess, image

	image = 10*image
	smim = smooth(image, 41, /edge_truncate)
	image = (5000 + image - min(smim(128:384, 128:384))) > 0

end




;\\ INITIALISATION ROUTINES
pro AFA_initialise, misc, console

	console->log, '** AFA SDI **', 'InstrumentSpecific', /display

	;\\ Set up the com ports
	comms_wrapper, misc.port_map.cal_source.number, misc.dll_name, type = 'moxa', /open, errcode=errcode, moxa_setbaud=12
	console->log, 'Open Calibration Source Port: ' + string(errcode, f='(i0)'), 'InstrumentSpecific', /display
	comms_wrapper, misc.port_map.mirror.number, misc.dll_name, type = 'moxa', /open, errcode=errcode, moxa_setbaud=12
	console->log, 'Open Mirror Port: ' + string(errcode, f='(i0)'), 'InstrumentSpecific', /display
	comms_wrapper, misc.port_map.filter.number, misc.dll_name, type = 'moxa', /open, errcode=errcode, moxa_setbaud=13
	console->log, 'Open Filter Port: ' + string(errcode, f='(i0)'), 'InstrumentSpecific', /display
	comms_wrapper, misc.port_map.etalon.number, misc.dll_name, type = 'moxa', /open, errcode=errcode, moxa_setbaud=14
	console->log, 'Open Etalon Port: ' + string(errcode, f='(i0)'), 'InstrumentSpecific', /display


	;\\ Initialise Faulhaber motors
	tx = string(13B)
	comms_wrapper, misc.port_map.cal_source.number, misc.dll_name, type='moxa', /write, data = 'DI'+tx  ;\\ disable cal source motor
	comms_wrapper, misc.port_map.mirror.number, misc.dll_name, type='moxa', /write, data = 'EN'+tx 	  ;\\ enable mirror motor
	comms_wrapper, misc.port_map.mirror.number, misc.dll_name, type='moxa', /write, data = 'ANSW1'+string(13B)


	;\\ Setup etalon
	commands = ['E1L1CC179', 'E1L2CC179', 'E1L3CC179', $ ;\\ capacitive coarse
				'E1L1CF130', 'E1L2CF150', 'E1L3CF090', $ ;\\ capacitive fine
				'E1L1RC132', 'E1L2RC130', 'E1L3RC130', $ ;\\ resistive coarse
				'E1L1RF121', 'E1L2RF133', 'E1L3RF133', $ ;\\ resistive fine
				'E1L1PC227', 'E1L2PC227', 'E1L3PC228', $ ;\\ phase coarse
				'E1L1PF127', 'E1L2PF127', 'E1L3PF127' ]	 ;\\ phase coarse

	for c = 0, n_elements(commands) - 1 do begin
		comms_wrapper, misc.port_map.etalon.number, misc.dll_name, type = 'moxa', /write, data = commands[c]+tx
		wait, 0.1
		comms_wrapper, misc.port_map.etalon.number, misc.dll_name, type = 'moxa', /read, data = in
		pt = (where(byte(in) le 13))[0] > 1
		console->log, 'Sent Etalon Command: ' + commands[c] + ', Result: ' + strmid(in, 0, pt), 'InstrumentSpecific', /display
		wait, 0.1
	endfor


		;afa_etalon_setup, misc, log,'E1L1CC179' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L2CC179' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L3CC179' & wait, 0.1
		;OLD afa_etalon_setup, misc, log,'E1L1CF178'
		;OLD afa_etalon_setup, misc, log,'E1L1CF150'
		;afa_etalon_setup, misc, log,'E1L1CF130' & wait, 0.1
		;OLD afa_etalon_setup, misc, log,'E1L2CF198'
		;OLD afa_etalon_setup, misc, log,'E1L2CF170'
		;afa_etalon_setup, misc, log,'E1L2CF150' & wait, 0.1
		;OLD afa_etalon_setup, misc, log,'E1L3CF135'
		;OLD afa_etalon_setup, misc, log,'E1L3CF110'
		;afa_etalon_setup, misc, log,'E1L3CF090' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L1RC132' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L2RC130' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L3RC130' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L1RF121' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L2RF133' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L3RF133' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L1PC227' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L2PC227' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L3PC228' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L1PF127' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L2PF127' & wait, 0.1
		;afa_etalon_setup, misc, log,'E1L3PF127' & wait, 0.1

end

