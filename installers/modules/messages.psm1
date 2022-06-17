function Write-Message {
    [CmdletBinding()]
    param  
    (  
         [Parameter(Position=0)][ValidateNotNullOrEmpty()][string]$Severity = "Information",
         [Parameter(Mandatory = $true, Position=1)][ValidateNotNullOrEmpty()][string]$InformationMessage  ,
         [Parameter(Position=2)][string]$ForegroundColor
    ) 
    Write-Host (Get-Date) "[${Severity}]" $InformationMessage -ForegroundColor $ForegroundColor
}

function Write-Information {
    [CmdletBinding()]
    param  
    (  
         [Parameter(Mandatory = $true, Position=0)][ValidateNotNullOrEmpty()][string]$InformationMessage  
    )  
    Write-Message "Information" $InformationMessage -ForegroundColor Blue
}

function Write-Success {
    [CmdletBinding()]
    param  
    (  
         [Parameter(Mandatory = $true, Position=0)][ValidateNotNullOrEmpty()][string]$SuccessMessage  
    )  
    Write-Message "Success" $SuccessMessage -ForegroundColor Green
}

function Write-Error {
    [CmdletBinding()]
    param  
    (  
         [Parameter(Mandatory = $true, Position=0)][ValidateNotNullOrEmpty()][string]$ErrorMessage  
    )  
    Write-Message "Error" $ErrorMessage -ForegroundColor Red
}

function Write-Warning {
    [CmdletBinding()]
    param  
    (  
         [Parameter(Mandatory = $true, Position=0)][ValidateNotNullOrEmpty()][string]$WarningMessage  
    )  
    Write-Message "Warning" $WarningMessage -ForegroundColor Yellow
}