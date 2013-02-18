pro AFA_setup, data

	;\\ ETALON
	data.etalon.NUMBER_OF_CHANNELS = 128
	data.etalon.LEG1_OFFSET = 1.000000
	data.etalon.LEG2_OFFSET = 1.000000
	data.etalon.LEG3_OFFSET = 1.000000
	data.etalon.LEG1_BASE_VOLTAGE = 500
	data.etalon.LEG2_BASE_VOLTAGE = 730
	data.etalon.LEG3_BASE_VOLTAGE = 550
	data.etalon.NM_PER_STEP = 0.012809
	data.etalon.NM_PER_STEP_REFRESH_HOURS = 300.000000
	data.etalon.GAP_REFRACTIVE_INDEX = 0.000000
	data.etalon.PHASEMAP_REFRESH_HOURS = 30.000000
	data.etalon.GAP = 18.600000
	data.etalon.MAX_VOLTAGE = 4096


	;\\ CAMERA
	data.camera.EXPOSURE_TIME = 0.050000
	data.camera.READ_MODE = 4
	data.camera.ACQUISITION_MODE = 5
	data.camera.TRIGGER_MODE = 0
	data.camera.SHUTTER_MODE = 1
	data.camera.SHUTTER_CLOSING_TIME = 0
	data.camera.SHUTTER_OPENING_TIME = 10
	data.camera.VERT_SHIFT_SPEED = 1
	data.camera.COOLER_ON = 1
	data.camera.COOLER_TEMP = -93
	data.camera.FAN_MODE = 0
	data.camera.CAM_TEMP = -87.035004
	data.camera.XBIN = 2
	data.camera.YBIN = 2
	data.camera.GAIN = 1
	data.camera.XCEN = 256
	data.camera.YCEN = 256
	data.camera.PREAMP_GAIN = 1
	data.camera.BASELINE_CLAMP = 1
	data.camera.EM_GAIN_MODE = 3
	data.camera.VS_AMPLITUDE = 0
	data.camera.AD_CHANNEL = 0
	data.camera.OUTPUT_AMPLIFIER = 0
	data.camera.HS_SPEED = 2
	data.camera.XPIX = 1024
	data.camera.YPIX = 1024


	;\\ HEADER
	data.header.SITE = 'HAARP: Gakona,  Alaska'
	data.header.SITE_CODE = 'HRP'
	data.header.INSTRUMENT_NAME = 'AFA'
	data.header.LONGITUDE = -145.147003
	data.header.LATITUDE = 62.391701
	data.header.YEAR = '2011'
	data.header.DOY = ''
	data.header.OPERATOR = 'MC'
	data.header.COMMENT = 'Last edited 18-Nov-2011'
	data.header.SOFTWARE = ''


	;\\ LOGGING
	data.logging.LOG_DIRECTORY = 'c:\users\sdi3000\log\'
	data.logging.TIME_NAME_FORMAT = 'Y$ doy$'
	data.logging.ENABLE_LOGGING = 1
	data.logging.LOG_OVERWRITE = 0
	data.logging.LOG_APPEND = 1
	data.logging.FTP_SNAPSHOT = '137.229.27.190 -l usafa -pw aer0n0my'


	;\\ MISC
	data.misc.DEFAULT_SETTINGS_PATH = 'c:\users\sdi3000\settings\'
	data.misc.SCREEN_CAPTURE_PATH = 'c:\users\sdi3000\screencapture\'
	data.misc.PHASE_MAP_PATH = 'c:\users\sdi3000\phasemaps\'
	data.misc.ZONE_SET_PATH = 'c:\users\sdi3000\usafa\zonemaps\'
	data.misc.SPECTRA_PATH = 'c:\users\sdi3000\data\'
	data.misc.DLL_NAME = 'c:\users\sdi3000\sdi\bin\sdi_external.dll'
	data.misc.TIMER_TICK_INTERVAL = 0.020000
	data.misc.SHUTDOWN_ON_EXIT = 0
	data.misc.MOTOR_SKY_POS = 87837
	data.misc.MOTOR_CAL_POS = -2121
	data.misc.PORT_MAP.MIRROR.NUMBER = 3
	data.misc.PORT_MAP.MIRROR.TYPE = ''
	data.misc.PORT_MAP.MIRROR.SETTINGS = ''

	data.misc.PORT_MAP.CAL_SOURCE.NUMBER = 5
	data.misc.PORT_MAP.CAL_SOURCE.TYPE = ''
	data.misc.PORT_MAP.CAL_SOURCE.SETTINGS = ''

	data.misc.PORT_MAP.ETALON.NUMBER = 4
	data.misc.PORT_MAP.ETALON.TYPE = 'Access I/O USB to Parallel'
	data.misc.PORT_MAP.ETALON.SETTINGS = ''

	data.misc.PORT_MAP.FILTER.NUMBER = 2
	data.misc.PORT_MAP.FILTER.TYPE = 'Serial, ACE Smart Filter'
	data.misc.PORT_MAP.FILTER.SETTINGS = ''


	data.misc.SOURCE_MAP.S0 = 750
	data.misc.SOURCE_MAP.S1 = 1500
	data.misc.SOURCE_MAP.S2 = 2250
	data.misc.SOURCE_MAP.S3 = 0

	data.misc.SNAPSHOT_REFRESH_HOURS = 0.000000

end
