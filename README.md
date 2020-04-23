# PowerShell-module-tools
Example template of a PowerShell module, with some minor tools and a lot of structure, used to test, demo a new module, or as your own Hello World learning tool.

Originally migrated from a separate repo [Batch-Tools-Sysadmin](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/milestone/6?closed=1)

## Repo status

This repository is currently in a **design and development** phase and should be expected to have big changes per commit.

# Spec

Specification for what this software is, what it should do, what it should not do.

This PowerShell module should be a great example (and good starting framework for modifying it yourself) for not only creating a public PoSh module, but testing, building, packaging it, and distributed in every possible manner:

- PowerShell Gallery
- Chocolatey
- nuget
- GitHub repo
- GitHub .zip package download
- GitHub copy & paste module file
- GitHub copy & paste a "dot-sourceable" collection of function scripts.

There may be other examples & instructions elsewhere that also explain distributing a PowerShell module. This repo will also function as a live, working example of doing the distribution to a "Hello World"-type practice module. It will also function to help me personally practice CI/CD development principles, by creating automations for the test/build/deploy processes. Tools like [Invoke-Build](http://duffney.io/GettingStartedWithInvokeBuild), [PSScriptAnalyzer](https://mikefrobbins.com/2015/11/19/using-psscriptanalyzer-to-check-your-powershell-code-for-best-practices/), [Pester](https://devblogs.microsoft.com/scripting/what-is-pester-and-why-should-i-care/), and [Plaster](https://overpoweredshell.com/Working-with-Plaster/) will be used to achieve this. Examples of using such tools are given in the link [PowerShell must-have tools for development](https://bitsofknowledge.net/2018/03/24/powershell-must-have-tools-for-development/) but instead of following each of those examples to practice doing it yourself, this repo seeks to provide working, ready-to-use examples that can easily be dropped in place and edited to suit your needs.

However, alternative options for module-restricted environments should be considered, where a strict security policy prevents online download of such tools. Micro functions to build the module would be useful. A dot-sourceable file with all the functions would help those cases.

Since this module is dedicated to learning, it should also serve instructions and helper files for setting up a PowerShell instance on new machines, including Profiles, and development tools.

This demo module will also be unique in that it won't be just the framework of a module, but also include some functions of varying complexity. It will be a "real" module in that sense, where other modules can rely on this module and it's functions. Instructions and examples for including module dependencies should also be practiced.

Module dependencies:

- This module should depend on at least one external module (as an example), but it should be easy to also turn this "dependency" off for testing.
  - External module locations:
    - External GitHub repo
    - PowerShell Gallery hosted module
    - chocolatey package module
  - Possible external modules to depend on:
    - Logging module, which can produce & consume
- Practice in another module, setting this module as a dependency.

Example functions:

- Ping list function, that also does Parallel processing. PowerShell has many different ways to execute commands in parallel, multiple versions of this simple Ping function that has input values and returns results should be made to demonstrate all the ways Parallel Processing can be done:
  - [Invoke-Parallel](https://github.com/RamblingCookieMonster/Invoke-Parallel), an external function that can be imported and called upon.
  - [PSParallel](https://github.com/powercode/PSParallel), a PowerShell module utilizing C# to run script blocks in parallel
  - [ForEach -Parallel](https://docs.microsoft.com/en-us/powershell/module/psworkflow/about/about_foreach-parallel?view=powershell-5.1), which requires [Workflows](https://docs.microsoft.com/en-us/powershell/module/psworkflow/about/about_workflows?view=powershell-5.1) (which also have their own [Parallel](https://docs.microsoft.com/en-us/powershell/module/psworkflow/about/about_parallel?view=powershell-5.1) script blocks) (some [Examples](https://www.petri.com/introduction-to-parallel-powershell-processing))
  - [ForEach-Object -Parallel](https://devblogs.microsoft.com/powershell/powershell-foreach-object-parallel-feature/)
  - [Jobs](https://devblogs.microsoft.com/scripting/parallel-processing-with-jobs-in-powershell/)
  > Side note: Many of these methods are only compatible with a certain range of PowerShell versions. What will make testing this more difficult is the fact that the last version of Windows PowerShell is v5.1, v6 and up is PowerShell Core. Some of these methods are only compatible with v6 or v7, but some are *also* compatible with v5.1 (which uses a completely different source library, .NET Core vs .NET Framework).
- Since a ping command could be simple, or a bit more complex (maybe we try a DNS look-up, then a PTR aka reverse DNS look-up. Maybe even a WHOIS!) and we're going to be trying multiple methods of utilizing parallel processing, we also need a separate testing structure that can time the execution of each method of ping function, the regular, linear way (for control experiment, of course) and each other parallel processing method we can find. Demo list of ~1000 items should be used, with -Limit option for testing only 50 or 100.
  - Testing suite tools & functions:
  - Logging of test results per OS version and PowerShell version
  - Measure commands to log execution time of different methods, and logging of the results
  - Escalated privilege requirement testing.
- Module-building helper cmdlets.
- Write-HorizontalRule (terminal output formatting function, also for log files probably)
- PromptForChoice-YesNo (similar to CHOICE from cmd.exe, example of prompting users from a function)
- Get-ScriptDirectory (return the path of the currently executing script)
- Backup-Robocopy (simple backup script utilizing robocopy.exe as the copy tool, standard tool in Windows since 7)
- Clean-RobocopyLog (regex replace to remove percentage signs that clutter robocopy logs)
- Find-AndReplace (find-and-replace content in files recursively within directories, and also filenames themselves)

