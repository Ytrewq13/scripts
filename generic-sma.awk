# Awk script to produce a Simple Moving Average of a single column of data.
# Set `avg_size` to control the width of the window used to compute the average
# (i.e. `avg_size=7` for a 7-day average with daily data)
# Recommended usage is from a shell script (with pipes or temporary files):
# `... | awk -F, -f"/path/to/this/script.awk" -v "avg_size=14" | ...`

BEGIN {
    if (length(avg_size) == 0) { avg_size=7; }
    # Running sum
    the_sum = 0
}

# Before we have read enough lines to have an average, print an empty average
# column
avg_size/2 >= NR {
    print $1 FS
}

1 == NR {
    # `last` acts like a queue, storing up to `avg_size` items
    last[0] = $1
}

{
    the_sum += $1
    to_remove = last[avg_size-1]

    i = avg_size
    while (i --> 1) {
        last[i] = last[i-1]
    }
    last[0] = $1
}

# When we have read enough lines to calculate the average, calculate it and
# print it (along with the correct input from our stored queue (`last`)
NR >= avg_size {
    idx = int(avg_size/2)
    the_sum -= to_remove
    the_sum = 0
    i = avg_size
    while (i --> 0) {
        the_sum += last[i]
    }
    the_avg = the_sum / avg_size
    print last[idx] FS the_avg
}

# At the end of the file, print everything that is left in the unprinted half
# of the queue (`last`)
END {
    i = NR - 1 > avg_size/2 ? int(avg_size/2) : NR - 1
    while (i --> 0) {
        print last[i] FS
    }
}
