## Function: determines Linux distro information
#------------------------------------------------------------------------------#
def linux_distro():
    """ Args: None
        Requires: platform
        Returns: list || False if not linux
            [0]: Flavor
            [1]: Version
            [2]: CodeName
        Usage: flavor,version,code_name = linux_distro()
    """
    _f, _v, _c = platform.linux_distribution()
    if is_empty("flavor",_f) == True:
        return False
    else:
        return _f.lower(), _v.lower(), _c.lower()


## Function: python version reporting
#------------------------------------------------------------------------------#
def python_version():
    """ Args: None
        Requires: sys
        Returns:
            py_full: full version, eg 2.7.13
            py_major: major version, eg 2
            py_minor: minor version, eg 7
            py_micro: micro version, eg 13
        Usage:
            py_full, py_major, py_minor, py_micro = python_version()
        References:
            https://www.python.org/dev/peps/pep-0440
    """
    py_major    = int(sys.version.split(' ')[0].split(".")[:1][0])
    py_minor    = int(sys.version.split(' ')[0].split(".")[1:2][0])
    py_micro    = int(sys.version.split(' ')[0].split(".")[1:3][0])
    py_full     = "%i.%i.%i" % (py_major, py_minor, py_micro)
    return py_full, py_major, py_minor, py_micro


## Function: determines if input is empty or not
#------------------------------------------------------------------------------#
def is_empty(_name,_struct):
    """ Args:
            _name (str): name of the struct to check, for debug logging
            _struct (str,int,dict,list,tuple): structure itself to check
        Returns:
            True = empty
            False = !empty
        Usage: is_empty("myVar",myvar)
    """
    if _struct:
        logger("[function:is_empty] _struct input [var:%s val:%s] = true"%(_name,_struct),"d")
        return False
    else:
        logger("[function:is_empty] _struct input [var:%s val:%s] = false"%(_name,_struct),"d")
        return True


## Function: command exec [modules: commands if py <2.6, subprocess otherwise]
#------------------------------------------------------------------------------#
def sysexec(_cmd):
    """ Args:
            _cmd (str): command to execute

        Requires: datetime, (commands || subprocess)

        Returns:
            timing, retcode, stdoutdata

        Usage:
            a = sysexec("echo foo")
            timing = a[0]
            retcode = a[1]
            output: a[2]
            -OR-
            timing, retcode, output = sysexec("echo foo")

        References:
            http://docs.python.org/2/library/subprocess.html
            http://www.bogotobogo.com/python/python_subprocess_module.php
    """
    ## determine if we're on python <2.6 or >2.6
    py_full, py_major, py_minor, py_micro = python_version()
    start = datetime.datetime.now()

    ## Select commands or subprocess module based on python version.
    ## Older Deb/Ubuntu or RH/Cent OSes commonly have 2.4.x
    if py_major == 2 and py_minor < 6:
        import commands
        retcode, stdoutdata = commands.getstatusoutput(_cmd)

    if py_major == 2 and py_minor >= 6:
        from subprocess import Popen, PIPE, STDOUT, call

        ## If --verbose is set, buffer the command output since it can be very long.
        if verbose is True:
            buffer_size=1
        else:
            buffer_size=0

        ## Issue the command... can separate output here if needed later on.
        # stdoutdata = process.communicate()[0]
        # stderrdata = process.communicate()[1] # = None, unless Popen(stderr=PIPE)
        proc = Popen(_cmd,
                        shell=True,
                        stdin=PIPE,
                        stdout=PIPE,
                        stderr=STDOUT,
                        close_fds=False,
                        bufsize=buffer_size)
        for line in iter(proc.stdout.readline, b''):
            print line,

        stdoutdata = proc.communicate()[0]
        retcode = proc.returncode
        proc.stdout.close()
        proc.wait()

    end = datetime.datetime.now()
    timing = end - start
    return timing, retcode, stdoutdata


## START MySQL Functions
#------------------------------------------------------------------------------#
def query_exec(query):
    connection = conn
    cursor = connection.cursor()
    num_affected_rows = cursor.execute(query)
    cursor.close()
    connection.commit()
    return num_affected_rows

def query_row(query):
    connection = conn
    cursor = connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    row = cursor.fetchone()
    cursor.close()
    return row

def query_rows(query):
    connection = conn
    cursor = connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    rows = cursor.fetchall()
    cursor.close()
    return rows

def mysql_connection(_dbhost,_dbuser,_dbpass,_dbport=3306,_dbsock='/var/run/mysqld/mysqld.sock',_dbschema='mysql'):
    if is_empty("_dbhost",_dbhost) == True:
        logger("[function:mysql_connection] missing --dbhost, connection will be impossible.",'c')
        exitcode("EX_NOPERM")
    if is_empty("_dbuser",_dbuser) == True:
        logger("[function:mysql_connection] missing --dbuser, connection will be impossible.",'c')
        exitcode("EX_NOPERM")

    logger("[function:mysql_connection] attempting connection with args: dbhost:%s, dbuser:%s, dbpass:<redacted>, dbport:%i, dbsock:%s, dbschema:%s"%(_dbhost,_dbuser,_dbport,_dbsock,_dbschema),'d')

    try:
        conn = MySQLdb.connect(
            host=_dbhost,
            user=_dbuser,
            passwd=_dbpass,
            port=_dbport,
            db=_dbschema,
            unix_socket=_dbsock)
        return conn;

    except MySQLdb.Error, e:
        logger("Database connection faulure. Error %d: %s"%(e.args[0], e.args[1]),'c')
        exitcode("EX_UNAVAILABLE")
