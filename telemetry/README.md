# Flight Data Recorder Grapher
for Laika FDR log files.

## Usage

Start GNU-Octave and change directory to `<KSP game dir>/Ships/Scripts/telemetry`, or the directory where you saved the log from FDR module.
Be sure that the file `FDR_Grapher.m` is present, otherwise copy or move it there.

From GNU-Octave prompt launch `FDR_Grapher` and enter the name of the file to read.

```
GNU Octave, version 4.0.3
Copyright (C) 2016 John W. Eaton and others.

>> FDR_Grapher
Enter FDR filename (without extension): PID_log
Saved SVG file.
Saved PDF file.
Done.
>>>
```

Once done, you'll find the result in `out` sub-directory.
```
>> ls out
PID_log.pdf     PID_log.svg
```

