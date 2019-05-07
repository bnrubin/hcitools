#!/quovadx/cis6.1/integrator/bin/hcitcl
set run_time [clock format [clock seconds] -format "%m-%d-%Y-%H:%M:%S"]
set Date [clock format [clock seconds] -format "%Y%m%d"]
set arg_values $argv
if { $argc < 2 } {
    puts "Usage is: get_stats_data SYSTEM SITE \[EMAIL\]"
    return
}
set system [lindex $arg_values 0]
set sitename [lindex $arg_values 1]
set email [lindex $arg_values 2]
set outfilename [append outfilename "/home/hci/temp/" $system "_" $sitename "_statsfile_" $Date ".csv"]
set subject "get_stats_data for Sitename: $sitename at $run_time"
set debug 0
set outrec ""

if { [file exists $outfilename] } {
    set outfileID [open $outfilename a]
} else {
    set outfileID [open $outfilename w]
    append header "SYSTEM,SITENAME,THREADNAME,MSGSIN,MSGSOUT,BYTESIN,BYTESOUT,IBLATENCY,OBLATENCY,XLATECNT,FORWARDCNT,ERRORCNT,OBDATAQD,PSTATUS"

    #append header "SITENAME,THREADNAME,SAMPLE_DAY,SAMPLE_DATE,SAMPLE_TIME,THREADSTART_DAY,THREADSTART_DATE,"
    #append header "THREADSTART_TIME,THREADSTOP_DAY,THREADSTOP_DATE,THREADSTOP_TIME,"
    #append header "PSTATUS,LASTREAD_DAY,LASTREAD_DATE,LASTREAD_TIME,"
    #append header "LASTWRITE_DAY,LASTWRITE_DATE,LASTWRITE_TIME,"
    #append header "LASTERR_DAY,LASTERR_DATE,LASTERR_TIME,LASTERRTEXT,"
    #append header "ERRORCNT,MSGSIN,MSGSOUT,BYTESIN,BYTESOUT,OBDATAQD,"
    #append header "IBLATENCY,OBLATENCY,TOTLATENCY,IBPRESMSQD,IBPOSTSMSQD,OBPRESMSQD,OBREPLYQD"
    puts $outfileID $header
}

# Attach to the Shared Memory Region
msiAttach
set threadlist [msiTocEntry]
set threadcount [llength $threadlist]

foreach threadname $threadlist {
    if { [string is digit [string range $threadname 0 0]] } {
    puts "$threadname skipped"
    continue    ;# This code added to skip threadnames that start with a digit
    }
    if { [string equal $threadname ""] } {
        continue
    }
    set threadkeys [msiGetStatSample $threadname]
    if {![string equal $threadkeys ""]} {
        set LASTEXTRACT [clock format [keylget threadkeys LASTEXTRACT] -format "%a,%m-%d-%Y,%H:%M:%S"]
        set THREADSTART [clock format [keylget threadkeys START] -format "%a,%m-%d-%Y,%H:%M:%S"]
        set THREADSTOP  [clock format [keylget threadkeys STOP] -format "%a,%m-%d-%Y,%H:%M:%S"]
        set PSTATUS     [keylget threadkeys PSTATUS]
        set PLASTREAD   [clock format [keylget threadkeys PLASTREAD] -format "%a,%m-%d-%Y,%H:%M:%S"]
        set PLASTWRITE  [clock format [keylget threadkeys PLASTWRITE] -format "%a,%m-%d-%Y,%H:%M:%S"]
        set PLASTERROR  [clock format [keylget threadkeys PLASTERROR] -format "%a,%m-%d-%Y,%H:%M:%S"]
        set PLASTERRTEXT [keylget threadkeys PLASTERRTEXT]
        set ERRORCNT    [keylget threadkeys ERRORCNT]
        set MSGSIN      [keylget threadkeys MSGSIN]
        set MSGSOUT     [keylget threadkeys MSGSOUT]
        set BYTESIN     [keylget threadkeys BYTESIN]
        set BYTESOUT    [keylget threadkeys BYTESOUT]
        set OBDATAQD    [keylget threadkeys OBDATAQD]
        set IBLATENCY   [keylget threadkeys IBLATENCY]
        set OBLATENCY   [keylget threadkeys OBLATENCY]
        set TOTLATENCY  [keylget threadkeys TOTLATENCY]
        set IBPRESMSQD  [keylget threadkeys IBPRESMSQD]
        set IBPOSTSMSQD [keylget threadkeys IBPOSTSMSQD]
        set OBPRESMSQD  [keylget threadkeys OBPRESMSQD]
        set OBREPLYQD   [keylget threadkeys OBREPLYQD]
        set XLATECNT    [keylget threadkeys XLATECNT]
        set FORWARDCNT  [keylget threadkeys FORWARDCNT]
        set ERRORCNT    [keylget threadkeys ERRORCNT]

        set statsrec ""

        append statsrec "$system,$sitename,$threadname,$MSGSIN,$MSGSOUT,$BYTESIN,$BYTESOUT,$IBLATENCY,$OBLATENCY,$XLATECNT,$FORWARDCNT,$ERRORCNT,$OBDATAQD,$PSTATUS"

        #append statsrec "$sitename,$threadname,$LASTEXTRACT,$THREADSTART,$THREADSTOP,$PSTATUS,$PLASTREAD,"
        #append statsrec "$PLASTWRITE,$PLASTERROR,$PLASTERRTEXT,$ERRORCNT,$MSGSIN,$MSGSOUT,$BYTESIN,$BYTESOUT,$OBDATAQD,"
        #append statsrec "$IBLATENCY,$OBLATENCY,$TOTLATENCY,$IBPRESMSQD,$IBPOSTSMSQD,$OBPRESMSQD,$OBREPLYQD"

        puts $outfileID $statsrec

    }
}
close $outfileID
