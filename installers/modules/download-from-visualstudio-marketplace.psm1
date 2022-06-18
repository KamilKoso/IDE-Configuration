function Download-From-VisualStudio-Marketplace {
    [cmdletbinding()]
    param(
        [ValidateNotNullOrEmpty()][Parameter(Mandatory = $true)][string]$PackageName
    )
    $baseProtocol = "https:"
    $baseHostName = "marketplace.visualstudio.com"
    $Uri = "$($baseProtocol)//$($baseHostName)/items?itemName=$($PackageName)"
    $File = Join-Path -path $env:temp -ChildPath $PackageName
    $HTML = Invoke-WebRequest -Uri $Uri -UseBasicParsing -SessionVariable session
    $DownloadAnchor = $HTML.Links |
    Where-Object { $_.class -eq 'install-button-container' } |
    Select-Object -ExpandProperty href
    Select-Object -ExpandProperty href
    $DownloadUri = "$($baseProtocol)//$($baseHostName)$($DownloadAnchor)"
    Invoke-WebRequest -Uri $DownloadUri -OutFile $File
    return $File
}
