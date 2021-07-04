BEGIN {
    c_sum = 0
    d_sum = 0
}

1 == NR {
    print $1 FS $3 FS $4 FS "avg.cases" FS "avg.deaths"
}

2 == NR {
    c_last[0] = $3
    d_last[0] = $4
}

1 != NR {
    c_sum += $3
    d_sum += $4

    c_r = c_last[avg_size-1]
    d_r = d_last[avg_size-1]

    i = NR - 1 > avg_size ? avg_size : NR - 1
    while (i --> 1) {
        c_last[i] = c_last[i-1]
        d_last[i] = d_last[i-1]
    }
    c_last[0] = $3
    d_last[0] = $4
}

NR > avg_size {
    c_sum -= c_r
    d_sum -= d_r
    avg_cases = c_sum / avg_size
    avg_deaths = d_sum / avg_size
    print $1 FS $3 FS $4 FS avg_cases FS avg_deaths
}
