#!/bin/bash


# Check if the script was called with a directory name
if [ $# -eq 0 ]; then
  echo "Usage: $0 directory"
  exit 1
fi

# Check if the specified directory exists
if [ ! -d $1 ]; then
  echo "Error: $1 is not a directory"
  exit 1
fi

# Change to the specified directory
cd $1 || exit 1

# Create a temporary data file with disk usage information
#df | awk '{if($1 ~ /^\//) print $1,int($5)}' | awk -v q="\"" '{print q$1q,$2/100}' > ./disk_usage.dat
df | awk '{if($1 ~ /^\//) print $1 "," int($5)}' > disk_usage.dat

# Check if the data file is not empty before plotting
if [ -s "./disk_usage.dat" ]; then

  # Generate a stacked bar chart with gnuplot
  gnuplot -persist <<-EOFMarker
    set terminal dumb size 80,30
    set datafile separator ","
    set style data histogram
    set style histogram rowstacked
    set style fill solid border -1
    set boxwidth 0.9
    set yrange [0:100]
    set xrange [*:*]
    set xtics nomirror rotate by -90
    unset key
    set title "Disk Usage Percentage by Mount Point"
    plot "./disk_usage.dat" using 2:xtic(1)
EOFMarker
  
  else

  echo "No disk usage data found."

fi

# Remove the temporary data file
rm -f ./disk_usage.dat
