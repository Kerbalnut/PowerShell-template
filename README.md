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

There may be other examples & instructions elsewhere that also explain distributing a PowerShell module. This repo will also function as a live example of doing the distribution to a "Hello World" type practice module. It will also function to help me learn CI/CD development principles, by creating automations for the test/build/deploy processes. Tools like PSScriptAnalyzer, Pester, and Plaster will be used to achieve this. Examples of using such tools are given in the link [PowerShell must-have tools for development](https://bitsofknowledge.net/2018/03/24/powershell-must-have-tools-for-development/) but instead of following each of those examples to practice doing it yourself, this repo seeks to provide working, ready-to-use examples that can easily be dropped in place and edited to suit your needs.

However, alternative options for module-restricted environments should be considered, where a strict security policy prevents online download of such tools. Micro functions to build the module would be useful. A dot-sourceable file with all the functions would help those cases.

This demo module will also be unique in that it won't be just the framework of a module, but also include some functions of varying complexity. It will be a "real" module in that sense, where other modules can rely on this module and it's functions. Instructions and examples for including module dependencies should also be practiced.


