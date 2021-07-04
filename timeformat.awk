#!/bin/awk -f
#
# Formats a number of seconds into Days, Hours, Minutes, Seconds
# (can work on multiple lines)
# Only prints Days, Hours, Minutes if they are required.
#
# TODO: move sexagesimal into a function in a different file and then call it
# on the time after days have been removed.
{
    ds=86400    # Seconds per day
    hs=3600     # Seconds per hour
    ms=60       # Seconds per minute
    t=$1
    d=0
    h=0
    m=0
    s=0
    sign=1
    if (t<0)
        sign=-1
    t=t*sign
    d=int(t/ds)
    t-=d*ds
    h=int(t/hs)
    t-=h*hs
    m=int(t/ms)
    t-=m*ms
    s=t
    if (sign==-1)
        printf "-"
    if (d>1)
        printf "%d days ", d
    else if (d>0)
        printf "%d day ",  d
    # Sexagesimal: HH:MM:SS.usecs
    printf "%02d:%02d:%09.6f\n", h, m, s
    # After the decimal point, microseconds are printed (millionths of seconds)
    # Therefore, 6 digits are needed after the decimal point. We need 2 digits
    # for seconds, so (with the character for the decimal) we need 9 characters
    # in total to print the seconds and microseconds together.
}
