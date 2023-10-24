TOMOgram MANager v0.9
Sagar Khavnekar, William Wan 2023



****
TOML
****
.. image:: https://img.shields.io/pypi/v/toml
    :target: https://pypi.org/project/toml/
.. image:: https://travis-ci.org/uiri/toml.svg?branch=master
    :target: https://travis-ci.org/uiri/toml
.. image:: https://img.shields.io/pypi/pyversions/toml.svg
    :target: https://pypi.org/project/toml/
A Python library for parsing and creating `TOML <https://en.wikipedia.org/wiki/TOML>`_.
The module passes `the TOML test suite <https://github.com/toml-lang/toml-test>`_.
See also:
* `The TOML Standard <https://github.com/toml-lang/toml>`_
* `The currently supported TOML specification <https://github.com/toml-lang/toml/blob/v0.5.0/README.md>`_
Installation
============
To install the latest release on `PyPI <https://pypi.org/project/toml/>`_,
simply run:
::
  pip install toml
Or to install the latest development version, run:
::
  git clone https://github.com/uiri/toml.git
  cd toml
  python setup.py install
Quick Tutorial
==============
*toml.loads* takes in a string containing standard TOML-formatted data and
returns a dictionary containing the parsed data.



Short Guide 

TOMOMAN now operates as a set of functions that take in a paramfile for each task. Tasks are individual operations,
such as sorting new stacks, running IMOD preprocessing or AreTomo alignment, and defocus determination. 

Example paramfiles are contained in the TOMOMAN folder. The tomoman_copy_paramfiles function can be used to copy 
them into a working directory. 

Each task has it's own function, but proper paramfiles have a header that can be automatically read. In that case,
tasks can be run using tomoman(paramfilename).

A pipeline of defined tasks can also be run using tomoman_pipeline. The input to this is a plain-text file consisting
of a list of .param files. 



Compiling

Compile using compile_tomoman(target_dir), where target_dir is where place the compiled file. This should be the exec/lib/ subfolder.


To run compiled TOMOMAN, you need to set an environmental $TOMOMANHOME that points to the exec/ subfolder. In the exec/bash/ folder are 
the run scripts. Also, remember to update the matlabRoot parameter in the exec/lib/tomoman_config.sh file.

LICENSE
TOMOMAN is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
