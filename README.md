# Shell Laboratory
A handy tool-set for UNIX based shells offering common actions, useful utilities, and various processes, all contriving definite applications which are designed for robustnness, conveniality, and efficiency.

## Purpose
The purpose of this repository is to provide a tool-set for myself (and maybe others) to use the Shell scripts for higher purposes, mainly for four reasons:
* **Learning by doing**: Shell scripts can be intimidating at the beginning. Nothing beats hacking around to learn them.
* **Prototyping**: I have yet to see any other programming language that provides such convenience and ease to start writing code from the command-line (Python included). While shell scripts have the issue of portability, as well as a bit of archaic syntax, the plethora of tools available, the inherent modularity of UNIX-like ecosystems, and the ease with which one can call any program naturally inside the script makes it a very suitable language to test an idea. If you are a power user of the shell, the scripts will flow swiftly.
* **For the love of vintage**: There's so much appeal for me in simpler technologies and the process of creating something complex out of them.
* **For the love of Rube Goldberg**: You know those machines through which a ball keeps falling from one device to another for 15 minutes or so just to turn on the light bulb? Those machines are the only type of functional design where overcomplexity is desired and veneered. Unlike the entropian complexity that arises indirectly and unnecessarily in business projects, theirs is desired, modular, and highly testable. Sounds a lot like UNIX shell.

## Portability
Most of the script are written with Bash in mind. This is mainly because I am a user of Fedora. Nonetheless, I intend to make the scripts as portable as possible, that is eventually; particularly with ZSH. While I may use some widely used programs (like bc for calculations), the aim is also to use built-ins as much as possible. My approach, thus, is not of a purist, but rather a conservationist.

## Structure
My philosophy when it comes to writing projects is that "Evolution is the offspring of Necessity," Hence, a project's structure, in whole or part, should be altered based only on necessity. Necessity, in turn, is dictated by the following aspects:
* **Archetypical Categorization**: The most basic and essential categorization in Shell Laboratory is based on archetypes rather than types as it depends on the nature of the script rather than its funciton or characteristics. Classification into these categories is based on the degree of reusability and the type of input/output operations of the code in question. There are 3 main archetypes: actions, utilities, and processes. Such categorization is achieved by the postfix starting with the double underscore in the script's file name.
* **Subject Matters**: The content of a script file is determined by the commonality of a subject, which enforces further categorization beyond the archetypes. Such a common subject is still defined by its archetype which acts as a qualifier.
* **Degree of Reusability**: A piece of code qualifies to a subject naturally based on its context. On the other hand, fitting it inside a certain archetype depends on the degree of reusability intended. For example, if the piece in question exists within a process but would qualify to be a utility or an action, if it is not meant to be reused, it can and should stay within the process. Hence, in such categorization, the archetype acts as a quantifier.
In order to maintain and enforce the desire for such a model of progress, I developed a framework that combines principles of procedural, object-oriented, as well as functional programming, each in its own archetype. I would call such a framework _PUA_, standing for Process Utility Action, where the P encompasses the Procedural element, U harbors the Object line of thinking, and A follows more the Functional approach. Here, one can see that I use Utility against the conventional use of the term, for which I use Action instead; this is to stay more true to the meaning of the words as used within the framework.
* **Clarity over Genericity**:

### Archetypes of Scripts
Scripts are maintained in a flat directory structure and each script's archetype is designated by the postfix preceded by double underscore "\__" as follows:
* **Action**: Scripts which implement basic and common functionality meant to be called by other scripts rather than functioning on their own as a stand-alone procedure. The basicness here implies a single function per action which doesn't involve storage of in-memory data, while the commonality implies usage in more than one place across the project. Actions should be used by the other archetypes. Actions relates to the Functional paradigm.
* **Utility**: Scripts that are meant to perform a complex function which involves structuring and storage of data. A utility should only be used by a process or another utility. Utilities relates to the Object-Oriented paradigm.
* **Process**: Scripts which are meant to be user-facing and performing several functions. A process should use utilities to store and manipulate data structure, and actions to perform common functionalities. Processes are strictly Procedural and they consist of 3 code sections: input, process, and output, all accessing a shared memory space with the parameters designated by their prefixes indicating to which section they belong. This allows for clean yet flexible flow of data across the process.

### Types of Processes
The Process archetype comes in different flavours depending on its workflow:
* **Linear Process**: A linear process which starts by input initialization, then processes the data, and ends by providing the output as information in one shot.
* **Yielding Process**: A process in which the control of the output is based on a processed criteria. Thus the input is initialized, data is processed inside a loop inside of which a decision of made whether to provide information as an output or not incrementally.

## Coding Guidelines
Guidelines to be followed in order to maintain homogoneity across the different parts of the project, which, in turn, would create a standard, which, in turn, would allow for automation of usage and documentation.

