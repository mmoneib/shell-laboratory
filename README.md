# Shell Laboratory
A handy toolset for UNIX based shells with common and exotic features.

## Purpose
The purpose of this repository is to provide a tool-set for myself (and maybe others) to use the shell scripts for higher purposes, mainly for four reasons:
- **Learning by doing**: Shell scipts can be intimidating at the beginning. Nothing beats hacking around to learn them.
- **Prototyping**: I have yet to see a programming language that provides such convenience and ease to start writing code from the command-line (Python included). While shell scripts have the issue of portability, as well as a bit of archaic syntax, the plethora of tools avaialable, the inherent modularity of UNIX-like ecosystems, and the ease with which one can call any program naturally inside the script makes it a very suitable language to test an idea. If you are a power user of the shell, the scripts will flow swiftly.
- **For the love of vintage**: There's so much appeal for me in simpler technology.
- **For the love of Rube Goldberg**: You know those machines were a ball keeps falling from one device to another for 15 minutes just to turn on the light bulb? Those machines are the only type where overcomplexity is desired and veneered. Yet unlike the entropian complexity that arises indirectly and unnecessarily in business projects, theirs is desired, modular, and highly testable. Sounds a lot like UNIX shell.

## A Note about Portability
Most of the script are written with Bash in mind. This is mainly because I am a user of Fedora. Nonetheless, I intend to make the scripts as portable as possible, that is eventually; particularly with ZSH. While I may use some widely used programs (like bc for calclulations), the aim is also to use built-ins as much as possible. My approach, thus, is not of a purist, but rather a conservationist.

## Types of Scripts
I always choose tags over folders. Tags allow for a dynamic flat structure which give the user more freedom and reduces the hassle of maintaining directories. Terefore, scripts are maintained in a flat directory structure, all residing in the same directory, and postfixes are used as tags to indicate the type of the script as follows:
- **Sourced**: Scripts which implement basic functionality meant to be sourced (inherited) by other scripts rather than functioning on their own.
- **Sourceable**: Scripts that are meant ot be inherited but which may provide useful functionality per se.
- **Sourcing**: Scripts which are not meant to be sourced by other scripts while may source others. They can also be an independent stand-alones, without any need to source another scripts.

## Coding Gudelines
1. All file names must be suffixed correctly: 'sourced' for abstract scripts which are not meant to be used as stand-alone, and 'sourceable for hybrid script which can be sourced by other scripts or used from the command-line as a stand-alone application. File names are lowercase with words separated by an underscore and the suffix by a double underscore.
2. Scripts following the same common utility theme should be collected as functions inside a utility script for that theme. For non-utility themes of dispersed scripts, consolidation in one script with several functionalities should also be favored, whenever suitable.
3. For all sourced and sourceable scripts, all internal function and fariable names must be preceded by a prefix in the form ____scriptshortnamehere____. A short name should not be more than a few characters, should be unique across all scripts, and should be indicated in a comment directly after the shebang.
4. 

## List of Scripts
### Sourcing
#### Canvas
Transforms the terminal into a canvas where text and color are the brushes. Perfect for ASCII art, but can also be used as a free-form text editor or to practise pixel art.
#### Compound Interest
Provides a workflow to track wealth building through compounded interest. The script can be adjusted to provde Stop Loss and Take Profit targets for each trade along the way.
#### Credits Scroll
Scroll the text of a file or piped input automatically from the bottom-up, in the manner of movie credits, in the viewable area of the opened terminal.
#### Tagger
Add tags to anything and save the metadata in a file database for archiving purposes and easy retrieval of information.
### Sourced
#### Check Option Parameters
Manages the parsing of option parameters and their values.
#### Piped or Not
Reads an input file from a parameter or a pipe's input into an array of lines.
### Sourceable
#### Color Utilities
A utility library that privides interface to manage the terminal's color output with a higher degree of abstraction. Other scripts can use this as an interface to manipulate text and backgrounds.
### Sourced
#### Check Option Parameter
Manage the option parameters of your script with more flexibility and higher level of abstraction than provided by the built-in _getopts_.
#### Depth First Search
A shell implementation fo the popular DFS search strategy. The algorithm can be source in scripts for parsing text, solving games, or implementing AI capabilities.

