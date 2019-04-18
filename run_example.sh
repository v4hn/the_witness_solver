#!/bin/sh

python visualize.py "puzzles/${1:-example}.lp" 0 > solution.html
echo "Created file solution.html with solutions."