### General
1. Always keep in mind the 3S words: Simplicity, Security, and Scalability. They are the most important aspect of a software project.
2. Project expansion should only based on necessity rather than whim or desire. Adding a new feature should be based on demand, removing one should be triggered by the lack thereof.
3. Regression can also affect design, so in order to avoid falling into the abyss of entropy, constant refactoring is needed when adding or removing code. This involves the following:
- Avoiding redundancy and duplication through consolidation into a higher abstraction.
- Maintaining clarity and simplicity through proper (re)naming, correct (re)placement, and strict (re)scoping of statements or procedures based on necessity.
- Meaningful documentation in standard places to allow for automated documentation.
4. Nothing is enforced as everything is loosely-typed.
5. All file names must be suffixed correctly: "_action", "_utility", or "_process".
6. All scripts should be in a single flat directory.
7. All scripts should start with the shebang #!/bin/sh for portability reasons, whenever possible.
8. All scripts should be self documenting through automatically generated Usage and Help texts. This is achieved by special comments around parameters and functions, which are parsed by the script help\__actions.
9. No sourcing should be used. (_TODO_ Check if a single sourceable class acting as a controller for scripts executin would simplify the code.) Any reusable function should by executing its script independently. Sourcing should be done as _sh $(dirname $0)/script_name_here.sh option\_parameters\_here_.
10. All parameters should be correctly prefixed depending on their section. Access of parameters is also based on the current section.
11. Snake case for functions and Camel case for variables, apart from prefixes or suffixes which are separated by underscore in any case.
12. A brief introduction to the script should be contained in the top comment frame along with the author(s) and the dependencies (usually non built-ins or standard applications invoked by the script).
13. APIs should be developed using the Actions paradigm.
14. Variables without a prefix should be limited only to the scope of their function.
15. Internal functions and variables should be prefixed by double underscores.
16. Generally, each script should terminate itself.

### Action-Specific
1. All action functions should have a name corresponding to the name of the action as intended to be called by the required input parameter "a".
2. Each action function must have an explanatory comment prior to it.
3. Each optional or required input parameter should have an inline explanatory comment above it.
4. Each function should start with validation of its own input parameters.
5. The script's input parameters should be designated as follows:
  - Required Input Parameter of Action Script: Prefixed by _p\_r\__ and should be initialized from an option parameter at the entrance of the actions script. It can be accessed from any action function as long as it is validated for existence in the fir lines of that function.
  - Optional Input Parameter of Action Script: Prefixed by _p\_o\__ and should be initialized from an option parameter at the entrance of the actions script. It can be accessed from any action function as long as it is validated for existence in the fir lines of that function.

### Utility-Specific

### Process-Specific
1. In general, a process is divided into an input function, which parses the input and prepares the data for the process; a process function, which uses the prepared data to perform calculations or manipulations within itself and/or with the help of utilities or actions while also preparing the data for output; and an output function for preparing the data, where it is strictly discouraged to do any sort of manipulation apart from what is required by the for of presentation (no manipulation of data structure).
2. While the whole script uses a form of shared memory,it is softly partitioned by prefixes as follows:
  - Input parameters are used only for configuration, to be initialized by the input function and accessed by the processing and output functions as immutables, and are prefixed by c\_r for required ones and c\_o for optional ones.
  - Process parameters are prepared by the input function and accessed only by the process function in a mutable fashion; they are prefixed by d\_.
  - Output parameters are prepared by the input or process functions and accessed by the process or output functions as immutables; they are prefixed by o\_.
3. Each optional or required input parameter should have an inline explanatory comment above it. 

## List of Scripts (in descending order from a user's perspective)
### Processes
#### Canvas
Transforms the terminal into a canvas where text and color are the brushes. Perfect for ASCII art, but can also be used as a free-form text editor or to practise pixel art.
#### Credits Scroll
Scroll the text of a file or piped input automatically from the bottom-up, in the manner of movie credits, in the viewable area of the opened terminal.
#### Tagger
Add tags to anything and save the metadata in a file database for archiving purposes and easy retrieval of information.
#### Wealth Ladder
Provides a workflow to track wealth building through compounded interest. The script can be adjusted to provide Stop Loss and Take Profit targets for each trade along the way.
### Utilities
#### Check Option Parameter
Manage the option parameters of your script with more flexibility and higher level of abstraction than provided by the built-in _getopts_.
#### Depth First Search
A shell implementation of the popular DFS search strategy. The algorithm can be source in scripts for parsing text, solving games, or implementing AI capabilities.
### Actions
#### Color Actions
Functions that provides interface to manage the terminal's color output with a higher degree of abstraction. Other scripts can use this as an interface to manipulate text and backgrounds.
#### String Actions
Functions for text manipulation.
#### Help Actions
Generate auto documentation for other scripts abiding by the commenting standard of this project as stated above in the guidelines.
