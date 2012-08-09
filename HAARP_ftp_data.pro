
pro HAARP_ftp_data, force=force

common data_xfer_semaphore, xfer_tstamp

       if n_elements(xfer_tstamp) eq 0 then xfer_tstamp = 0d
       jsnow   = dt_tm_tojs(systime())
       if jsnow - xfer_tstamp lt 12d*3600d and not(keyword_set(force)) then return
       xfer_tstamp = jsnow

       ftp_script = 'c:\SDI_ftp_script.ftp'
       openw, spunt, ftp_script, /get_lun
       printf, spunt, 'cd data/haarp'
       printf, spunt, 'lcd c:\users\sdi3000\data\spectra'
       printf, spunt, 'bin'
       printf, spunt, 'hash'
       printf, spunt, 'prompt'
       printf, spunt, 'passive'
       printf, spunt, 'mput *.nc'
       printf, spunt, 'quit'
       close, spunt
       free_lun, spunt

       bat_script = 'c:\SDI_data_xfer.bat'
       openw, spunt, bat_script, /get_lun
       printf, spunt, 'c:'
       printf, spunt, 'cd \users\sdi3000\data\spectra'
       printf, spunt, 'ftps -user:SDI3000 -password:fabryPER0T fulcrum.gi.alaska.edu -s:' + ftp_script
       printf, spunt, 'move *.nc .\2011_fall'
       close, spunt
       free_lun, spunt


       spawn, bat_script, /nowait

end