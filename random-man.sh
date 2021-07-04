#!/bin/sh

apropos . | shuf -n1 | cut -d' ' -f1 | xargs -I{} man -Tpdf {} | zathura -
