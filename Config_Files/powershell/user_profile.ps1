<#
    Configuration set up for Windows Terminal with Oh My Posh, and NeoVIM
    
    1. Install the Hack Nerd Fonts
    2. Install Windows Terminal and Powershell from Windows Store
    3. Copy the settings.json for Terminal
    4. Install Scoop and other tools
        *. Run the following commands:  
            
            iwr -useb get.scoop.sh | iex
            scoop install curl sudo jq
    
    5. Install Git for Windows
    6. Install Neovim
        *. scoop install neovim gcc

    7. Make the configuration user profile
        *. mkdir .config/powershell
        .. copy this file and the omp json file

    8. Install Oh-My-Posh
        *. Install-Module posh-git -Scope CurrentUser -Force
        .. Install-Module oh-my-posh -Scope CurrentUser -Force

        oh-my-posh --init --shell pwsh --config .\cuellar.omp.json `
			| Invoke-Expression

    9. Install Terminal Icons
        *. Install-Module -Name Terminal-Icons -Repository PSGallery -Force

    10. Install PSReadline - Autocompletion
        *. Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser`
			-Force -SkipPublisherCheck
#>

# Prompt
Import-Module posh-git
Import-Module oh-my-posh

# Load prompt config
function Get-ScriptDirectory { Split-Path $MyInvocation.ScriptName }
$PROMPT_CONFIG = Join-Path (Get-ScriptDirectory) 'cuellar.omp.json'
oh-my-posh --init --shell pwsh --config $PROMPT_CONFIG | Invoke-Expression

# Icons
Import-Module -Name Terminal-Icons

# PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History

# Alias
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias g git
Set-Alias grep findstr
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'

# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

