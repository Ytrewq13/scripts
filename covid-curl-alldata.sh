#!/bin/sh

# Gets data from UK gov API, puts it in a csv file (date,cases,deaths)

URL="https://disease.sh/v3/covid-19/gov/uk"
CURL_REQUEST_TYPE="GET"
CURL_HEADER="accept: */*"
JQ_FILTER='[keys_unsorted, [.[].newCases], [.[].todayDeaths]] | transpose |
    map([.[0], .[1], .[2]]) | reverse | .[] | @csv'
SMA_AWKSCRIPT="/home/sam/.scripts/generic-sma.awk"

CACHE_DIR="$XDG_CACHE_HOME"
CACHE_FILENAME="covid_data.csv"
CACHE_PATH="$CACHE_DIR/$CACHE_FILENAME"

RAW_JSON_FILENAME="raw_data.json"
CSV_FILENAME="cases_deaths.csv"
DATES_FILENAME="dates"
CASES_FILENAME="cases"
DEATHS_FILENAME="deaths"
AVG_CASES_FILENAME="avg_cases"
AVG_DEATHS_FILENAME="avg_deaths"

COMBINED_CSV_FILENAME="all_data.csv"

# Create a temporary directory
TMPDIR="$(mktemp -d)"

RAW_JSON_PATH="$TMPDIR/$RAW_JSON_FILENAME"
CSV_PATH="$TMPDIR/$CSV_FILENAME"

DATES_PATH="$TMPDIR/$DATES_FILENAME"
CASES_PATH="$TMPDIR/$CASES_FILENAME"
DEATHS_PATH="$TMPDIR/$DEATHS_FILENAME"
AVG_CASES_PATH="$TMPDIR/$AVG_CASES_FILENAME"
AVG_DEATHS_PATH="$TMPDIR/$AVG_DEATHS_FILENAME"

COMBINED_CSV_PATH="$TMPDIR/$COMBINED_CSV_FILENAME"

# Get the raw JSON data
curl --request "$CURL_REQUEST_TYPE" \
    --header "$CURL_HEADER" \
    --output "$RAW_JSON_PATH" \
    --fail \
    "$URL"

# Abort on server error
if [ "$?" -ne 0 ]; then
    rm -rf "$TMPDIR"
    exit 1
fi

JQ_FILTER_DATES='keys_unsorted | reverse | .[]'
JQ_FILTER_CASES='[.[].newCases] | reverse | .[]'
JQ_FILTER_DEATHS='[.[].todayDeaths] | reverse | .[]'

# Extract dates, cases, and deaths from the JSON
jq -r "$JQ_FILTER_DATES" "$RAW_JSON_PATH" > "$DATES_PATH"
# Abort on jq error
if [ "$?" -ne 0 ]; then
    rm -rf "$TMPDIR"
    exit 1
fi
jq -r "$JQ_FILTER_CASES" "$RAW_JSON_PATH" > "$CASES_PATH"
# Abort on jq error
if [ "$?" -ne 0 ]; then
    rm -rf "$TMPDIR"
    exit 1
fi
jq -r "$JQ_FILTER_DEATHS" "$RAW_JSON_PATH" > "$DEATHS_PATH"
# Abort on jq error
if [ "$?" -ne 0 ]; then
    rm -rf "$TMPDIR"
    exit 1
fi

# Generate the SMAs for cases and deaths
AVG_LEN_CASES=7
AVG_LEN_DEATHS=14
awk -F, -f "$SMA_AWKSCRIPT" -v "avg_size=$AVG_LEN_CASES" "$CASES_PATH" |
    cut --delimiter=',' --fields=2 > "$AVG_CASES_PATH"
awk -F, -f "$SMA_AWKSCRIPT" -v "avg_size=$AVG_LEN_DEATHS" "$DEATHS_PATH" |
    cut --delimiter=',' --fields=2 > "$AVG_DEATHS_PATH"

# Combine the columns into a final .csv file which we will cache
echo "date,cases,deaths,avg. cases,avg. deaths" > "$COMBINED_CSV_PATH"
paste -d, "$DATES_PATH" "$CASES_PATH" "$DEATHS_PATH" "$AVG_CASES_PATH" \
    "$AVG_DEATHS_PATH" >> "$COMBINED_CSV_PATH"

cp "$COMBINED_CSV_PATH" "$CACHE_PATH"

rm -rf "$TMPDIR"

# TODO: implement a generic simple moving average (awk?) script (with arbitrary
# average size) - simple moving average with arbitrary length that takes a
# single column as input and returns a single column as output
# TODO: change visualise-covid to use this cache file, and use different sized
# averages for each of cases and deaths