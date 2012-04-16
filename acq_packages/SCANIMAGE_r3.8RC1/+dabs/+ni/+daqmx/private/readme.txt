General Notes
* NI DAQmx DLL is expected to be installed on system as part of DAQmx installation -- the DLLs are not supplied by Dabs


Version Detection
* 3 DAQmx API functions (common to all DAQmx versions) have been extracted out of library to use for version detection before loading the full library
* 2 prototype files, one for 32-bit and one for 64-bit, have been created for interfacing to whatever DLL version is installed to determine the version number. The latter prototype file needs/uses a thunk file, also included.


Version 8.8
* Only 32-bit supported
* Header file provided by API


Version 9.3 (and above)
* 32-bit and 64-bit supported
* Header file provided by API is included. A modified version is also included which makes changes needed for 32- and 64-bit compatibility, and to address issues that have been observed with void pointers with Matlab's loadlibrary().
* Platform-specific prototype files included, with 64-bit including thunk file.



