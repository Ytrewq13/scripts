BEGIN {
    c_sum = 0
    d_sum = 0
}

1 == NR {
    print $1 FS $3 FS $4 FS "avg.cases" FS "avg.deaths"
}

2 == NR {
    last_1[0] = $1
    last_2[0] = $2
    last_3[0] = $3
    last_4[0] = $4
#    c_last[0] = $3
#    d_last[0] = $4
}

1 != NR {
    c_sum += $3
    d_sum += $4

    c_r = last_3[avg_size-1]
    d_r = last_4[avg_size-1]
#    c_r = c_last[avg_size-1]
#    d_r = d_last[avg_size-1]

    i = NR - 1 > avg_size ? avg_size : NR - 1
    while (i --> 1) {
        last_1[i] = last_1[i-1]
        last_2[i] = last_2[i-1]
        last_3[i] = last_3[i-1]
        last_4[i] = last_4[i-1]
#        c_last[i] = c_last[i-1]
#        d_last[i] = d_last[i-1]
    }
    last_1[0] = $1
    last_2[0] = $2
    last_3[0] = $3
    last_4[0] = $4
#    c_last[0] = $3
#    d_last[0] = $4
}

NR > avg_size/2 {
    idx = int(avg_size/2)
    c_sum -= c_r
    d_sum -= d_r
    avg_cases = c_sum / avg_size
    avg_deaths = d_sum / avg_size
    print last_1[idx] FS last_3[idx] FS last_4[idx] FS avg_cases FS avg_deaths
}

END {
    i = NR - 1 > avg_size/2 ? int(avg_size/2) : NR - 1
    while (i --> 0) {
        print last_1[i] FS last_3[i] FS last_4[i] FS FS
    }
}