#### END MySQL Functions


## Function: POSIX exit code handler for verbose and debugging modes
#------------------------------------------------------------------------------#
def exitcode(code):
    """ Args:
            code (str): POSIX code from the list below.
        Requires: sys
        Returns: N/A
        Usage: exitcode(EX_IOERR)
        Notes: https://docs.python.org/2/library/os.html#process-management
    """
    posix_codes = {
        'EX_CANTCREAT': 'cannot create output file',
        'EX_CONFIG': 'configuration related error',
        'EX_DATAERR': 'input data was incorrect',
        'EX_IOERR': 'error during Input/Output operation',
        'EX_NOHOST': 'specified host does not exist',
        'EX_NOINPUT': 'input file did not exist or was not readable',
        'EX_NOPERM': 'insufficient permission on operation',
        'EX_NOTFOUND': 'data location failure',
        'EX_NOUSER': 'specified user does not exist',
        'EX_OK': 'exit code with no errors, the good kind of exit',
        'EX_OSERR': 'OS level error encountered during processing',
        'EX_OSFILE': 'file access/permission/pointer error',
        'EX_PROTOCOL': 'communication protocol illegal, invalid',
        'EX_SOFTWARE': 'internal software error encountered',
        'EX_TEMPFAIL': 'inconsistent or temporary failure',
        'EX_UNAVAILABLE': 'required service is unavailable',
        'EX_USAGE': 'command was used incorrectly'
    }

    if code in posix_codes:
        if debug is True:
            logger("[function:exitcode] exit code received: %s"%(code),"d")

        if code == "EX_OK":
            sys.exit(0)

        if code != "EX_OK":
            sys.exit(1)

    else:
        if debug is True:
            logger("[function:exitcode] requested exit code not found: %s"%(code),"c")
        sys.exit(127)

## Function: logging (console, file)
#------------------------------------------------------------------------------#
def logger(_content, _level):
    """ Args:
    	   content (str): message to log to file
    	   level: log level of message
                d = DEBUG
                i = INFO
                w = WARN
                e = ERROR
                c = CRIT
        Requires: log
        Returns: True: success || exitcode("EX_DATAERR")
        Usage: logger("a debug message","d")
    """
    if(_level == "d"):
        log.debug("%s" % (_content))
    elif(_level == "i"):
        log.info("%s" % (_content))
    elif(_level == "w"):
        log.warn("%s" % (_content))
    elif(_level == "e"):
        log.error("%s" % (_content))
    elif(_level == "c"):
        log.critical("%s" % (_content))
    else:
        exitcode("EX_DATAERR")

    return True


## Function: script exec user/uid
#------------------------------------------------------------------------------#
def whoami():
    """ Args: None
        Requires: getpass, os
        Returns: _user, _uid || exitcode("EX_OSERR")
        Usage/Notes: user,uid = whoami()
    """
    try:
        _user = getpass.getuser()
        _uid = os.getuid()
        logger("[function:whoami] script is running as [user:%s],[uid:%s]"%(_user,_uid),"d")

    except:
        logger("[function:whoami] failed to determine script's executing user or uid.","c")
        exitcode("EX_OSERR")

    return (_user, _uid)


## Function: option parser, configures command line arguments
#------------------------------------------------------------------------------#
def parse_options():
    """ Args: None
        Requires: OptionParser
        Returns: parser.parse_args()
        Usage:
            (options, args) = parse_options()
            argv1           = options.argv1
            argv2           = options.argv2

        Sample:
            parser.add_option("--option",
                                        dest="variable",
                                        default="default",
                                        action="store_true",
                                        help="Contents [default: null]")
    """

    usage = "usage: "
    parser = OptionParser(usage=usage)
    parser.add_option("--dbuser",
                      dest="dbuser",
                      default="root",
                      help="DB user [default: root]")

    return parser.parse_args()


## Config file handler for replication server connection info
#------------------------------------------------------------------------------#
def repl_cfg_handler(_cfg_file):
    """ Args:
    	   _cfg_file(str): filename containing replication connection auth info
        Requires: os, ConfigParser
        Returns:
            _host = replication server hostname
            _user = replication server username
            _pass = replication server password
            _port = replication server port
        Usage:
            _repl_host, _repl_user, _repl_pass, _repl_port = repl_cfg_handler(checkrepl_file)
    """

    ## test config file existence and access
    logger("[function:repl_cfg_handler] testing replication cfg file access: %s"%(_cfg_file),'d')
    if(os.path.exists(_cfg_file)):
        logger("[function:repl_cfg_handler] file exists: %s"%(_cfg_file),'d')
        if(os.access(_cfgfile, os.R_OK)):
            logger("[function:repl_cfg_handler] file readable: %s"%(_cfg_file),'d')
        else:
            logger("[function:repl_cfg_handler] file read FAILED: %s"%(_cfg_file),'c')
            exitcode("EX_NOINPUT")
    else:
        logger("[function:repl_cfg_handler] file does not exist: %s"%(_cfg_file),'c')
        exitcode("EX_NOINPUT")

    ## initilize config settings
    # config file header string: "[replication_connection]"
    _cfg_parser = ConfigParser()
    _cfg_parser.read([_cfg_file])
    _header = 'replication_connection'
    _host = _cfg_parser.get(_header,'repl_host')
    _user = _cfg_parser.get(_header,'repl_user')
    _pass = _cfg_parser.get(_header,'repl_pass')
    _port = _cfg_parser.get(_header,'repl_port')

    return _host, _user, _pass, _port
