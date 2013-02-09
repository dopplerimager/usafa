
pro HAARP_ftp_data, force=force

common data_xfer_semaphore, xfer_tstamp

	;\\ Attempt a transfer around 23 UT
	js2ymds, dt_tm_tojs(systime(/ut)), y, m, d, s
	if abs((s/3600.) - 23.) gt (15./60.) and not keyword_set(force) then return

	if n_elements(xfer_tstamp) eq 0 then xfer_tstamp = 0d
	jsnow   = dt_tm_tojs(systime())
	if jsnow - xfer_tstamp lt 12d*3600d and not(keyword_set(force)) then return
	xfer_tstamp = jsnow

	command_string = 'idlde -e "data_transfer, ' + "data_dir = 'c:\users\sdi3000\data\', " + $
				   		"sent_dir = 'c:\users\sdi3000\data\sent\', " + $
				   		"ftp_command = 'usafa:aer0n0my@137.229.27.190', " + $
	 			   		"site = 'HRP'" + '"'

	spawn, command_string, /nowait
end